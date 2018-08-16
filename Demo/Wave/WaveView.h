//
//  WaveView.h
//  Demo
//
//  Created by sword on 2017/7/21.
//  Copyright © 2017年 Sword. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaveView : UIView

@property (strong, nonatomic) UIColor *waveColor;
@property (assign, nonatomic) CGFloat waveHeight;
@property (assign, nonatomic) CGFloat speed;
@property (assign, nonatomic) CGFloat originHeight;

@property (readonly) BOOL waving;

- (void)wave;
- (void)stopWave;

@end
