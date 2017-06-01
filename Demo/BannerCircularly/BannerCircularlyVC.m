//
//  BannerCircularlyVC.m
//  Demo
//
//  Created by sword on 2017/5/31.
//  Copyright © 2017年 Sword. All rights reserved.
//

#import "BannerCircularlyVC.h"
#import "BannerShufflingView.h"

@interface BannerCircularlyVC () <BannerShufflingViewDataSource>

@property (strong, nonatomic) NSArray *bannerNames;

@property (strong, nonatomic) BannerShufflingView *bannerView;

@end

@implementation BannerCircularlyVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bannerView];
    self.bannerView.dataSource = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)imageLoopNumberOfRow:(BannerShufflingView *)scrollView {
    return self.bannerNames.count;
}
- (void)imageLoop:(BannerShufflingView *)scrollView visiableImageView:(UIImageView *)imageView imageForRow:(NSInteger)row {
    NSLog(@"-----%@", @(row));
    imageView.image = [UIImage imageNamed:self.bannerNames[row]];
}

- (NSArray<NSString *> *)bannerNames {
    
    if (!_bannerNames) {
        _bannerNames = @[@"banner2", @"banner1", @"banner3", @"banner4", @"banner5"];
    }
    return _bannerNames;
}
- (BannerShufflingView *)bannerView {
    
    if (!_bannerView) {
        _bannerView = [[BannerShufflingView alloc] initWithFrame:CGRectMake(0, 200, 375, 200) contentType:kBannerShufflingSVCorridor];
    }
    return _bannerView;
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
