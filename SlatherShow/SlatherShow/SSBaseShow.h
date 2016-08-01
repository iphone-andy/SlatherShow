//
//  SSBaseView.h
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/10.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define IOS8Later [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0

@interface SSWindowController : UIViewController

@end

@interface SSBaseShow : NSObject

- (void)show;

- (void)dismiss;

@end

