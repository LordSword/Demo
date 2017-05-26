//
//  BannerShufflingView.m
//  YuanXin_Project
//
//  Created by Sword on 15/9/15.
//  Copyright (c) 2015年 yuanxin. All rights reserved.
//

#import "BannerShufflingView.h"
#import "TimerIntermediary.h"

#define REPEAT_TIME 5.0f

@interface BannerShufflingView() <UIScrollViewDelegate>

@property (nonatomic, assign, readwrite) BannerShufflingViewSlideState slideState;

@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *allImageViews;                    /**< 所有的imageView */
@property (nonatomic, strong, readwrite) NSMutableArray *visiableImageViews;    /**< 当前页面可见的imageView */
@property (nonatomic, assign, readwrite) NSInteger      currentRow;             /**< 整个dataSource 的 row */
@property (nonatomic, assign, readonly ) NSInteger      currentIndex;           /**< 当前位置相对于整个view的 page index 点 */
@property (nonatomic, assign, readonly ) CGRect         visiableRect;           /**< 可见的Rect */
@property (nonatomic, assign) NSInteger row;

@property (strong, nonatomic, readwrite) TimerIntermediary *timerIntermediary;

@property (copy, nonatomic, readwrite) void(^clickBlock)(BannerShufflingView *, NSInteger);
@end


#define MAX_VIEW_NUM 5

@implementation BannerShufflingView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self initializeBannerShuffingView];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initializeBannerShuffingView];
}

- (void)initializeBannerShuffingView {
    [self addSubview:self.contentView];
    [self addSubview:self.pageControl];
    
    _row = 1;
    [self setNeedsUpdateConstraints];
    
//    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] subscribeNext:^(id x) {
//        if (kBannerShufflingViewSlidePrepare == self.slideState) {
//            self.slideState = kBannerShufflingViewSlideSliding;
//        }
//    }];
//    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillResignActiveNotification object:nil] subscribeNext:^(id x) {
//        self.slideState = kBannerShufflingViewSlidePrepare;
//    }];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    if (self.contentView.translatesAutoresizingMaskIntoConstraints) {
        self.contentView.translatesAutoresizingMaskIntoConstraints = self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSArray *contentH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_contentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentView)];
        NSArray *contentV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_contentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentView)];
        [self addConstraints:contentH];
        [self addConstraints:contentV];
        
        NSArray *pageH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_pageControl]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_pageControl)];
        NSArray *pageV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageControl]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_pageControl)];
        [self addConstraints:pageH];
        [self addConstraints:pageV];
    }
}
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if ( self.allImageViews.count && !CGSizeEqualToSize([self.allImageViews.firstObject bounds].size, self.contentView.bounds.size) ) {
        for (UIImageView *imageView in self.allImageViews) {
            
            if ( [imageView isKindOfClass:[UIImageView class]] ) {
                imageView.frame = CGRectMake(imageView.tag*self.contentView.bounds.size.width, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
            }
        }
        self.contentView.contentSize = CGSizeMake(self.allImageViews.count*self.contentView.bounds.size.width, self.contentView.bounds.size.height);
        if ( 1 != self.allImageViews.count)
            self.contentView.contentOffset = CGPointMake(self.allImageViews.count/2*self.contentView.bounds.size.width, 0);
    }
}


#pragma mark - delegate

#pragma mark - transfer UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.slideState = kBannerShufflingViewSlidePrepare;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.slideState = kBannerShufflingViewSlideSliding;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offset = scrollView.contentOffset.x/scrollView.bounds.size.width;
    CGFloat err = 0;
//    if (!CGRectEqualToRect(CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.width, scrollView.height), CGRectMake(MAX_VIEW_NUM/2*scrollView.width, 0, scrollView.width, scrollView.height))
//        && (int)offset - offset == err) { //不为中心 和 整数
    
    if ((int)offset - offset == err) {
        
        self.currentRow = [self convertIndexToRow:[self currentIndex]];
    } else {
        
        if (self.superview && self.row) {
            [self applyForVisiable];
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentRow = [self convertIndexToRow:[self currentIndex]];
}


#pragma mark - public
- (void)setClickImageView:( void(^)(BannerShufflingView *loopView, NSInteger index))clickBlock {
    
    self.clickBlock = clickBlock;
}

- (void)startScroll {
    
//    if (1 == self.allImageViews.count || !self.allImageViews.count) return;
//    [self.timerIntermediary startWithDate:[NSDate dateWithTimeIntervalSinceNow:REPEAT_TIME]];
    self.slideState = kBannerShufflingViewSlideSliding;
}
- (void)stopScroll {
    
//    if (resetOffset) {
//        [self.contentView setContentOffset:CGPointMake(self.currentIndex*self.width, 0) animated:NO];
//        self.sliding = NO;
//    }
    self.slideState = kBannerShufflingViewSlideStop;
//    [self.timerIntermediary stop];
}
- (void)reloadData {
    
    self.dataSource = _dataSource;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    self.currentRow = 0;
}

#pragma mark - private method
- (void)applyForVisiable {
    
    for (int i = 0; i < self.allImageViews.count; ++i) {
        
        UIImageView *imageView = self.allImageViews[i];
        
        if ( CGRectIntersectsRect(imageView.frame, self.visiableRect) ) { //CGRectEqualToRect(imageView.frame, [self visiableRect])
            
            if ( ![self.visiableImageViews containsObject:imageView] ) {
                
                [self.visiableImageViews addObject:imageView];
                if ( [self.dataSource respondsToSelector:@selector(imageLoop:visiableImageView:imageForRow:)] ) {
                    
                    [self.dataSource imageLoop:self visiableImageView:imageView imageForRow:[self convertIndexToRow:imageView.tag]];
                }
            }
        } else {
            [self.visiableImageViews removeObject:imageView];
        }
    }
}
- (void)scrollToNextPage {
    if (self.contentView.contentOffset.x < self.contentView.contentSize.width - CGRectGetWidth(self.frame)) {
        [self.contentView setContentOffset:CGPointMake((NSInteger)(self.contentView.contentOffset.x/CGRectGetWidth(self.frame) + 1)*CGRectGetWidth(self.frame), 0) animated:YES];
    }
}
- (NSInteger)convertIndexToRow:(NSInteger)index {
    
    NSInteger offset = index - self.allImageViews.count/2;
    
    return (self.currentRow + offset + self.row)%self.row; //防止负数%
}
- (void)addImageView:(NSInteger)count {
    
    self.contentView.scrollEnabled = 1 != count ? : NO;
    
    [self.allImageViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.allImageViews removeAllObjects];
    for (NSInteger i = 0; i < count; ++i) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = i;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView:)];
        [imageView addGestureRecognizer:tapGesture];
        imageView.userInteractionEnabled = YES;
        [self.allImageViews addObject:imageView];
        [self.contentView addSubview:imageView];
    }
}
- (void)clickImageView:(UITapGestureRecognizer *)tapGesture {
    
    if ([self.allImageViews containsObject:tapGesture.view]) {
        
        if (self.clickBlock) {
            __weak __typeof(self) wself = self;
            self.clickBlock(wself, [self convertIndexToRow:tapGesture.view.tag]);
        }
    }
}


#pragma mark - setter & getter
- (void)setDataSource:(id<BannerShufflingViewDataSource>)dataSource {
    
    _dataSource = dataSource;
    
    if ([dataSource respondsToSelector:@selector(imageLoopNumberOfRow:)]) {
        
        NSInteger delegateRow = [dataSource imageLoopNumberOfRow:self];
        if (self.row == delegateRow || delegateRow <= 0)  return;
        
        self.row = delegateRow;
    }
    if (self.superview && self.row) {
        [self applyForVisiable];
    }
}
- (void)setRow:(NSInteger)row {
    _row = row;
    
    [self addImageView:( 1 == self.row ? 1 : MAX_VIEW_NUM)];
    if (1 ==  self.row) {
        [self stopScroll];
    } else {
        [self startScroll];
    }
    self.pageControl.numberOfPages = row;
}

- (void)setCurrentRow:(NSInteger)currentRow {
    
    //调整视图的位置，将视图呈现在最中间
    NSInteger offset = self.currentIndex - self.allImageViews.count/2;
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < self.allImageViews.count; ++i) {
        
        NSInteger indexOffset        = (i + offset + MAX_VIEW_NUM)%MAX_VIEW_NUM;//防止负数%
        UIImageView *imageView       = self.allImageViews[i];
        UIImageView *offsetImageView = self.allImageViews[indexOffset];
        
        [tmpDic setValue:imageView.image forKey:[@(i) stringValue]];
        
        if ([tmpDic objectForKey:[@(indexOffset) stringValue]]) {

            imageView.image = tmpDic[[@(indexOffset) stringValue]];
        } else {
            imageView.image = offsetImageView.image;
        }
    }
    
    if (MAX_VIEW_NUM == self.allImageViews.count /* && ![self.visiableImageViews containsObject:self.allImageViews[self.allImageViews.count/2]] */) {
        
        [self.visiableImageViews removeAllObjects];
        UIImageView *imageView = self.allImageViews[self.allImageViews.count/2];
        [self.visiableImageViews addObject:imageView];
    }
    self.contentView.contentOffset = CGPointMake(self.allImageViews.count/2*self.contentView.bounds.size.width, 0);
    
    //是否需要调整坐标
    if (currentRow == _currentRow)
        return;
    
    _currentRow = currentRow;

    [self.dataSource imageLoop:self visiableImageView:self.allImageViews[self.allImageViews.count/2] imageForRow:currentRow];
    self.pageControl.currentPage = currentRow;
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
            [self.contentView setContentOffset:CGPointMake(self.currentIndex*self.bounds.size.width, 0) animated:NO];
            [self.timerIntermediary stop];
            break;
    }
}

#pragma mark - Getter
- (UIScrollView *)contentView {
    
    if (!_contentView) {
        UIScrollView *view = [[UIScrollView alloc] init];
        
        view.delegate                       = self;
        view.showsHorizontalScrollIndicator = NO;
        view.showsVerticalScrollIndicator   = NO;
        view.bounces                        = NO;
        view.pagingEnabled                  = YES;
        view.decelerationRate               = UIScrollViewDecelerationRateFast;
        
        _contentView = view;
    }
    return _contentView;
}
- (UIPageControl *)pageControl {
    
    if (!_pageControl) {
        UIPageControl *page = [[UIPageControl alloc] init];
        
        page.userInteractionEnabled = NO;
        page.hidesForSinglePage = YES;
        _pageControl = page;
    }
    return _pageControl;
}
- (NSMutableArray *)allImageViews {
    
    if (!_allImageViews) {
        _allImageViews = [[NSMutableArray alloc] init];
    }
    
    return _allImageViews;
}
- (NSMutableArray *)visiableImageViews {
    
    if (!_visiableImageViews) {
        _visiableImageViews = [[NSMutableArray alloc] init];
    }
    return _visiableImageViews;
}
- (NSInteger)currentIndex {
    
    return (NSInteger)(self.contentView.contentOffset.x/self.contentView.bounds.size.width);
}
- (CGRect)visiableRect {
    
    return CGRectMake(self.contentView.contentOffset.x, self.contentView.contentOffset.y, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
}
- (TimerIntermediary *)timerIntermediary {
    
    if (!_timerIntermediary) {
        _timerIntermediary = [TimerIntermediary timerIntermediaryWithTimeInterval:REPEAT_TIME target:self action:^(TimerIntermediary *intermediary, BannerShufflingView *target) {
            
            [target scrollToNextPage];
        } userInfo:nil repeats:YES];
    }
    return _timerIntermediary;
}

#pragma mark - overline
- (void)setContentInset:(UIEdgeInsets) contentInset {
    [self.contentView setContentInset:UIEdgeInsetsZero];
}


@end
