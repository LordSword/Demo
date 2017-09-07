//
//  LoadingButton.m
//  Demo
//
//  Created by sword on 2017/9/7.
//  Copyright © 2017年 Sword. All rights reserved.
//

#import "LoadingButton.h"

@interface LoadingButton ()

@property (strong, nonatomic) NSString *disabledTitle;
@property (strong, nonatomic) UILabel *loadingLabel;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@end

@implementation LoadingButton
@synthesize loadingTitle = _loadingTitle;

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.indicatorView];
        [self addSubview:self.loadingLabel];
        [self setNeedsUpdateConstraints];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        
        [self addSubview:self.indicatorView];
        [self addSubview:self.loadingLabel];
        [self setNeedsUpdateConstraints];
    }
    return self;
}
- (void)updateConstraints {
    [super updateConstraints];
    
    if (self.indicatorView.translatesAutoresizingMaskIntoConstraints) {
        self.indicatorView.translatesAutoresizingMaskIntoConstraints = self.loadingLabel.translatesAutoresizingMaskIntoConstraints = NO;

        NSLayoutConstraint *hLabCon = [NSLayoutConstraint constraintWithItem:self.loadingLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:CGRectGetWidth(self.indicatorView.bounds)/2];
        NSLayoutConstraint *vLabCon = [NSLayoutConstraint constraintWithItem:self.loadingLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *hCon = [NSLayoutConstraint constraintWithItem:self.indicatorView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.loadingLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:-2];
        NSLayoutConstraint *vCon = [NSLayoutConstraint constraintWithItem:self.indicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.loadingLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];

        [self addConstraint:hLabCon];
        [self addConstraint:vLabCon];
        [self addConstraint:hCon];
        [self addConstraint:vCon];
    }
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    
    if (UIControlStateDisabled == state) {
        self.disabledTitle = title;
    }
}

#pragma mark - Setter
- (void)setLoading:(BOOL)loading {
    
    if (_loading == loading) return;
    _loading = loading;
    [super setEnabled:!loading];
    [self setTitle:loading ? @"":self.disabledTitle forState:UIControlStateDisabled];
    self.loadingLabel.hidden = !loading;
    
    self.indicatorView.color = self.loadingLabel.textColor = self.loadingTitleColor ?:[UIColor whiteColor];
    self.loadingLabel.font = self.titleLabel.font;
    if (loading) {
        [self.indicatorView startAnimating];
    } else {
        [self.indicatorView stopAnimating];
    }
}
- (void)setLoadingTitle:(NSString *)loadingTitle {
    
    self.loadingLabel.text = loadingTitle;
}

- (void)setEnabled:(BOOL)enabled {
    
    if (self.loading) {
        self.loading = NO;
    }
    [super setEnabled:enabled];
}

#pragma mark - Getter
- (UIActivityIndicatorView *)indicatorView {
    
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}
- (UILabel *)loadingLabel {
    
    if (!_loadingLabel) {
        _loadingLabel = [[UILabel alloc] init];
        _loadingLabel.hidden = YES;
    }
    return _loadingLabel;
}
- (NSString *)loadingTitle {
    
    return self.loadingLabel.text;
}

@end
