//
//  TestLoadingViewController.m
//  Demo
//
//  Created by sword on 2017/9/7.
//  Copyright © 2017年 Sword. All rights reserved.
//

#import "TestLoadingViewController.h"

#import "LoadingButton.h"

@interface TestLoadingViewController ()

@property (weak, nonatomic) IBOutlet LoadingButton *loadingButton;
@end

@implementation TestLoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
}
- (IBAction)setButtonToLoading:(UIButton *)sender {
    
    self.loadingButton.loading = YES;
}
- (IBAction)stopLoadingForButton:(UIButton *)sender {
    
    self.loadingButton.loading = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
