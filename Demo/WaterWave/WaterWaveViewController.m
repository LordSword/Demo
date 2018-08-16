//
//  WaterWaveViewController.m
//  Demo
//
//  Created by sword on 2017/7/21.
//  Copyright © 2017年 Sword. All rights reserved.
//

#import "WaterWaveViewController.h"

#import "WaterWaveView.h"

@interface WaterWaveViewController ()

@property (strong, nonatomic) WaterWaveView *waterWaveView;
@property (strong, nonatomic) UIButton *controlWave;

@end

@implementation WaterWaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.waterWaveView];
    [self.view addSubview:self.controlWave];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.waterWaveView.center = self.view.center;
    
    self.controlWave.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetMaxY(self.waterWaveView.frame) + 30);
}


- (void)changeWaveStatus {
    
    if (self.waterWaveView.isAnimation) {
        [self.waterWaveView stopWave];
    } else {
        [self.waterWaveView wave];
    }
}

- (WaterWaveView *)waterWaveView {
    
    if (!_waterWaveView) {
        _waterWaveView = [[WaterWaveView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        
        _waterWaveView.originColor = [UIColor redColor];
    }
    return _waterWaveView;
}
- (UIButton *)controlWave {
    
    if (!_controlWave) {
        _controlWave = [[UIButton alloc] init];
        
        [_controlWave setTitle:@"stop/start" forState:UIControlStateNormal];
        [_controlWave setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_controlWave addTarget:self action:@selector(changeWaveStatus) forControlEvents:UIControlEventTouchUpInside];
        
        [_controlWave sizeToFit];
    }
    return _controlWave;
}

@end
