//
//  SSShowManager.m
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/10.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import "SlatherShow.h"

@interface SlatherShow()

@end

@implementation SlatherShow

+ (SSSystemAlertView *(^)(void))makeSysAlert{
    
    return ^(void){
        [SSSystemAlertView shareInstance].ss_alertInit();
        return [SSSystemAlertView shareInstance];
    };
}
+ (SSCustomAlertView *(^)(void))makeCusAlert{
    
    return ^(){
        [SSCustomAlertView shareInstance].ss_alertInit();
        return [SSCustomAlertView shareInstance];
    };
}

@end
