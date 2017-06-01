//
//  BannerShufflingSV.m
//  Demo
//
//  Created by sword on 2017/6/1.
//  Copyright © 2017年 Sword. All rights reserved.
//

#import "BannerShufflingSV.h"

#import "TimerIntermediary.h"

#define REPEAT_TIME 5.0f
#define MAX_VIEW_NUM 5
#define Image_Offset 100
#define Image_Min_Scale 0.95

@interface BannerShufflingSV ()

@property (nonatomic, assign, readwrite) BannerShufflingSVType type;
@property (nonatomic, assign, readwrite) BannerShufflingViewSlideState slideState;
@property (assign, nonatomic) BOOL didLayout;

@property (nonatomic, strong) NSMutableArray<UIImageView *> *allImageViews;   /**< 所有的imageView */
@property (nonatomic, strong, readwrite) NSMutableArray *visiableImageViews;    /**< 当前页面可见的imageView */
@property (nonatomic, assign, readonly) CGRect visiableRect;                    /**< 可见的Rect */
@property (nonatomic, assign, readonly ) NSInteger currentIndex;                /**< 当前位置相对于整个view的 page index 点 */
@property (nonatomic, assign, readwrite) NSInteger currentRow;                  /**< 整个dataSource 的 row */

@property (strong, nonatomic, readwrite) TimerIntermediary *timerIntermediary;

@end

@interface BannerShufflingSV (delegate) <UIScrollViewDelegate>

@end

@implementation BannerShufflingSV
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.delegate                       = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator   = NO;
        self.bounces                        = NO;
        self.pagingEnabled                  = YES;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.didLayout /*&& !CGSizeEqualToSize(CGSizeZero, self.allImageViews.firstObject.bounds.size)*/ || CGSizeEqualToSize(CGSizeZero, self.bounds.size)) return;
    
    self.didLayout = YES;
    CGFloat imageWidth = [self widthOfImageView];
    for (NSInteger i = 0; i < self.allImageViews.count; ++i) {
        UIImageView *imageView = self.allImageViews[i];
        imageView.frame = CGRectMake(i*imageWidth, 0, imageWidth, CGRectGetHeight(self.bounds));
    }
    self.contentSize = CGSizeMake(self.allImageViews.count*imageWidth, CGRectGetHeight(self.bounds));
    [self resetImageViewOffset:0];
}

#pragma mark - Public
+ (BannerShufflingSV *)bannerSVWithType:(BannerShufflingSVType)type loadImage:(void(^)(UIImageView *, NSInteger row))loadImageBlock clickImage:( void(^)(NSInteger index))clickBlock {
    BannerShufflingSV *result = [[BannerShufflingSV alloc] init];
    
    result.clipsToBounds = kBannerShufflingSVCorridor != type;
    result.type = type;
    result.loadImageBlock = loadImageBlock;
    result.clickImageBlock = clickBlock;
    return result;
}
- (void)startScroll {
    self.slideState = kBannerShufflingViewSlideSliding;
}
- (void)stopScroll {
    self.slideState = kBannerShufflingViewSlideStop;
}

- (CGFloat)widthOfImageView {
    return CGRectGetWidth(self.bounds);
}
- (void)scrollToIndex:(NSInteger)index offset:(CGFloat)offset animated:(BOOL)animated {
    NSInteger realIndex = MIN(self.allImageViews.count - 1, MAX(0, index));
    
    [self setContentOffset:CGPointMake(realIndex*[self widthOfImageView] + offset, 0) animated:animated];
}

#pragma mark - Private
- (NSInteger)convertIndexToRow:(NSInteger)index {
    if (0 == self.row) return 0;
    
    NSInteger offset = index - self.allImageViews.count/2;
    
    return (self.currentRow + offset + self.row)%self.row; //防止负数%
}

- (void)resetImageViewOffset:(NSInteger)offset {
    if (0 == self.row) return;
    self.currentRow = (self.currentRow + offset + self.row)%self.row;

    CGFloat xOffset = 0;
    if (self.isTracking) {
        xOffset = self.contentOffset.x - [self widthOfImageView];
        while (fabs(xOffset) >= [self widthOfImageView] && [self widthOfImageView] > 0) {
            if (xOffset > 0) {
                xOffset -= [self widthOfImageView];
            } else {
                xOffset += [self widthOfImageView];
            }
        }
    }
    [self scrollToIndex:self.allImageViews.count/2 offset:xOffset animated:NO];
    
    if (kBannerShufflingSVCorridor == self.type) {
        [self resetImageViewScale];
    }
}
- (void)resetImageViewScale {
    
    for (NSInteger i = 0; i < self.allImageViews.count; ++i) {
        UIImageView *imageView = self.allImageViews[i];
        
        CGFloat scale = self.allImageViews.count/2 == i ? 1 : Image_Min_Scale;
        imageView.transform = CGAffineTransformMakeScale( scale, scale);
    }
}
- (void)changeShowImageViewScale {
    
    if (self.contentOffset.x == self.allImageViews[self.allImageViews.count/2].frame.origin.x) return;//没有滑动
    
    UIImageView *currentImageView = self.allImageViews[self.allImageViews.count/2];

    CGFloat offset = self.contentOffset.x - currentImageView.frame.origin.x;
    
    NSInteger nextIndexOfImage = self.allImageViews.count/2 + (offset < 0 ? -1 : 1);//向左-1 向右1
    nextIndexOfImage = MAX(0, MIN(self.allImageViews.count - 1, nextIndexOfImage));
    
    UIImageView *nextImageView = self.allImageViews[nextIndexOfImage];
    if (nextImageView != currentImageView) {
        CGFloat changedRate = offset/[self widthOfImageView]*(1 - Image_Min_Scale);
        currentImageView.transform = CGAffineTransformMakeScale(1 - changedRate, 1 - changedRate);
        nextImageView.transform = CGAffineTransformMakeScale(Image_Min_Scale + changedRate, Image_Min_Scale + changedRate);
    }
}
- (void)exchangeImageOfImageView {
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < self.allImageViews.count; ++i) {
        UIImageView *imageView       = self.allImageViews[i];
        [tmpDic setValue:imageView.image forKey:@(imageView.tag).stringValue];
    }
   
    for (int i = 0; i < self.allImageViews.count; ++i) {
        
        NSInteger rowOfImageView     = [self convertIndexToRow:i];
        UIImageView *imageView       = self.allImageViews[i];
        
        imageView.image = [tmpDic valueForKey:@(rowOfImageView + Image_Offset).stringValue];
        imageView.tag = rowOfImageView + Image_Offset;

        if (!imageView.image && [self.visiableImageViews containsObject:imageView]) {
            !self.loadImageBlock ? : self.loadImageBlock(imageView, rowOfImageView);
        }
    }
}

- (void)resetVisiableImage {
    
    for (int i = 0; i < self.allImageViews.count; ++i) {
        if (CGSizeEqualToSize(CGSizeZero, self.bounds.size)) return;
        
        UIImageView *imageView = self.allImageViews[i];
        
        if ( CGRectIntersectsRect(imageView.frame, self.visiableRect) ) { //CGRectEqualToRect(imageView.frame, [self visiableRect])
            if ( ![self.visiableImageViews containsObject:imageView] ) {
                [self.visiableImageViews addObject:imageView];
                
                NSInteger row = [self convertIndexToRow:[self.allImageViews indexOfObject:imageView]];
                !self.loadImageBlock ? : self.loadImageBlock(imageView, row);
                imageView.tag = row + Image_Offset;
            }
        } else {
            [self.visiableImageViews removeObject:imageView];
        }
    }
}
- (CGRect)visiableRect {
    CGRect result = CGRectMake(self.contentOffset.x, self.contentOffset.y, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    if (kBannerShufflingSVCorridor == self.type) {
        result.origin.x -= 15;
        result.size.width += 30;
    }
    
    return result;
}

- (void)clickImageView:(UITapGestureRecognizer *)tapGesture {
    
    if ([self.allImageViews containsObject:(UIImageView *)tapGesture.view]) {
        
        if (self.clickImageBlock) {
            self.clickImageBlock(self.currentRow);
        }
    }
}

#pragma mark - Setter
- (void)setSlideState:(BannerShufflingViewSlideState)slideState {
    if (_slideState == slideState) {
        return;
    }
    if (1 == self.allImageViews.count || !self.allImageViews.count) {
        _slideState = kBannerShufflingViewSlidePrepare;
        return;
    }
    _slideState = slideState;
    
    switch (slideState) {
        case kBannerShufflingViewSlidePrepare:
            [self.timerIntermediary stop];
            break;
        case kBannerShufflingViewSlideSliding:
            [self.timerIntermediary startWithDate:[NSDate dateWithTimeIntervalSinceNow:REPEAT_TIME]];
            break;
        case kBannerShufflingViewSlideStop:
            [self.timerIntermediary stop];
            break;
    }
}
- (void)setRow:(NSInteger)row {
    if (_row == row) return;
    _row = row;
    
    [self removeImageView];
    [self addImageView:( 1 == self.row ? 1 : MAX_VIEW_NUM)];
    if (1 == self.row) {
        [self stopScroll];
    } else {
        [self startScroll];
    }
    self.currentRow = 0;
    [self resetVisiableImage];
}
- (void)removeImageView {
    
    [self.allImageViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.allImageViews removeAllObjects];
    [self.visiableImageViews removeAllObjects];
}
- (void)addImageView:(NSInteger)count {
    
    self.scrollEnabled = 1 != count ? : NO;
    
    for (NSInteger i = 0; i < count; ++i) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = i;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView:)];
        [imageView addGestureRecognizer:tapGesture];
        imageView.userInteractionEnabled = YES;
        [self.allImageViews addObject:imageView];
        [self addSubview:imageView];
    }
    [self layoutIfNeeded];
}

#pragma mark - Getter
- (NSMutableArray *)allImageViews {
    
    if (!_allImageViews) {
        _allImageViews = [[NSMutableArray alloc] init];
    }
    return _allImageViews;
}
- (TimerIntermediary *)timerIntermediary {
    
    if (!_timerIntermediary) {
        _timerIntermediary = [TimerIntermediary timerIntermediaryWithTimeInterval:REPEAT_TIME target:self action:^(TimerIntermediary *intermediary, BannerShufflingSV *target) {
            
            [target scrollToIndex:3 offset:0 animated:YES];
        } userInfo:nil repeats:YES];
    }
    return _timerIntermediary;
}
- (NSMutableArray *)visiableImageViews {
    
    if (!_visiableImageViews) {
        _visiableImageViews = [[NSMutableArray alloc] init];
    }
    return _visiableImageViews;
}

- (void)setCurrentRow:(NSInteger)currentRow {
    _currentRow = currentRow;

    !self.rowDidChange ? : self.rowDidChange(currentRow);
}
@end


@implementation BannerShufflingSV (delegate)

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.slideState = kBannerShufflingViewSlidePrepare;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.slideState = kBannerShufflingViewSlideSliding;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offset = scrollView.contentOffset.x/[self widthOfImageView] - self.allImageViews.count/2;
    
    if ( fabs(offset) >= 1) {
        
        [self resetImageViewOffset:offset];
        [self exchangeImageOfImageView];
    } else {
        [self resetVisiableImage];
    }
    if (kBannerShufflingSVCorridor == self.type) {
        [self changeShowImageViewScale];
    }
}

@end
