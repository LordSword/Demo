//
//  IntermediaryTimer.h
//  YuanXin_Project
//
//  Created by Sword on 15/9/15.
//  Copyright (c) 2015年 yuanxin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TimerIntermediary;
typedef void(^TimerAction)( TimerIntermediary *intermediary, __kindof NSObject *target);

@interface TimerIntermediary : NSObject

@property (strong, nonatomic, readonly) NSTimer   *timer;

@property (weak, nonatomic, readonly) id          target;
@property (copy, nonatomic, readonly) TimerAction action;

+ (instancetype)timerIntermediaryWithTimeInterval:(NSTimeInterval)timeInterval
                                target:(id)target
                                action:(TimerAction)action
                              userInfo:(id)usrinfo
                               repeats:(BOOL)yesOrNo;

- (void)start;
- (void)startWithDate:(NSDate *)date;
- (void)stop;
@end
