//
//  SSCustomAlertView.h
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/10.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "SSBaseShow.h"

@class SSCustomAlertView;

typedef void (^CustomAlertClickBlock)(SSCustomAlertView *alertView, NSInteger buttonIndex);

@interface SSCustomAlertView : UIView

@property(nonatomic, strong) UIColor *tintColor;
@property(nonatomic, assign, readonly) NSInteger cancelButtonIndex; //取消按钮的index = numberofbuttons - 1
@property(nonatomic, assign, readonly) NSInteger firstOtherButtonIndex; // = 0
@property(nonatomic, assign, readonly) NSInteger numberOfButtons;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSAttributedString *attributeTitle;
@property(nonatomic, strong) NSString *message;
@property(nonatomic, strong) NSAttributedString *attributeMessage;
@property(nonatomic, assign) BOOL buttonsShouldStack; //按钮是否列表显示(只有两个按钮的时候,当按钮的文本过长时，可以选择分两行来展示按钮),默认为NO
@property(nonatomic, assign) BOOL tapBackgroundDismiss; //点击背景是否dismiss当前alert、默认为NO
@property(nonatomic, copy) CustomAlertClickBlock clickBlock; //按钮点击触发事件

/**
 *  类方法调用
 *
 *  @param title             title
 *  @param message           message
 *  @param clickBlock        clickBlock 按钮点击回调
 *  @param cancelButtonTitle cancelButtonTitle
 *  @param otherButtons      otherButtons
 *
 *  @return SSCustomAlertView
 */
+ (void)showWithTitle:(NSString *)title message:(NSString *)message clickBlock:(CustomAlertClickBlock)clickBlock cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons;
/**
 *  初始化 不带clickBlock，所以初始化完以后需要另外赋值clickBlock属性
 *
 *  @param title             title
 *  @param message           message
 *  @param cancelButtonTitle cancelButtonTitle
 *  @param otherButtons      otherButtons 可以设置为attributeString
 *
 *  @return SSCustomAlertView
 */
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons;
/**
 *  初始化
 *
 *  @param title             title
 *  @param message           message
 *  @param clickBlock        clickBlock 按钮点击回调
 *  @param cancelButtonTitle cancelButtonTitle
 *  @param otherButtons      otherButtons
 *
 *  @return SSCustomAlertView
 */
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message clickBlock:(CustomAlertClickBlock)clickBlock cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons;
/**
 *  添加按钮
 *
 *  @param title title
 *
 *  @return index
 */
- (NSInteger)addButtonWithTitle:(NSString *)title;
/**
 *  添加自定义的view  eg.textfield
 *
 *  @param customView view
 */
- (void)addCustomView:(UIView *)customView;
/**
 *  show
 */
- (void)show;
/**
 *  dismiss
 */
- (void)dismiss;

#pragma mark - chainable alert

+ (SSCustomAlertView *)shareInstance;

- (SSCustomAlertView *(^)(void))ss_alertInit;

- (SSCustomAlertView *(^)(NSString *title))ss_title;

- (SSCustomAlertView *(^)(NSAttributedString *attributedTitle))ss_attributedTitle;

- (SSCustomAlertView *(^)(NSString *message))ss_message;

- (SSCustomAlertView *(^)(NSAttributedString *attributedMessage))ss_attributedMessage;

- (SSCustomAlertView *(^)(NSString *cancleTitle))ss_cancleTitle;
// 可以设置为attributeString
- (SSCustomAlertView *(^)(NSArray *actionTitle))ss_actionTitle;

- (SSCustomAlertView *(^)(CustomAlertClickBlock))ss_actionHandle;

- (SSCustomAlertView *(^)(UIView *customView))ss_addCustomView;

- (SSCustomAlertView *(^)(BOOL tapDismiss))ss_setTapDismiss;

- (SSCustomAlertView *(^)(BOOL buttonStack))ss_setButtonStack;

- (SSCustomAlertView *(^)(void))ss_show;

- (void(^)(void))ss_dismiss;


@end
