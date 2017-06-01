//
//  BannerShufflingSV.h
//  Demo
//
//  Created by sword on 2017/6/1.
//  Copyright © 2017年 Sword. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BannerShufflingSVType) {
    kBannerShufflingSVNormal,
    kBannerShufflingSVCorridor
};

typedef NS_ENUM(NSInteger, BannerShufflingViewSlideState) {
    kBannerShufflingViewSlidePrepare,
    kBannerShufflingViewSlideSliding,
    kBannerShufflingViewSlideStop
};
#define MAX_VIEW_NUM 5

//抽象类
@interface BannerShufflingSV : UIScrollView

+ (BannerShufflingSV *)bannerSVWithType:(BannerShufflingSVType)type loadImage:(void(^)(UIImageView *, NSInteger row))loadImageBlock clickImage:( void(^)(NSInteger index))clickBlock;

@property (nonatomic, assign) NSInteger row;

@property (copy, nonatomic) void(^clickImageBlock)(NSInteger index);
@property (copy, nonatomic) void(^loadImageBlock)(UIImageView *imageView, NSInteger row);
@property (copy, nonatomic) void(^rowDidChange)(NSInteger row);

- (void)startScroll;
- (void)stopScroll;


@end
