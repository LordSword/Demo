//
//  WaterWaveView.h
//  Demo
//
//  Created by sword on 2017/7/21.
//  Copyright © 2017年 Sword. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaterWaveView : UIView

@property (assign, nonatomic, getter=isAnimation) BOOL animation;

- (void)wave;
- (void)stopWave;

@end
