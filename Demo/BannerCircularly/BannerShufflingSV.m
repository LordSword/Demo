//
//  BannerShufflingSV.m
//  Demo
//
//  Created by sword on 2017/6/1.
//  Copyright © 2017年 Sword. All rights reserved.
//

#import "BannerShufflingSV.h"

#import "TimerIntermediary.h"

#import <objc/runtime.h>

#define REPEAT_TIME 5.0f
#define MAX_VIEW_NUM 5
#define Image_Min_Scale 0.95

#define Image_Path_Key @"imagePath"
#define NoImage_Tag  -1
#define Image_Offset 100

@interface UIImageView(UndefinedKey)

@property (strong, nonatomic, readonly) NSMutableDictionary *customUndefinedValues;

@end

@implementation UIImageView(UndefinedKey)

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    [self.customUndefinedValues setValue:value forKey:key];
}
- (id)valueForUndefinedKey:(NSString *)key {
    
    return [self.customUndefinedValues valueForKey:key];
}

- (NSMutableDictionary *)customUndefinedValues {
    
    if (!objc_getAssociatedObject(self, _cmd)) {
        objc_setAssociatedObject(self, _cmd, [[NSMutableDictionary alloc] init], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return objc_getAssociatedObject(self, _cmd);
}

@end



@interface BannerShufflingSV ()

@property (nonatomic, assign, readwrite) BannerShufflingSVType type;
@property (nonatomic, assign, readwrite) BannerShufflingViewSlideState slideState;

@property (nonatomic, strong) NSMutableArray<UIImageView *> *allImageViews;   /**< 所有的imageView 当imageView.tag = -1 时 为默认图片或无图 */
@property (nonatomic, strong, readwrite) NSMutableArray *visiableImageViews;    /**< 当前页面可见的imageView */
@property (nonatomic, assign, readonly) CGRect visiableRect;                    /**< 可见的Rect */
@property (atomic, assign, readwrite) NSInteger currentRow;                  /**< 整个dataSource 的 row */

@property (strong, nonatomic, readwrite) TimerIntermediary *timerIntermediary;

@property (assign, nonatomic) BOOL didTouch;

@end

@interface BannerShufflingSV (delegate) <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation BannerShufflingSV
@synthesize currentRow = _currentRow;

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        _didTouch                           = NO;
        self.delegate                       = self;
        self.panGestureRecognizer.delegate  = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator   = NO;
        self.bounces                        = NO;
        self.pagingEnabled                  = YES;
//        self.decelerationRate               = 0.1f;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGSizeEqualToSize(self.bounds.size, CGSizeMake(self.contentSize.width/self.allImageViews.count, self.contentSize.height))) {
        return;
    }
    CGFloat imageWidth = [self widthOfImageView];

    for (NSInteger i = 0; i < self.allImageViews.count; ++i) {
        UIImageView *imageView = self.allImageViews[i];
        imageView.transform = CGAffineTransformMakeScale(1, 1);
        imageView.frame = CGRectMake(i*imageWidth, 0, imageWidth, CGRectGetHeight(self.bounds));
    }
    self.contentSize = CGSizeMake(self.allImageViews.count*imageWidth, CGRectGetHeight(self.bounds));
    [self resetImageViewOffset:0];
}

#pragma mark - Public
+ (BannerShufflingSV *)bannerSVWithType:(BannerShufflingSVType)type loadImage:(loadImageBlock)loadImageBlock clickImage:( void(^)(NSInteger index))clickBlock {
    BannerShufflingSV *result = [[BannerShufflingSV alloc] init];
    
    result.clipsToBounds = kBannerShufflingSVCorridor != type;
    result.type = type;
    result.loadImageBlock = loadImageBlock;
    result.clickImageBlock = clickBlock;
    result.contentInset = UIEdgeInsetsZero;
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
- (void)scrollToIndex:(NSInteger)index {
    NSInteger realIndex = MIN(self.allImageViews.count - 1, MAX(0, index));
    
    //这个方法在快速滑动时将无法重置位置
    [self setContentOffset:CGPointMake(realIndex*[self widthOfImageView], 0) animated:YES];
}

#pragma mark - Private
- (NSInteger)convertIndexToRow:(NSInteger)index {
    if (0 == self.row) return 0;
    
    NSInteger offset = index - self.allImageViews.count/2;
    
    return (self.currentRow + offset + self.row)%self.row; //防止负数%
}

- (void)resetImageViewOffset:(CGFloat)offset {
    if (0 == self.row || 0 == [self widthOfImageView]) return;
    
    self.currentRow = (self.currentRow + (NSInteger)offset + self.row)%self.row;
    
    CGFloat xOffset = 0;
//    if (self.isDecelerating && !self.isTracking && self.isDragging) {
        xOffset = self.contentOffset.x - self.allImageViews.count/2*[self widthOfImageView];
        while (fabs(xOffset) >= [self widthOfImageView]) {
            if (xOffset > 0) {
                xOffset -= [self widthOfImageView];
            } else {
                xOffset += [self widthOfImageView];
            }
        }
//    }
    self.contentOffset = CGPointMake(self.allImageViews.count/2*[self widthOfImageView] + xOffset, 0);

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
        CGFloat changedRate = fabs(offset)/[self widthOfImageView]*(1 - Image_Min_Scale);
        currentImageView.transform = CGAffineTransformMakeScale(1 - changedRate, 1 - changedRate);
        nextImageView.transform = CGAffineTransformMakeScale(Image_Min_Scale + changedRate, Image_Min_Scale + changedRate);
    }
}
- (void)exchangeImageOfImageView {
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < self.allImageViews.count; ++i) {
        UIImageView *imageView = self.allImageViews[i];
        
        if (-1 != imageView.tag && [imageView valueForKey:Image_Path_Key]) {
            [tmpDic setValue:imageView.image forKey:@(imageView.tag).stringValue];
            [tmpDic setValue:[imageView valueForKey:Image_Path_Key] forKey:[NSString stringWithFormat:@"%@%@", Image_Path_Key, @(imageView.tag).stringValue]];
        }
    }
   
    for (int i = 0; i < self.allImageViews.count; ++i) {
        
        NSInteger rowOfImageView     = [self convertIndexToRow:i];
        UIImageView *imageView       = self.allImageViews[i];
        
        imageView.image = [tmpDic valueForKey:@(rowOfImageView+Image_Offset).stringValue];

        if (imageView.image ) {
            imageView.tag = rowOfImageView + Image_Offset;
            [imageView setValue:[tmpDic valueForKey:[NSString stringWithFormat:@"%@%@", Image_Path_Key, @(rowOfImageView+Image_Offset).stringValue]] forKey:Image_Path_Key];
        } else {
            imageView.tag = NoImage_Tag;
            [imageView setValue:nil forKey:Image_Path_Key];
            if ([self.visiableImageViews containsObject:imageView]) {
                [self loadImageForImageView:imageView];
            }
        }
    }
}

- (void)resetVisiableImage {
    
    for (int i = 0; i < self.allImageViews.count; ++i) {
        if (0 == self.row || CGSizeEqualToSize(CGSizeZero, self.bounds.size)) return;
        
        UIImageView *imageView = self.allImageViews[i];
        
        if ( CGRectIntersectsRect(imageView.frame, self.visiableRect) ) { //CGRectEqualToRect(imageView.frame, [self visiableRect])
            if ( ![self.visiableImageViews containsObject:imageView] ) {
                [self.visiableImageViews addObject:imageView];
                [self loadImageForImageView:imageView];
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
- (void)loadImageForImageView:(UIImageView *)imageView {
    if ( NoImage_Tag != imageView.tag && [imageView valueForKey:Image_Path_Key]) return;
    NSInteger row = [self convertIndexToRow:[self.allImageViews indexOfObject:imageView]];

    imageView.tag = row + Image_Offset;
    !self.loadImageBlock ? : self.loadImageBlock(imageView, row, ^(NSString *imagePath, UIImage *defaultImage){
        if ((row + Image_Offset) == imageView.tag) { //加载过程中位置会改变
            [imageView setValue:imagePath forKey:Image_Path_Key];
        } else if (![imageView valueForKey:Image_Path_Key]) { //位置改变后图片如果还是无图就赋值默认图片
            imageView.image = defaultImage;
        }
    });
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
    _row = row;
    
    [self addImageView:( 1 == self.row ? 1 : MAX_VIEW_NUM)];
    self.currentRow = 0;
    [self resetImageViewOffset:0];
    [self resetVisiableImage];
    
    if (1 == self.row) {
        [self stopScroll];
    } else {
        [self startScroll];
    }
}
- (void)removeImageView {
    
    [self.allImageViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [obj removeFromSuperview];
        });
    }];
    [self.allImageViews removeAllObjects];
}
- (void)addImageView:(NSInteger)count {
    [self.visiableImageViews removeAllObjects];
    
    [self removeImageView];
    self.scrollEnabled = 1 != count ? : NO;
    
    for (NSInteger i = 0; i < count; ++i) {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.tag = NoImage_Tag; //代表无图
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView:)];
        [imageView addGestureRecognizer:tapGesture];
        imageView.userInteractionEnabled = YES;
        [self.allImageViews addObject:imageView];
        [self addSubview:imageView];
    }
    self.contentSize = CGSizeZero; //重置大小
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
            
            [target scrollToIndex:target.allImageViews.count/2 + 1];
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
    
    @synchronized (self) {
        _currentRow = currentRow;
    }

    !self.rowDidChange ? : self.rowDidChange(currentRow);
}
- (NSInteger)currentRow {
    @synchronized (self) {
        return _currentRow;
    }
}
@end


@implementation BannerShufflingSV (delegate)
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    self.didTouch = YES;
    return YES;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.slideState = kBannerShufflingViewSlidePrepare;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.didTouch = NO;
    self.slideState = kBannerShufflingViewSlideSliding;
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    if (!self.didTouch) {
        self.contentOffset = CGPointMake(self.allImageViews.count/2*[self widthOfImageView], 0);
    }
}
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    
//    *targetContentOffset = scrollView.contentOffset;//CGPointMake([self widthOfImageView]*(NSInteger)(scrollView.contentOffset.x/[self widthOfImageView] + 0.5), scrollView.contentOffset.y);
//    [scrollView setContentOffset:CGPointMake([self widthOfImageView]*(NSInteger)(scrollView.contentOffset.x/[self widthOfImageView] + 0.5), scrollView.contentOffset.y) animated:true];
//}
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    
//    [self setContentOffset:CGPointMake([self widthOfImageView]*(NSInteger)(scrollView.contentOffset.x/[self widthOfImageView] + 0.5), scrollView.contentOffset.y) animated:true];
//}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offset = scrollView.contentOffset.x/[self widthOfImageView] - self.allImageViews.count/2;
    
    if (fabs(offset) >= 1) {
        
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
