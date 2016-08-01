//
//  SSCustemActionSheet.h
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/10.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "SSBaseShow.h"

@class SSCustomActionSheet;
typedef void (^ActionSheetClickBlock)(SSCustomActionSheet *actionSheet, NSInteger buttonIndex);

@interface SSCustomActionSheet : UIView

@property (nonatomic , assign) NSInteger destructIndex;

#pragma mark - class Instance actionSheet

+ (SSCustomActionSheet *)shareInstance;

+ (SSCustomActionSheet *)showActionSheetWithTitle:(NSString *)title
                                          message:(NSString *)message
                                cancelButtonTitle:(NSString *)cancelButtonTitle
                           destructiveButtonTitle:(NSString *)destructiveButtonTitle
                                otherButtonTitles:(NSArray *)otherButtonTitles
                                          handler:(ActionSheetClickBlock)block;

#pragma mark - Instance actionSheet init

+ (instancetype)actionSheetWithTitle:(NSString *)title;
+ (instancetype)actionSheetWithTitle:(NSString *)title message:(NSString *)message;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message;

#pragma mark - Add action

- (void)addButtonWithTitle:(NSString *)title handler:(void (^)(void))block;
- (void)addDestructiveButtonWithTitle:(NSString *)title handler:(void (^)(void))block;
- (void)setCancelButtonWithTitle:(NSString *)title handler:(void (^)(void))block;

@end
