//
//  SSSystemAlertView.h
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/10.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import "SSBaseView.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SSSystemAlertViewTextFieldStyle) {
    SSSystemAlertViewTextFieldStylePlain = 10,            //only one text field
    SSSystemAlertViewTextFieldStyleSecure,                //only one text field
    SSSystemAlertViewTextFieldStyleLoginAndPasswordInput  //two text field,one plain ,one secure
};
typedef void (^AlertClickBlock)(id alert, NSInteger buttonIndex);//alert 在iOS8以下为UIAlertView类型，iOS8以上为UIAlertController类型，调用者根据系统版本号自行判断

@interface SSSystemAlertView : SSBaseView

#pragma mark - shareInstance

+ (SSSystemAlertView *)shareInstance;

#pragma mark - Class AlertView show
/**
 *  class method show alert,cancle button will add to alert in the last , so the cancle index = added button count - 1
 *
 *  @param title             title
 *  @param message           message
 *  @param cancelButtonTitle cancelButtonTitle
 *  @param otherButtonTitles otherButtonTitles
 *  @param block             action (cancleButton index = allbutton.count - 1)
 *
 *  @return success or not   return SSSystemAlertView , just use it to call dismiss , dont do like add Button or set cancle or add Textfield to the renturn value
 */
+ (SSSystemAlertView *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(AlertClickBlock)block;

#pragma mark - Instance alertView init

+ (instancetype)alertViewWithTitle:(NSString *)title;
+ (instancetype)alertViewWithTitle:(NSString *)title message:(NSString *)message;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message;

#pragma mark - Add action

- (void)addButtonWithTitle:(NSString *)title handler:(void (^)(void))block;
- (void)setCancelButtonWithTitle:(NSString *)title handler:(void (^)(void))block;
/**
 *  add textfield to alertview
 *
 *  @param style                textfield style
 *  @param configurationHandler textfield config
 *
 *  @return success or not
 */
- (BOOL)addTextFieldWithType:(SSSystemAlertViewTextFieldStyle)style configurationHandler:(void (^)( NSArray<UITextField *> *textFields))configurationHandler;

#pragma mark - chainable alert

- (SSSystemAlertView *(^)(void))ss_alertInit;

- (SSSystemAlertView *(^)(NSString *title))ss_title;

- (SSSystemAlertView *(^)(NSAttributedString *attributedTitle))ss_attributedTitle;

- (SSSystemAlertView *(^)(NSString *message))ss_message;

- (SSSystemAlertView *(^)(NSAttributedString *attributedMessage))ss_attributedMessage;

- (SSSystemAlertView *(^)(NSString *cancleTitle))ss_cancleTitle;

//- (SSSystemAlertView *(^)(void (^handle)(void)))ss_cancleHandle;

- (SSSystemAlertView *(^)(NSArray <NSString *>*actionTitle))ss_actionTitle;

- (SSSystemAlertView *(^)(void (^handle)(NSUInteger index)))ss_actionHandle;

- (SSSystemAlertView *(^)(void))ss_show;

- (void(^)(void))ss_dismiss;

@end
