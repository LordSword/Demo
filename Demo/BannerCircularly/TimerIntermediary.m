//
//  IntermediaryTimer.m
//  YuanXin_Project
//
//  Created by Sword on 15/9/15.
//  Copyright (c) 2015年 yuanxin. All rights reserved.
//

#import "TimerIntermediary.h"

@interface TimerIntermediary()

@property (nonatomic, readwrite, strong) NSTimer     *timer;

@property (nonatomic, readwrite, weak  ) id             target;
@property (nonatomic, readwrite, copy  ) TimerAction    action;
@property (nonatomic, readwrite, assign) NSTimeInterval timeInterval;
@property (nonatomic, readwrite, strong) id             usrinfo;
@property (nonatomic, readwrite, assign) BOOL           repeats;
@end

@implementation TimerIntermediary

+ (instancetype)timerIntermediaryWithTimeInterval:(NSTimeInterval)timeInterval
                                           target:(id)target
                                           action:(TimerAction)action
                                         userInfo:(id)usrinfo
                                          repeats:(BOOL)yesOrNo {
    
    NSParameterAssert(target);
    
    TimerIntermediary *intermediary = [[TimerIntermediary alloc] init];
    
    intermediary.action = action;
    intermediary.target = target;
    intermediary.timeInterval = timeInterval;
    intermediary.usrinfo = usrinfo;
    intermediary.repeats = yesOrNo;
    
    return intermediary;
}


#pragma mark - action
- (void)timerAction {
    
    if (self.target && self.action) {
        
        __weak __typeof__(self) weak_self = self;
        self.action(weak_self, self.target);
    } else {
        [self stop];
    }
}

- (void)start {
     [self startWithDate:[NSDate date]];
}
- (void)startWithDate:(NSDate *)date {
    
    [self stop];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(timerAction) userInfo:self.usrinfo repeats:self.repeats];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    self.timer.fireDate = date;
}
- (void)stop {
    
    if (self.timer) {
        [self.timer invalidate]; self.timer = nil;
    }
}

@end
