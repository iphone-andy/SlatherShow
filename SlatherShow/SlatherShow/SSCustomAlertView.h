//
//  SSCustomAlertView.h
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/10.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import "UIKit/UIKit.h"

@interface SSCustomAlertView : UIView

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic) BOOL keepTopAlignment;
@property (nonatomic, weak) id<UIAlertViewDelegate> delegate;

@property(nonatomic) NSInteger cancelButtonIndex;
@property(nonatomic, readonly) NSInteger firstOtherButtonIndex;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, readonly) NSInteger numberOfButtons;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, readonly, getter=isVisible) BOOL visible;
@property(nonatomic) BOOL buttonsShouldStack; //按钮列表显示

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
- (NSInteger)addButtonWithTitle:(NSString *)title;
- (void)show;

@end
