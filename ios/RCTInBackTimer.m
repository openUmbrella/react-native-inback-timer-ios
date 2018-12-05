//
//  RCTInBackTimer.h
//  RCTInBackTimer
//
//  Created by jeff.Li on 2018/11/7.
//  Copyright © 2018 jeff.Li. All rights reserved.

#import "RCTInBackTimer.h"

NSString * const BASICEVENTNAME = @"backgroundTimerEvent";
const NSInteger MAXTIMERCOUNT = 20;

@interface RCTInBackTimer ()


@property (nonatomic, strong) NSMutableArray *timerPool;

@property (nonatomic, assign) BOOL hasListeners;

@property (nonatomic, assign) UIBackgroundTaskIdentifier taskId;


@end

@implementation RCTInBackTimer

-(instancetype)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground:) name:@"UIApplicationWillEnterForegroundNotification" object:nil];
    }
    return self;
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIApplicationWillEnterForegroundNotification" object:nil];
}

-(void)appEnterBackground:(NSNotification *)notification{
    
    __weak typeof(self) weakSelf = self;
    self.taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.taskId];
        weakSelf.taskId = UIBackgroundTaskInvalid;
    }];
    
}
-(void)appEnterForeground:(NSNotification *)notification{
    [[UIApplication sharedApplication] endBackgroundTask:self.taskId];
    self.taskId = UIBackgroundTaskInvalid;
}

RCT_EXPORT_MODULE()

- (NSDictionary *)constantsToExport {
    return @{
             @"basicEventName": BASICEVENTNAME,
             @"maxTimerCount": @(MAXTIMERCOUNT)
             };
}

+(BOOL)requiresMainQueueSetup{
    return YES;
}

- (NSArray<NSString *> *)supportedEvents { return [self eventList]; }


-(NSArray *)eventList{
    NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:MAXTIMERCOUNT];
    for (int i = 0; i < MAXTIMERCOUNT; i++) {
        [muArr addObject: [NSString stringWithFormat:@"%@%d",BASICEVENTNAME, i]];
    }
    return muArr.copy;
    
}

-(void)startObserving{
    
    self.hasListeners = YES;
}

-(void)stopObserving{
    
    self.hasListeners = NO;
}


RCT_EXPORT_METHOD(timer:(NSString *)eventName
                  interval: (double)interval
                  count: (NSInteger) count
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:(interval / 1000.0f) target:self selector:@selector(sendCountDownEvent:) userInfo: @{@"outTime": @(count), @"eventName":eventName} repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    [self.timerPool addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                              @"timer": timer,
                                                                              @"remainCount": @(count),
                                                                              @"eventName": eventName,
                                                                              }]];
    
    resolve(@(1));
}

-(void)sendCountDownEvent:(NSTimer *)timer{
    
    for (NSMutableDictionary *timeDict in self.timerPool) {
        NSString *eventName = timeDict[@"eventName"];
        if ([eventName isEqualToString:timer.userInfo[@"eventName"]]) {
            NSInteger remainCount = ((NSNumber *)timeDict[@"remainCount"]).integerValue;
            if (remainCount < 0) {
                [(NSTimer *)timeDict[@"timer"] invalidate];
                [self.timerPool removeObject:timeDict];
                break;
            }else{
                if (self.bridge != nil && self.hasListeners) {
                    --remainCount;
                    [self sendEventWithName:timer.userInfo[@"eventName"] body:@{@"remain": @(remainCount)}];
                    timeDict[@"remainCount"] = @(remainCount);
                }else{
                    for (NSDictionary *timeDict in self.timerPool) {
                        NSTimer *timer = timeDict[@"timer"];
                        [timer invalidate];
                    }
                    [self.timerPool removeAllObjects];
                }
                break;
            }
            
        }
        
    }
    
}


RCT_EXPORT_METHOD(clear:(NSString *)eventName){
    
    for (NSMutableDictionary *timerDic in self.timerPool) {
        NSString * timerEventName = timerDic[@"eventName"];
        if ([timerEventName isEqualToString: eventName]) {
            [(NSTimer *)timerDic[@"timer"] invalidate];
            [self.timerPool removeObject:timerDic];
            break;
        }
    }
}

-(NSMutableArray *)timerPool{
    if (_timerPool == nil) {
        _timerPool = [NSMutableArray array];
    }
    return _timerPool;
}


@end
