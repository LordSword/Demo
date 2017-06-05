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
@property (strong, nonatomic) BannerShufflingView *bannerView1;

@end

@implementation BannerCircularlyVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view layoutIfNeeded];
    
    [self.view addSubview:self.bannerView1];
    [self.view addSubview:self.bannerView];
    self.bannerView.dataSource = self;
    self.bannerView1.dataSource = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)imageLoopNumberOfRow:(BannerShufflingView *)scrollView {
    return self.bannerNames.count;
}
- (void)imageLoop:(BannerShufflingView *)scrollView visiableImageView:(UIImageView *)imageView imageForRow:(NSInteger)row complete:(void(^)(NSString *imagePath))complete {
    NSLog(@"-----%@", @(row));
    imageView.image = [UIImage imageNamed:self.bannerNames[row]];
    
    !complete ? : complete(self.bannerNames[row]);
}

- (NSArray<NSString *> *)bannerNames {
    
    if (!_bannerNames) {
        _bannerNames = @[ @"banner5", @"banner4", @"banner2"];
    }
    return _bannerNames;
}
- (BannerShufflingView *)bannerView {
    
    if (!_bannerView) {
        _bannerView = [[BannerShufflingView alloc] initWithFrame:CGRectMake(0, 350, 375, 200) contentType:kBannerShufflingSVCorridor];
    }
    return _bannerView;
}
- (BannerShufflingView *)bannerView1 {
    if (!_bannerView1) {
        _bannerView1 = [[BannerShufflingView alloc] initWithFrame:CGRectMake(0, 100, 375, 200) contentType:kBannerShufflingSVNormal];
    }
    return _bannerView1;
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
