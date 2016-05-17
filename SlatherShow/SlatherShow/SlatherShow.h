//
//  SSShowManager.h
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/10.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSSystemAlertView.h"

typedef NS_ENUM(NSUInteger, SlatherShowType) {
    SSSystemAlertType = 1,
    SSCustomAlertType = 10,
    SSSystemActionType = 20,
    SSCustomActionType = 30,
    SSToastType = 40,
    SSLoadingType = 50,
    SSProgressType = 60
};

@interface SlatherShow : NSObject

//@property(nonatomic, readonly, copy) SlatherShow *(^make)(SlatherShowType *type);

+ (SSSystemAlertView *(^)(SlatherShowType type))make;

//+ (SSSystemAlertView *)systemAlert;

//- (SSSystemAlertView *)systemAlert;

@end
