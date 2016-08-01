//
//  SSCustemActionSheet.m
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/10.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import "SSCustomActionSheet.h"

@interface SSCustomActionSheet()

@end

@implementation SSCustomActionSheet

+ (SSCustomActionSheet *)shareInstance{
    static SSCustomActionSheet *alert;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alert = [[self alloc] init];
    });
    return alert;
}

//+ (SSCustomActionSheet *)showActionSheetWithTitle:(NSString *)title
//                                          message:(NSString *)message
//                                cancelButtonTitle:(NSString *)cancelButtonTitle
//                           destructiveButtonTitle:(NSString *)destructiveButtonTitle
//                                otherButtonTitles:(NSArray *)otherButtonTitles
//                                          handler:(ActionSheetClickBlock)block{
//    
//    [[[SSCustomActionSheet shareInstance] initWithTitle:title message:message clickBlock:clickBlock cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtons] show];
//}
//
//- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons
//{
//    return [self initWithTitle:title message:message clickBlock:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtons];
//    
//}
//
//- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message clickBlock:(CustomAlertClickBlock)clickBlock cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons
//{
//    self = [super init];
//    if (self) {
//        self.clickBlock = [clickBlock copy];
//        [self setupWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtons];
//    }
//    return self;
//}

@end
