//
//  BannerShufflingView.h
//  YuanXin_Project
//
//  Created by Sword on 15/9/15.
//  Copyright (c) 2015年 yuanxin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BannerShufflingSV.h"

@class BannerShufflingView;

@protocol BannerShufflingViewDataSource  <NSObject>

- (void)imageLoop:(BannerShufflingView *)scrollView visiableImageView:(UIImageView *)imageView imageForRow:(NSInteger)row complete:(void(^)(NSString *imagePath, UIImage *))complete;
- (NSInteger)imageLoopNumberOfRow:(BannerShufflingView *)scrollView;
@end

@interface BannerShufflingView : UIView

- (instancetype)initWithFrame:(CGRect)frame contentType:(BannerShufflingSVType)type;

@property (nonatomic, weak) IBOutlet id<BannerShufflingViewDataSource> dataSource;
@property (copy, nonatomic, readwrite) void(^clickBlock)(BannerShufflingView *bannerView, NSInteger imageIndex);

- (void)reloadData;

- (void)startScroll;
- (void)stopScroll;

@end
