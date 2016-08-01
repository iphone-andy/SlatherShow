//
//  SSSystemActionSheet.h
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/10.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import "SSBaseShow.h"

typedef void (^ActionSheetClickBlock)(id alert, NSInteger buttonIndex);//alert 在iOS8以下为UIAlertView类型，iOS8以上为UIAlertController类型，调用者根据系统版本号自行判断

@interface SSSystemActionSheet : SSBaseShow

+ (SSSystemActionSheet *)shareInstance;

+ (SSSystemActionSheet *)showActionSheetWithTitle:(NSString *)title
                                          message:(NSString *)message
                                cancelButtonTitle:(NSString *)cancelButtonTitle
                           destructiveButtonTitle:(NSString *)destructiveButtonTitle
                                otherButtonTitles:(NSArray *)otherButtonTitles
                                          handler:(ActionSheetClickBlock)block;

#pragma mark - Instance alertView init

+ (instancetype)actionSheetWithTitle:(NSString *)title;
+ (instancetype)actionSheetWithTitle:(NSString *)title message:(NSString *)message;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message;

#pragma mark - Add action

- (void)addButtonWithTitle:(NSString *)title handler:(void (^)(void))block;
- (void)addDestructiveButtonWithTitle:(NSString *)title handler:(void (^)(void))block;
- (void)setCancelButtonWithTitle:(NSString *)title handler:(void (^)(void))block;

#pragma mark - chainable alert

- (SSSystemActionSheet *(^)(void))ss_actionSheetInit;

- (SSSystemActionSheet *(^)(NSString *title))ss_title;

- (SSSystemActionSheet *(^)(NSAttributedString *attributedTitle))ss_attributedTitle;

- (SSSystemActionSheet *(^)(NSString *message))ss_message;

- (SSSystemActionSheet *(^)(NSAttributedString *attributedMessage))ss_attributedMessage;

- (SSSystemActionSheet *(^)(NSString *cancleTitle))ss_cancleTitle;

//- (SSSystemActionSheet *(^)(void (^handle)(void)))ss_cancleHandle;

- (SSSystemActionSheet *(^)(NSString *destructiveTitle))ss_destructiveTitle;

//- (SSSystemActionSheet *(^)(void (^handle)(void)))ss_destructiveHandle;

- (SSSystemActionSheet *(^)(NSArray <NSString *>*actionTitle))ss_actionTitle;

- (SSSystemActionSheet *(^)(void (^handle)(NSUInteger index)))ss_actionHandle;

- (SSSystemActionSheet *(^)(void))ss_show;

- (void(^)(void))ss_dismiss;

@end
