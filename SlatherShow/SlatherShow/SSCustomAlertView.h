//
//  SSCustomAlertView.h
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/10.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import "UIKit/UIKit.h"

@class SSCustomAlertView;

typedef void (^CustomAlertClickBlock)(SSCustomAlertView *alertView, NSInteger buttonIndex);

@interface SSCustomAlertView : UIView

@property(nonatomic, strong) UIColor *tintColor;
@property(nonatomic, assign, readonly) NSInteger cancelButtonIndex;
@property(nonatomic, assign, readonly) NSInteger firstOtherButtonIndex;
@property(nonatomic, assign, readonly) NSInteger numberOfButtons;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSAttributedString *attributeTitle;
@property(nonatomic, strong) NSString *message;
@property(nonatomic, strong) NSAttributedString *attributeMessage;
@property(nonatomic, assign) BOOL buttonsShouldStack; //按钮是否列表显示(只有两个按钮的时候)
@property(nonatomic, copy) CustomAlertClickBlock clickBlock;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message clickBlock:(CustomAlertClickBlock)clickBlock cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
- (NSInteger)addButtonWithTitle:(NSString *)title;
- (void)addCustomView:(UIView *)customView;
- (void)show;
- (void)dismiss;

@end
