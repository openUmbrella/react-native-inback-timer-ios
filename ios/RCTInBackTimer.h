//
//  RCTInBackTimer.h
//  RCTInBackTimer
//
//  Created by jeff.Li on 2018/11/7.
//  Copyright © 2018 jeff.Li. All rights reserved.
//

/**
 在使用这个模块时，必须先进行如下设置：
 1. 在info.plist表中新增字段 Application does not run in background 值为 NO
 2. 如果想要实现App长期在后台运行，需要在info.plist表中再加上字段：Required background modes 填入对应的值（如：location，notification，Bluetooth等）。或者通过选择：项目 -> capabilities -> 打开 background Modes 并选择对应功能。注意： 需要根据对应的App类型来选择对应的后台功能。如果乱选，审核会不过。如果想要更深入的了解，请自定搜索：“ios后台状态长时间运行” 相关知识
 
 **/

#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeModule.h>

@interface RCTInBackTimer : RCTEventEmitter <RCTBridgeModule>



@end
