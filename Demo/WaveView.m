//
//  WaveView.m
//  Demo
//
//  Created by sword on 2017/7/21.
//  Copyright © 2017年 Sword. All rights reserved.
//

#import "WaveView.h"

@interface WaveView()

@property (strong, nonatomic) CADisplayLink *link;

@property (strong, nonatomic) CAShapeLayer *layer1;
@property (strong, nonatomic) CAShapeLayer *layer2;

@property (assign, nonatomic) CGFloat offset;

@end

@implementation WaveView

@synthesize waveColor = _waveColor;

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self.layer addSublayer:self.layer1];
        [self.layer addSublayer:self.layer2];
    }
    return self;
}

- (void)wave {
    
    self.link.paused = NO;
}
- (void)stopWave {
    
    self.link.paused = YES;
}
- (BOOL)waving {
    
    return !self.link.paused;
}

- (void)doAni {
    
    if (0 == self.speed) return;
    
    self.offset += self.speed;
    //设置第一条波曲线的路径
    CGMutablePathRef pathRef = CGPathCreateMutable();
    //起始点
    CGFloat startY = self.waveHeight*sinf(self.offset*M_PI/CGRectGetWidth(self.bounds));
    CGPathMoveToPoint(pathRef, NULL, 0, startY);
    //第一个波的公式
    for (CGFloat i = 0.0; i <= CGRectGetWidth(self.bounds); i ++) {
        CGFloat y = 1.1*self.waveHeight*sinf(2*M_PI*i/CGRectGetWidth(self.bounds) + self.offset*M_PI/CGRectGetWidth(self.bounds)) + ( CGRectGetHeight(self.bounds) - self.originHeight);
        CGPathAddLineToPoint(pathRef, NULL, i, y);
    }
    CGPathAddLineToPoint(pathRef, NULL, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    CGPathAddLineToPoint(pathRef, NULL, 0, CGRectGetHeight(self.bounds));
    CGPathCloseSubpath(pathRef);
    //设置第一个波layer的path
    self.layer1.path = pathRef;
    CGPathRelease(pathRef);
    
    //设置第二条波曲线的路径
    CGMutablePathRef pathRef2 = CGPathCreateMutable();
    CGFloat startY2 = self.waveHeight*sinf(self.offset*M_PI/CGRectGetWidth(self.bounds) + M_PI/4);
    CGPathMoveToPoint(pathRef2, NULL, 0, startY2);
    //第二个波曲线的公式
    for (CGFloat i = 0.0; i <= CGRectGetWidth(self.bounds); i ++) {
        CGFloat y = self.waveHeight*sinf(2*M_PI*i/CGRectGetWidth(self.bounds) + 3*self.offset*M_PI/CGRectGetWidth(self.bounds) + M_PI/4) + ( CGRectGetHeight(self.bounds) - self.originHeight);
        CGPathAddLineToPoint(pathRef2, NULL, i, y);
    }
    CGPathAddLineToPoint(pathRef2, NULL, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    CGPathAddLineToPoint(pathRef2, NULL, 0, CGRectGetHeight(self.bounds));
    CGPathCloseSubpath(pathRef2);
    
    self.layer2.path = pathRef2;
    self.layer2.fillColor = self.waveColor.CGColor;
    CGPathRelease(pathRef2);
}

#pragma mark - Setter
- (void)setWaveColor:(UIColor *)waveColor {
    _waveColor = waveColor;
    
    self.layer1.fillColor = [waveColor colorWithAlphaComponent:0.8].CGColor;
    self.layer2.fillColor = waveColor.CGColor;
}

#pragma mark -Getter
- (CADisplayLink *)link {
    
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(doAni)];
        [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        _link.paused = YES;
    }
    return _link;
}

- (CAShapeLayer *)layer1 {
    
    if (!_layer1) {
        _layer1 = [CAShapeLayer layer];
    }
    return _layer1;
}
- (CAShapeLayer *)layer2 {
    
    if (!_layer2) {
        _layer2 = [CAShapeLayer layer];
    }
    return _layer2;
}

- (UIColor *)waveColor {
    
    if (!_waveColor) {
        _waveColor = [UIColor lightGrayColor];
    }
    return _waveColor;
}

@end
