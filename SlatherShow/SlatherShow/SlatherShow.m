//
//  SSShowManager.m
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/10.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import "SlatherShow.h"



@interface SlatherShow()

//@property (nonatomic , strong , readwrite) SSSystemAlertView *systemAlert;


@end

@implementation SlatherShow

+ (SSSystemAlertView *(^)(SlatherShowType type))make{

    return ^(SlatherShowType type){
        switch (type) {
            case SSSystemAlertType:
                [SSSystemAlertView shareInstance].ss_alertInit();
                return [SSSystemAlertView shareInstance];
                break;
                
            default:
                return [SSSystemAlertView shareInstance];
                break;
        }
    };
}

//+ (SSSystemAlertView *)systemAlert
//{
//
//    return [[SSSystemAlertView alloc] init];
//}


@end
