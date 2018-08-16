//
//  WaterWaveView.m
//  Demo
//
//  Created by sword on 2017/7/21.
//  Copyright © 2017年 Sword. All rights reserved.
//

#import "WaterWaveView.h"

#import "TimerIntermediary.h"

@interface WaterWaveView() <CAAnimationDelegate>

@property (strong, nonatomic) NSMutableArray <CALayer *> *animationLayer;
@property (strong, nonatomic) TimerIntermediary *timer;

@end

@implementation WaterWaveView

- (void)wave {
    
    if (self.animation) return;
    self.animation = true;
    
    [self.timer start];
    for (CALayer *layer in self.animationLayer) {
        [self startAnimationWithShape:layer];
    }
}
- (void)stopWave {
    
    if (!self.animation) return;
    self.animation = false;
    
    [self.timer stop];
    for (CALayer *layer in self.animationLayer) {
        [self pauseAnimationWithShape:layer];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if (flag) {
        CALayer *layer = [anim valueForKey:@"layer"];
        
        if ([self.animationLayer containsObject:layer]) {
            [layer removeFromSuperlayer];
            [self.animationLayer removeObject:layer];
        }
    }
}

- (void)startAnimationWithShape:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}
- (void)pauseAnimationWithShape:(CALayer *)layer {
    
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

- (CALayer *)createAnimationLayer {
    CALayer *result = [CALayer layer];
    
    result.backgroundColor = self.originColor.CGColor;
    result.bounds = self.bounds;
    result.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    result.masksToBounds = YES;
    result.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height)/2;
    
    return result;
}

- (void)getAnimationActionWithLayer:(CALayer *)layer {
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim.fromValue = @0.3;
    anim.toValue = @1;
    
    CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    anim1.fromValue = (id)self.originColor.CGColor;
    anim1.toValue = (id)[self.originColor colorWithAlphaComponent:0.01].CGColor;
    
    animationGroup.duration = 2.5f;
    animationGroup.repeatCount = 1;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    animationGroup.animations = @[anim, anim1];
    animationGroup.delegate = self;
    
    [animationGroup setValue:layer forKey:@"layer"];
    [layer addAnimation:animationGroup forKey:@"layer"];
}


- (NSMutableArray<CALayer *> *)animationLayer {
    
    if (!_animationLayer) {
        _animationLayer = [NSMutableArray arrayWithCapacity:5];
    }
    return _animationLayer;
}

- (TimerIntermediary *)timer {
    
    if (!_timer) {
        _timer = [TimerIntermediary timerIntermediaryWithTimeInterval:1.f target:self action:^(TimerIntermediary *intermediary, WaterWaveView *target) {
            
            CALayer *layer = [target createAnimationLayer];
            [target getAnimationActionWithLayer:layer];
            [target.layer addSublayer:layer];
            [target.animationLayer addObject:layer];
        } userInfo:nil repeats:YES];
    }
    return _timer;
}

@end
