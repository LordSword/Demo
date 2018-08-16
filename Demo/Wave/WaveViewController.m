//
//  WaveViewController.m
//  Demo
//
//  Created by sword on 2017/7/21.
//  Copyright © 2017年 Sword. All rights reserved.
//

#import "WaveViewController.h"

#import "WaveView.h"

@interface WaveViewController ()

@property (strong, nonatomic) WaveView *waveView;

@property (strong, nonatomic) UIButton *controlWave;

@end

@implementation WaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.waveView];
    [self.view addSubview:self.controlWave];
    [self.waveView wave];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.waveView.frame = CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds));
    self.waveView.layer.cornerRadius = CGRectGetWidth(self.view.bounds)/2;
    self.waveView.layer.masksToBounds = YES;
    self.controlWave.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, 340);
}

- (void)changeWaveStatus {
    
    if (self.waveView.waving) {
        [self.waveView stopWave];
    } else {
        [self.waveView wave];
    }
}


- (WaveView *)waveView {
    
    if (!_waveView) {
        _waveView = [[WaveView alloc] init];
        
        _waveView.waveHeight = 8;
        _waveView.speed = 5;
        _waveView.originHeight = 160;
        _waveView.waveColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
    }
    return _waveView;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
