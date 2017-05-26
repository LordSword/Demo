//
//  BannerShufflingView.h
//  YuanXin_Project
//
//  Created by Sword on 15/9/15.
//  Copyright (c) 2015年 yuanxin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BannerShufflingViewSlideState) {
    kBannerShufflingViewSlidePrepare,
    kBannerShufflingViewSlideSliding,
    kBannerShufflingViewSlideStop
};

@class BannerShufflingView;

@protocol BannerShufflingViewDataSource  <NSObject>

- (void)imageLoop:(BannerShufflingView *)scrollView visiableImageView:(UIImageView *)imageView imageForRow:(NSInteger)row;
- (NSInteger)imageLoopNumberOfRow:(BannerShufflingView *)scrollView;
@end

@interface BannerShufflingView : UIView

@property (nonatomic, weak) IBOutlet id<BannerShufflingViewDataSource> dataSource;

@property (nonatomic, assign, readonly) BannerShufflingViewSlideState slideState;
@property (nonatomic, strong, readonly) NSMutableArray *visiableImageViews;/**< 当前页面可见的imageView */
@property (nonatomic, assign, readonly) NSInteger currentRow;             /**< 整个dataSource 的 row */

- (void)reloadData;

- (void)startScroll;
- (void)stopScroll;

- (void)setClickImageView:( void(^)(BannerShufflingView *loopView, NSInteger index))clickBlock;

@end
