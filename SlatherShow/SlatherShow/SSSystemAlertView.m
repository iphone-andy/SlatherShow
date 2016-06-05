//
//  SSSystemAlertView.m
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/10.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import "SSSystemAlertView.h"
#import <objc/runtime.h>

#define IOS8Later [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
static const char SSSystemAlertView_ClassMethodActionBlockIdentify;
#pragma clang diagnostic pop

@interface SSSystemAlertView()<UIAlertViewDelegate>

@property(nonatomic , strong) id yzAlert;
@property(nonatomic , strong) NSMutableDictionary *alertActionDic;
@property(nonatomic , strong) NSMutableDictionary *alertSettingsDic;
@property(nonatomic , assign) NSUInteger actionIndex;

@property (nonatomic , strong , readwrite) NSMutableArray<UITextField *> *textFields;

@end

@implementation SSSystemAlertView

#pragma mark - ShareInstance
/**
 *  主要为了解决类方法调起UIAlertView的显示的时候，设置代理的问题，可以使用NSProxy动态代理来实现
 *  时间有限，暂时先用单例来保证UIAlertView代理的生命周期
 *
 *  @return SSSystemAlertView实例
 */
+ (SSSystemAlertView *)shareInstance{
    static SSSystemAlertView *alert;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alert = [[self alloc] init];
    });
    return alert;
}
#pragma mark - Class AlertView show

+ (SSSystemAlertView *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(AlertClickBlock)block;
{
    if (!cancelButtonTitle.length && !otherButtonTitles.count)
        cancelButtonTitle = @"取消";
    if (IOS8Later) {
        [SSSystemAlertView shareInstance].yzAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block((UIAlertController *)[SSSystemAlertView shareInstance].yzAlert,otherButtonTitles.count);
                }
            });
            
        }];
        [(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert addAction:cancelAction];
        [otherButtonTitles enumerateObjectsUsingBlock:^(NSString *button, NSUInteger index, BOOL *stop) {
            UIAlertAction *buttonAction = [UIAlertAction actionWithTitle:button style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) {
                        block((UIAlertController *)[SSSystemAlertView shareInstance].yzAlert,index);
                    }
                });
                
            }];
            [(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert addAction:buttonAction];
        }];
        [[self getCurrentVC] presentViewController:(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert animated:YES completion:nil];
    }else{
        
        [SSSystemAlertView shareInstance].yzAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:[self shareInstance] cancelButtonTitle:nil otherButtonTitles:nil];
        [otherButtonTitles enumerateObjectsUsingBlock:^(NSString *button, NSUInteger idx, BOOL *stop) {
            [(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert addButtonWithTitle:button];
        }];
        [(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert setCancelButtonIndex:[(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert addButtonWithTitle:cancelButtonTitle]];
        if (block) {
            objc_setAssociatedObject([self shareInstance],&SSSystemAlertView_ClassMethodActionBlockIdentify,block,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        [(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert show];
    }
    return [self shareInstance];
}

#pragma mark - Instance alertView init

+ (instancetype)alertViewWithTitle:(NSString *)title
{
    return [self alertViewWithTitle:title message:nil];
}

+ (instancetype)alertViewWithTitle:(NSString *)title message:(NSString *)message
{
    return [[[self class] alloc] initWithTitle:title message:message];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message
{
    NSAssert(title.length || message.length, @"alert view without a title and messsage cannot be added to the window.");
    self = [[self class] shareInstance];
    if (!self) {
        return nil;
    }
    objc_removeAssociatedObjects(self);
    self.textFields = [NSMutableArray array];
    self.alertActionDic = [NSMutableDictionary dictionary];
    if (IOS8Later) {
        _yzAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    }else{
        _yzAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    }
    return self;
}

#pragma mark - Add action

- (void)addButtonWithTitle:(NSString *)title handler:(void (^)(void))block
{
    NSAssert(title.length, @"A button without a title cannot be added to the alert view.");
    if (IOS8Later) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block();
                }
            });
        }];
        [(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert addAction:alertAction];
    }else{
        NSInteger index = [(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert addButtonWithTitle:title];
        [self setHandler:block forButtonAtIndex:index];
    }
}

- (void)setCancelButtonWithTitle:(NSString *)title handler:(void (^)(void))block
{
    if (!title.length)
        title = @"取消";
    if (IOS8Later) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (block) {
                block();
            }
        }];
        [(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert addAction:alertAction];
    }else{
        NSInteger cancelButtonIndex = [(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert addButtonWithTitle:title];
        ((UIAlertView *)[SSSystemAlertView shareInstance].yzAlert).cancelButtonIndex = cancelButtonIndex;
        [self setHandler:block forButtonAtIndex:cancelButtonIndex];
    }
}

- (void)setHandler:(void (^)(void))block forButtonAtIndex:(NSInteger)index
{
    NSNumber *key = @(index);
    if (block)
        [self.alertActionDic setObject:block forKey:key];
    else
        [self.alertActionDic removeObjectForKey:key];
}

- (BOOL)addTextFieldWithType:(SSSystemAlertViewTextFieldStyle)style configurationHandler:(void (^)( NSArray<UITextField *> *textFields))configurationHandler
{
    switch (style) {
        case SSSystemAlertViewTextFieldStylePlain:
        {
            if (IOS8Later){
                [(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.secureTextEntry = NO;
                    if (configurationHandler) {
                        configurationHandler(@[textField]);
                    }
                }];
                [[SSSystemAlertView shareInstance].textFields addObjectsFromArray:[(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert textFields]];
                
            }else{
                [(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [[SSSystemAlertView shareInstance].textFields addObject:[(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert textFieldAtIndex:0]];
                if (configurationHandler) {
                    configurationHandler(@[[(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert textFieldAtIndex:0]]);
                }
            }
        }
            break;
        case SSSystemAlertViewTextFieldStyleSecure:
        {
            if (IOS8Later) {
                [(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.secureTextEntry = YES;
                    [[SSSystemAlertView shareInstance].textFields addObject:textField];
                    if (configurationHandler) {
                        configurationHandler(@[textField]);
                    }
                }];
                [[SSSystemAlertView shareInstance].textFields addObjectsFromArray:[(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert textFields]];
                
            }else{
                [(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
                [[SSSystemAlertView shareInstance].textFields addObject:[(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert textFieldAtIndex:0]];
                if (configurationHandler) {
                    configurationHandler(@[[(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert textFieldAtIndex:0]]);
                }
            }
        }
            break;
        case SSSystemAlertViewTextFieldStyleLoginAndPasswordInput:
        {
            if (IOS8Later) {
                [(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.secureTextEntry = NO;
                    if (configurationHandler) {
                        configurationHandler(@[textField]);
                    }
                }];
                [(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.secureTextEntry = YES;
                    if (configurationHandler) {
                        configurationHandler(@[[NSNull null],textField]);
                    }
                }];
                [[SSSystemAlertView shareInstance].textFields addObjectsFromArray:[(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert textFields]];
                
            }else{
                [(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
                [[SSSystemAlertView shareInstance].textFields addObject:[(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert textFieldAtIndex:0]];
                [[SSSystemAlertView shareInstance].textFields addObject:[(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert textFieldAtIndex:1]];
                if (configurationHandler) {
                    configurationHandler(@[[(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert textFieldAtIndex:0],[(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert textFieldAtIndex:1]]);
                }
            }
        }
            break;
        default:
            break;
    }
    
    return YES;
}

#pragma mark - Alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.alertSettingsDic.count) {
            void(^block)(NSUInteger index) = [self.alertSettingsDic objectForKey:[NSString stringWithFormat:@"ss_actionHandle_index_%li",buttonIndex]];
            if (block) {
                block(buttonIndex);
            }
            return ;
        }
        AlertClickBlock block = objc_getAssociatedObject(self, &SSSystemAlertView_ClassMethodActionBlockIdentify);
        if (block){
            block(alertView,buttonIndex);
        }else{
            void (^buttonBlock)(void) = self.alertActionDic[@(buttonIndex)];
            if(buttonBlock){
                buttonBlock();
            }
        }
    });
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
//- (void)alertViewCancel:(UIAlertView *)alertView NS_DEPRECATED_IOS(2_0, 9_0);
//{
//
//}
//- (void)willPresentAlertView:(UIAlertView *)alertView NS_DEPRECATED_IOS(2_0, 9_0);  // before animation and showing view
//{
//
//}
//- (void)didPresentAlertView:(UIAlertView *)alertView NS_DEPRECATED_IOS(2_0, 9_0);  // after animation
//{
//
//}
//- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0); // before animation and hiding view
//{
//
//}
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0);  // after animation
//{
//
//}
//// Called after edits in any of the default fields added by the style
//- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView NS_DEPRECATED_IOS(2_0, 9_0);
//{
//    return YES;
//}

#pragma mark - Show / Dismiss action

- (void)show{
//    NSAssert(!_yzAlert, @"you may use chain grammar to init alert , you should use ss_show to show alert");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (IOS8Later) {
            if(_yzAlert){
                [[[self class] getCurrentVC] presentViewController:(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert animated:YES completion:nil];
            }
        }else{
            if (_yzAlert) {
                [(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert show];
            }
        }
    });
}

- (void)dismiss{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (IOS8Later) {
            if(_yzAlert){
                [(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert dismissViewControllerAnimated:YES completion:nil];
                _yzAlert = nil;
            }
        }else{
            if (_yzAlert) {
                [(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert dismissWithClickedButtonIndex:((UIAlertView *)[SSSystemAlertView shareInstance].yzAlert).cancelButtonIndex animated:YES];
                _yzAlert = nil;
            }
        }
    });
}

#pragma mark - Help methods

+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * topWin in windows)
        {
            if (topWin.windowLevel == UIWindowLevelNormal)
            {
                window = topWin;
                break;
            }
        }
    }
    UIView *frontView;
    for (int i = 0; i < [window.subviews count]; i++) {
        frontView = [[window subviews] objectAtIndex:i];
        if ([frontView isKindOfClass:NSClassFromString(@"UITransitionView")]) {
            frontView = [[frontView subviews] firstObject];
            if (frontView) {
                break;
            }
        }else{
            break;
        }
    }
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]){
        result = nextResponder;
    }else{
        result = window.rootViewController;
    }
    if ([result isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)nextResponder;
        if ([tab.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)tab.selectedViewController;
            result = [nav.viewControllers lastObject];
        } else {
            result = tab.selectedViewController;
        }
    } else if ([result isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)result;
        result = [nav.viewControllers lastObject];
    }
    return result;
}

#pragma mark - Dealloc
- (void)dealloc
{
    if (_yzAlert) {
        _yzAlert = nil;
    }
    objc_removeAssociatedObjects(self);
}

#pragma mark - chainable alert

- (SSSystemAlertView *(^)(void))ss_alertInit{
    return ^(){
        [SSSystemAlertView shareInstance].alertSettingsDic = [NSMutableDictionary dictionary];
        [SSSystemAlertView shareInstance].actionIndex = 1;
        return [SSSystemAlertView shareInstance];
    };
}

- (SSSystemAlertView *(^)(void))ss_show
{
    return ^(){
        NSString *title = [[SSSystemAlertView shareInstance].alertSettingsDic objectForKey:@"ss_systemAlert_title"];
        NSString *message = [[SSSystemAlertView shareInstance].alertSettingsDic objectForKey:@"ss_systemAlert_message"];
        NSAttributedString *attTitle = [[SSSystemAlertView shareInstance].alertSettingsDic objectForKey:@"ss_systemAlert_attributedTitle"];
        NSAttributedString *attMessage = [[SSSystemAlertView shareInstance].alertSettingsDic objectForKey:@"ss_systemAlert_attributedMessage"];
        if ((!title || title.length == 0) && (attTitle && attTitle.length > 0)) {
            title = [attTitle string];
        }
        if ((!message || message.length == 0) && (attMessage && attMessage.length > 0)) {
            message = [attMessage string];
        }
        NSString *cancle = [[SSSystemAlertView shareInstance].alertSettingsDic objectForKey:@"ss_systemAlert_cancleTitle"];
        void(^block)(NSUInteger index) = [[SSSystemAlertView shareInstance].alertSettingsDic objectForKey:@"ss_systemAlert_actionHandel"];
        NSArray *buttonArray = [[SSSystemAlertView shareInstance].alertSettingsDic objectForKey:@"ss_systemAlert_actionTitle"];
        
        (void)[[SSSystemAlertView shareInstance] initWithTitle:title message:message];
        
        if (attTitle && attTitle.length > 0) {
            [[SSSystemAlertView shareInstance] setAlertAttributedTitle:attTitle];
        }
        if (attMessage && attMessage.length > 0) {
            [[SSSystemAlertView shareInstance] setAlertAttributedMessage:attMessage];
        }
        
        if (buttonArray.count) {
            for (int i = 0 ; i < buttonArray.count; i ++) {
                [[SSSystemAlertView shareInstance] addButtonWithTitle:[buttonArray objectAtIndex:i] actionHandler:block];
            }
        }
        [[SSSystemAlertView shareInstance] addCancelButtonWithTitle:cancle actionHandler:block];
        [[SSSystemAlertView shareInstance] show];
        return [SSSystemAlertView shareInstance];
    };
}

- (void(^)(void))ss_dismiss{
    return ^(){
        [[SSSystemAlertView shareInstance] dismiss];
    };
}

- (SSSystemAlertView *(^)(NSString *title))ss_title{
    return ^(NSString *title){
        [[SSSystemAlertView shareInstance].alertSettingsDic setObject:title forKey:@"ss_systemAlert_title"];
        return [SSSystemAlertView shareInstance];
    };
}

- (SSSystemAlertView *(^)(NSString *message))ss_message
{
    return ^(NSString *message){
        [[SSSystemAlertView shareInstance].alertSettingsDic setObject:message forKey:@"ss_systemAlert_message"];
        return [SSSystemAlertView shareInstance];
    };
}

- (SSSystemAlertView *(^)(NSAttributedString *attributedTitle))ss_attributedTitle
{
    return ^(NSAttributedString *attributedTitle){
        [[SSSystemAlertView shareInstance].alertSettingsDic setObject:attributedTitle forKey:@"ss_systemAlert_attributedTitle"];
        return [SSSystemAlertView shareInstance];
    };
}

- (SSSystemAlertView *(^)(NSAttributedString *attributedMessage))ss_attributedMessage
{
    return ^(NSAttributedString *attributedMessage){
        [[SSSystemAlertView shareInstance].alertSettingsDic setObject:attributedMessage forKey:@"ss_systemAlert_attributedMessage"];
        return [SSSystemAlertView shareInstance];
    };
}

- (SSSystemAlertView *(^)(NSString *cancleTitle))ss_cancleTitle
{
    return ^(NSString *cancleTitle){
        [[SSSystemAlertView shareInstance].alertSettingsDic setObject:cancleTitle forKey:@"ss_systemAlert_cancleTitle"];
        return [SSSystemAlertView shareInstance];
    };
}

- (SSSystemAlertView *(^)(NSArray <NSString *>*actionTitle))ss_actionTitle
{
    return ^(NSArray <NSString *>*actionTitle){
        [[SSSystemAlertView shareInstance].alertSettingsDic setObject:actionTitle forKey:@"ss_systemAlert_actionTitle"];
        return [SSSystemAlertView shareInstance];
    };
}

- (SSSystemAlertView *(^)(void (^handle)(NSUInteger index)))ss_actionHandle{
    return ^(void (^handle)(NSUInteger index)){
        [[SSSystemAlertView shareInstance].alertSettingsDic setObject:[handle copy] forKey:@"ss_systemAlert_actionHandel"];
        return [SSSystemAlertView shareInstance];
    };
}

#pragma mark - chainable help methods

- (void)setAlertAttributedTitle:(NSAttributedString *)attStr{
    if (IOS8Later) {
        [(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert setValue:attStr forKey:@"attributedTitle"];
    }
}

- (void)setAlertAttributedMessage:(NSAttributedString *)attStr{
    if (IOS8Later) {
        [(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert setValue:attStr forKey:@"attributedMessage"];
    }
}

- (void)addButtonWithTitle:(NSString *)title actionHandler:(void (^)(NSUInteger index))block
{
    NSAssert(title.length, @"A button without a title cannot be added to the alert view.");
    NSUInteger btnIndex = [SSSystemAlertView shareInstance].actionIndex;
    if (IOS8Later) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(btnIndex - 1);
                }
            });
        }];
        [(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert addAction:alertAction];
    }else{
        NSInteger index = [(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert addButtonWithTitle:title];
        [[SSSystemAlertView shareInstance] setChainHandler:block forButtonAtIndex:index];
    }
    [SSSystemAlertView shareInstance].actionIndex ++;
}

- (void)addCancelButtonWithTitle:(NSString *)title actionHandler:(void (^)(NSUInteger index))block
{
    NSUInteger btnIndex = [SSSystemAlertView shareInstance].actionIndex;
    if (!title.length)
        title = @"取消";
    if (IOS8Later) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (block) {
                block(btnIndex - 1);
            }
        }];
        [(UIAlertController *)[SSSystemAlertView shareInstance].yzAlert addAction:alertAction];
    }else{
        NSInteger cancelButtonIndex = [(UIAlertView *)[SSSystemAlertView shareInstance].yzAlert addButtonWithTitle:title];
        ((UIAlertView *)[SSSystemAlertView shareInstance].yzAlert).cancelButtonIndex = cancelButtonIndex;
        [[SSSystemAlertView shareInstance] setChainHandler:block forButtonAtIndex:cancelButtonIndex];
    }
}

- (void)setChainHandler:(void (^)(NSUInteger index))block forButtonAtIndex:(NSInteger)index
{
    if (block)
        [self.alertSettingsDic setObject:block forKey:[NSString stringWithFormat:@"ss_actionHandle_index_%li",index]];
}
@end
