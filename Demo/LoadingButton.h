//
//  LoadingButton.h
//  Demo
//
//  Created by sword on 2017/9/7.
//  Copyright © 2017年 Sword. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface  LoadingButton : UIButton

@property (assign, nonatomic, getter=isLoading) BOOL loading;

@property (strong, nonatomic) IBInspectable NSString *loadingTitle;
@property (strong, nonatomic) IBInspectable UIColor *loadingTitleColor;

@end
