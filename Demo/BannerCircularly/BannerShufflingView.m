//
//  BannerShufflingView.m
//  YuanXin_Project
//
//  Created by Sword on 15/9/15.
//  Copyright (c) 2015年 yuanxin. All rights reserved.
//

#import "BannerShufflingView.h"
#import "BannerShufflingSV.h"

@interface BannerShufflingView() <UIScrollViewDelegate>

@property (nonatomic, assign, readwrite) BannerShufflingSVType type;

@property (nonatomic, strong) BannerShufflingSV *contentView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end


@implementation BannerShufflingView

- (instancetype)initWithFrame:(CGRect)frame contentType:(BannerShufflingSVType)type {
    
    if (self = [self initWithFrame:frame]) {
        self.clipsToBounds = YES;
        
        _type = type;
        __weak __typeof(self) wself = self;
        _contentView = [BannerShufflingSV bannerSVWithType:type loadImage:^(UIImageView *imageView, NSInteger row) {
            
            if ([wself.dataSource respondsToSelector:@selector(imageLoop:visiableImageView:imageForRow:)]) {
                [wself.dataSource imageLoop:wself visiableImageView:imageView imageForRow:row];
            }
        } clickImage:^(NSInteger index) {
            
            !wself.clickBlock ? : wself.clickBlock(wself, index);
        }];
        _contentView.rowDidChange = ^(NSInteger row) {
            wself.pageControl.currentPage = row;
        };
        
        [self addSubview:_contentView];
        [self sendSubviewToBack:_contentView];
    }
    return self;
}

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
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    if (self.contentView.translatesAutoresizingMaskIntoConstraints) {
        self.contentView.translatesAutoresizingMaskIntoConstraints = self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSArray *conH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(distance)-[_contentView]-(distance)-|" options:0 metrics:@{@"distance":@(kBannerShufflingSVNormal == self.type ? 0 : 15)} views:NSDictionaryOfVariableBindings(_contentView)];
        NSArray *conV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_contentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentView)];
        [self addConstraints:conH];
        [self addConstraints:conV];
    
        NSArray *pageH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_pageControl]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_pageControl)];
        NSArray *pageV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageControl]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_pageControl)];
        [self addConstraints:pageH];
        [self addConstraints:pageV];
    }
}

#pragma mark - Public
- (void)reloadData {
    
    [self resetScrollContent];
}
- (void)resetScrollContent {
    
    if ([self.dataSource respondsToSelector:@selector(imageLoopNumberOfRow:)]) {
        
        self.contentView.row = [self.dataSource imageLoopNumberOfRow:self];
        self.pageControl.numberOfPages = self.contentView.row;
    }
}

#pragma mark - setter & getter
- (void)setDataSource:(id<BannerShufflingViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    [self resetScrollContent];
}

#pragma mark - Getter
- (UIPageControl *)pageControl {
    
    if (!_pageControl) {
        UIPageControl *page = [[UIPageControl alloc] init];
        
        page.userInteractionEnabled = NO;
        page.hidesForSinglePage = YES;
        _pageControl = page;
    }
    return _pageControl;
}
@end