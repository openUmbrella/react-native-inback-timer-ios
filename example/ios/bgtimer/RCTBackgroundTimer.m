//
//  RCTInBackTimer.h
//  RCTInBackTimer
//
//  Created by jeff.Li on 2018/11/7.
//  Copyright © 2018 jeff.Li. All rights reserved.

#import "RCTBackgroundTimer.h"

NSString * const BASICEVENTNAME = @"backgroundTimerEvent";
const NSInteger MAXTIMERCOUNT = 20;

@interface RCTBackgroundTimer ()


@property (nonatomic, strong) NSMutableArray *timerPool;

@property (nonatomic, assign) BOOL hasListeners;


@end

@implementation RCTBackgroundTimer

-(instancetype)init{
  if (self = [super init]) {
    // 监听通知App进入后台的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
  }
  return self;
}

-(void)dealloc{
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
}

-(void)appEnterBackground:(NSNotification *)notification{
  
  [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    // NSLog(@"我的剩余时间已经没有了");
  }];
  
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
  
  NSLog(@"我们的时钟池:%@", self.timerPool);
  
  for (NSMutableDictionary *timeDict in self.timerPool) {
    NSString *eventName = timeDict[@"eventName"];
    if ([eventName isEqualToString:timer.userInfo[@"eventName"]]) {
      NSInteger remainCount = ((NSNumber *)timeDict[@"remainCount"]).integerValue;
      if (remainCount < 0) {
        [(NSTimer *)timeDict[@"timer"] invalidate];
        [self.timerPool removeObject:timeDict];
        break;
      }else{
        // 如果桥接还存在的话, 就向js端发送事件
        if (self.bridge != nil && self.hasListeners) {
          --remainCount;
          [self sendEventWithName:timer.userInfo[@"eventName"] body:@{@"remain": @(remainCount)}];
          timeDict[@"remainCount"] = @(remainCount);
        }else{
          // 清空所有的时钟
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
      // 将时钟停止
      [(NSTimer *)timerDic[@"timer"] invalidate];
      // 将这个时钟信息从时钟池中删除
      [self.timerPool removeObject:timerDic];
      break;
    }
  }
}


#pragma mark - 懒加载

-(NSMutableArray *)timerPool{
  if (_timerPool == nil) {
    _timerPool = [NSMutableArray array];
  }
  return _timerPool;
}


@end
