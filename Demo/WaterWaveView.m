//
//  WaterWaveView.m
//  Demo
//
//  Created by sword on 2017/7/21.
//  Copyright © 2017年 Sword. All rights reserved.
//

#import "WaterWaveView.h"

@interface WaterWaveView()

@property (strong, nonatomic) CALayer *layer1;
@property (strong, nonatomic) CALayer *layer2;
@property (strong, nonatomic) CALayer *layer3;

@end

@implementation WaterWaveView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self.layer addSublayer:self.layer1];
        [self.layer addSublayer:self.layer2];
        [self.layer addSublayer:self.layer3];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layer1.bounds = self.bounds;
    self.layer2.bounds = self.bounds;
    self.layer3.bounds = self.bounds;
    self.layer1.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}
- (void)wave {
    
    if (self.animation) return;
    self.animation = true;
    
    [self startAnimationWithShape:self.layer1];
    [self startAnimationWithShape:self.layer2];
    [self startAnimationWithShape:self.layer3];
    
}
- (void)stopWave {
    
    if (!self.animation) return;
    self.animation = false;
    
    [self pauseAnimationWithShape:self.layer1];
    [self pauseAnimationWithShape:self.layer2];
    [self pauseAnimationWithShape:self.layer3];
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

- (void)getAnimationAction:(CALayer *)layer {
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim.duration = 2.5; // 动画持续时间
    anim.repeatCount = CGFLOAT_MAX; // 重复次数
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    
    anim.fromValue = @0.3;
    anim.toValue = @1;
    
    layer.speed = 0;
    [layer addAnimation:anim forKey:@"scaleAnimation"];
}

- (CALayer *)layer1 {
    
    if (!_layer1) {
        _layer1 = [CALayer layer];
        
        _layer1.backgroundColor = [UIColor colorWithRed:0x84 green:0x96 blue:0xFF alpha:0.68].CGColor;
        _layer1.backgroundColor = [UIColor redColor].CGColor;
        [self getAnimationAction:_layer1];
    }
    return _layer1;
}
- (CALayer *)layer2 {
    
    if (!_layer2) {
        _layer2 = [CALayer layer];
        
        _layer2.backgroundColor = [UIColor colorWithRed:0x76 green:0x89 blue:0xFC alpha:0.68].CGColor;
        [self getAnimationAction:_layer2];
    }
    return _layer2;
}
- (CALayer *)layer3 {
    
    if (!_layer3) {
        _layer3 = [CALayer layer];
        
        _layer3.backgroundColor = [UIColor colorWithRed:0x6E green:0x83 blue:0xFF alpha:0.68].CGColor;
        [self getAnimationAction:_layer3];
    }
    return _layer3;
}

@end
