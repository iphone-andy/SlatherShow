//
//  SSSystemActionSheet.m
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/10.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import "SSSystemActionSheet.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
static const char SSSystemActionSheet_ClassMethodActionBlockIdentify;
#pragma clang diagnostic pop

@interface SSSystemActionSheet()<UIActionSheetDelegate>

@property(nonatomic , strong) id yzAction;
@property(nonatomic , strong) NSMutableDictionary *actionSheetDic;
@property(nonatomic , strong) NSMutableDictionary *actionSettingsDic;
@property(nonatomic , assign) NSUInteger actionIndex;

@end
@implementation SSSystemActionSheet

+ (SSSystemActionSheet *)shareInstance{
    static SSSystemActionSheet *alert;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alert = [[self alloc] init];
    });
    return alert;
}

#pragma mark - Class AlertView show

+ (SSSystemActionSheet *)showActionSheetWithTitle:(NSString *)title
                                          message:(NSString *)message
                                cancelButtonTitle:(NSString *)cancelButtonTitle
                                otherButtonTitles:(NSArray *)otherButtonTitles
                                          handler:(ActionSheetClickBlock)block{
   return [self showActionSheetWithTitle:title message:message cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:nil destructiveButtonIndex:-1 otherButtonTitles:otherButtonTitles handler:block];
}

+ (SSSystemActionSheet *)showActionSheetWithTitle:(NSString *)title
                                          message:(NSString *)message
                                cancelButtonTitle:(NSString *)cancelButtonTitle
                           destructiveButtonTitle:(NSString *)destructiveButtonTitle
                           destructiveButtonIndex:(NSInteger)destructiveButtonIndex
                                otherButtonTitles:(NSArray *)otherButtonTitles
                                          handler:(ActionSheetClickBlock)block;
{
    if (!cancelButtonTitle.length && !otherButtonTitles.count)
        cancelButtonTitle = @"取消";
    if (IOS8Later) {
        [SSSystemActionSheet shareInstance].yzAction = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block((UIAlertController *)[SSSystemActionSheet shareInstance].yzAction,otherButtonTitles.count);
                }
            });
        }];
        [(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction addAction:cancelAction];
        
        UIAlertAction *destrutiveAction;
        NSInteger destructiveButtonLocation = -1;
        if (destructiveButtonTitle.length > 0) {

            destructiveButtonLocation = destructiveButtonIndex < 0 ? 0 : (destructiveButtonIndex > otherButtonTitles.count ? otherButtonTitles.count : destructiveButtonIndex);
            destrutiveAction = [UIAlertAction actionWithTitle:destructiveButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) {
                        block((UIAlertController *)[SSSystemActionSheet shareInstance].yzAction,destructiveButtonLocation);
                    }
                });
            }];
        }

        [otherButtonTitles enumerateObjectsUsingBlock:^(NSString *button, NSUInteger index, BOOL *stop) {
            
            if (destrutiveAction) {
                if (destructiveButtonLocation == otherButtonTitles.count) {
                    UIAlertAction *buttonAction = [UIAlertAction actionWithTitle:button style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (block) {
                                block((UIAlertController *)[SSSystemActionSheet shareInstance].yzAction,(destructiveButtonLocation == -1) ? index : ( index >=destructiveButtonLocation ? index + 1 : index));
                            }
                        });
                    }];
                    [(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction addAction:buttonAction];
                    if (index + 1 == destructiveButtonLocation) {
                        [(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction addAction:destrutiveAction];
                    }
                }else{
                    if (index == destructiveButtonLocation) {
                        [(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction addAction:destrutiveAction];
                    }
                    UIAlertAction *buttonAction = [UIAlertAction actionWithTitle:button style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (block) {
                                block((UIAlertController *)[SSSystemActionSheet shareInstance].yzAction,(destructiveButtonLocation == -1) ? index : ( index >=destructiveButtonLocation ? index + 1 : index));
                            }
                        });
                    }];
                    [(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction addAction:buttonAction];
                }
            }else{
                UIAlertAction *buttonAction = [UIAlertAction actionWithTitle:button style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) {
                            block((UIAlertController *)[SSSystemActionSheet shareInstance].yzAction,(destructiveButtonLocation == -1) ? index : ( index >=destructiveButtonLocation ? index + 1 : index));
                        }
                    });
                }];
                [(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction addAction:buttonAction];
            }
        }];
        //TODO:fix ipad show error
        [[self getCurrentVC] presentViewController:(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction animated:YES completion:nil];
    }else{
        if (!title.length && message.length > 0) {
            title = message;
        }
        [SSSystemActionSheet shareInstance].yzAction = [[UIActionSheet alloc] initWithTitle:title delegate:[self shareInstance] cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
        [otherButtonTitles enumerateObjectsUsingBlock:^(NSString *button, NSUInteger idx, BOOL *stop) {
            [(UIActionSheet *)[SSSystemActionSheet shareInstance].yzAction addButtonWithTitle:button];
        }];
      
        if (block) {
            objc_setAssociatedObject([self shareInstance],&SSSystemActionSheet_ClassMethodActionBlockIdentify,block,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        [(UIActionSheet *)[SSSystemActionSheet shareInstance].yzAction showInView:[UIApplication sharedApplication].keyWindow];
    }
    return [self shareInstance];
}

#pragma mark - Instance alertView init

+ (instancetype)actionSheetWithTitle:(NSString *)title
{
    return [self actionSheetWithTitle:title message:nil];
}

+ (instancetype)actionSheetWithTitle:(NSString *)title message:(NSString *)message
{
    return [[[self class] alloc] initWithTitle:title message:message];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message
{
    NSAssert(title.length || message.length, @"action sheet view without a title and messsage cannot be added to the window.");
    self = [[self class] shareInstance];
    if (!self) {
        return nil;
    }
//    objc_removeAssociatedObjects(self);
    self.actionSheetDic = [NSMutableDictionary dictionary];
    if (IOS8Later) {
        _yzAction = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    }else{
        _yzAction = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    }
    return self;
}

#pragma mark - Add action

- (void)addButtonWithTitle:(NSString *)title handler:(void (^)(void))block
{
    NSAssert(title.length, @"A button without a title cannot be added to the action sheet.");
    if (IOS8Later) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block();
                }
            });
        }];
        [(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction addAction:alertAction];
    }else{
        NSInteger index = [(UIAlertView *)[SSSystemActionSheet shareInstance].yzAction addButtonWithTitle:title];
        [self setHandler:block forButtonAtIndex:index];
    }
}

- (void)addDestructiveButtonWithTitle:(NSString *)title handler:(void (^)(void))block
{
    NSAssert(title.length, @"A button without a title cannot be added to the action sheet.");
    if (IOS8Later) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block();
                }
            });
        }];
        [(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction addAction:alertAction];
    }else{
        NSInteger index = [(UIActionSheet *)[SSSystemActionSheet shareInstance].yzAction addButtonWithTitle:title];
        [(UIActionSheet *)[SSSystemActionSheet shareInstance].yzAction setDestructiveButtonIndex:index];
        [self setHandler:block forButtonAtIndex:index];
    }
}

- (void)setCancelButtonWithTitle:(NSString *)title handler:(void (^)(void))block
{
    if (!title.length)
        title = @"取消";
    if (IOS8Later) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block();
                }
            });
        }];
        [(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction addAction:alertAction];
    }else{
        NSInteger cancelButtonIndex = [(UIAlertView *)[SSSystemActionSheet shareInstance].yzAction addButtonWithTitle:title];
        ((UIAlertView *)[SSSystemActionSheet shareInstance].yzAction).cancelButtonIndex = cancelButtonIndex;
        [self setHandler:block forButtonAtIndex:cancelButtonIndex];
    }
}

- (void)setHandler:(void (^)(void))block forButtonAtIndex:(NSInteger)index
{
    NSNumber *key = @(index);
    if (block)
        [self.actionSheetDic setObject:block forKey:key];
    else
        [self.actionSheetDic removeObjectForKey:key];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.actionSettingsDic.count) {
            void(^block)(NSUInteger index) = [self.actionSettingsDic objectForKey:[NSString stringWithFormat:@"ss_actionHandle_index_%li",buttonIndex]];
            if (block) {
                block(buttonIndex);
            }
            return ;
        }
        ActionSheetClickBlock block = objc_getAssociatedObject(self, &SSSystemActionSheet_ClassMethodActionBlockIdentify);
        if (block){
            block(actionSheet,buttonIndex);
        }else{
            void (^buttonBlock)(void) = self.actionSheetDic[@(buttonIndex)];
            if(buttonBlock){
                buttonBlock();
            }
        }
    });
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet{
    NSLog(@"clicking the cancel button is simulated and the action sheet is dismissed");
}

#pragma mark - Show / Dismiss action

- (void)show{
    //    NSAssert(!_yzAction, @"you may use chain grammar to init alert , you should use ss_show to show alert");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (IOS8Later) {
            if(_yzAction){
                [[[self class] getCurrentVC] presentViewController:(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction animated:YES completion:nil];
            }
        }else{
            if (_yzAction) {
                [(UIActionSheet *)[SSSystemActionSheet shareInstance].yzAction showInView:[UIApplication sharedApplication].keyWindow];
            }
        }
    });
}

- (void)dismiss{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (IOS8Later) {
            if(_yzAction){
                [(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction dismissViewControllerAnimated:YES completion:nil];
                _yzAction = nil;
            }
        }else{
            if (_yzAction) {
                [(UIActionSheet *)[SSSystemActionSheet shareInstance].yzAction dismissWithClickedButtonIndex:((UIAlertView *)[SSSystemActionSheet shareInstance].yzAction).cancelButtonIndex animated:YES];
                _yzAction = nil;
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
    if (_yzAction) {
        _yzAction = nil;
    }
    objc_removeAssociatedObjects(self);
}

#pragma mark - chainable alert

- (SSSystemActionSheet *(^)(void))ss_actionSheetInit{
    return ^(){
        [SSSystemActionSheet shareInstance].actionSettingsDic = [NSMutableDictionary dictionary];
        [SSSystemActionSheet shareInstance].actionIndex = 1;
        return [SSSystemActionSheet shareInstance];
    };
}

- (SSSystemActionSheet *(^)(void))ss_show
{
    return ^(){
        NSString *title = [[SSSystemActionSheet shareInstance].actionSettingsDic objectForKey:@"ss_systemActionSheet_title"];
        NSString *message = [[SSSystemActionSheet shareInstance].actionSettingsDic objectForKey:@"ss_systemActionSheet_message"];
        NSAttributedString *attTitle = [[SSSystemActionSheet shareInstance].actionSettingsDic objectForKey:@"ss_systemActionSheet_attributedTitle"];
        NSAttributedString *attMessage = [[SSSystemActionSheet shareInstance].actionSettingsDic objectForKey:@"ss_systemActionSheet_attributedMessage"];
        if ((!title || title.length == 0) && (attTitle && attTitle.length > 0)) {
            title = [attTitle string];
        }
        if ((!message || message.length == 0) && (attMessage && attMessage.length > 0)) {
            message = [attMessage string];
        }
        NSString *cancle = [[SSSystemActionSheet shareInstance].actionSettingsDic objectForKey:@"ss_systemActionSheet_cancleTitle"];
        NSString *destructive = [[SSSystemActionSheet shareInstance].actionSettingsDic objectForKey:@"ss_systemActionSheet_destructiveTitle"];
        void(^block)(NSUInteger index) = [[SSSystemActionSheet shareInstance].actionSettingsDic objectForKey:@"ss_systemActionSheet_actionHandel"];
        NSMutableArray *buttonArray = [[SSSystemActionSheet shareInstance].actionSettingsDic objectForKey:@"ss_systemActionSheet_actionTitle"];
        
        (void)[[SSSystemActionSheet shareInstance] initWithTitle:title message:message];
        
        if (attTitle && attTitle.length > 0) {
            [[SSSystemActionSheet shareInstance] setActionSheetAttributedTitle:attTitle];
        }
        if (attMessage && attMessage.length > 0) {
            [[SSSystemActionSheet shareInstance] setActionSheetAttributedMessage:attMessage];
        }
        if (IOS8Later) {
            
        }
        NSInteger destructiveIndex = [[SSSystemActionSheet shareInstance].yzAction respondsToSelector:NSSelectorFromString(@"getDestructiveButtonIndex:")] ? ((UIActionSheet *)[SSSystemActionSheet shareInstance].yzAction).destructiveButtonIndex : -1;
        BOOL shouldAddDestructButton = NO;
        if (destructive.length > 0) {
            if (destructiveIndex <= (NSInteger)buttonArray.count) {
                if (destructiveIndex == -1 ) {
                    [[SSSystemActionSheet shareInstance] addDestructiveButtonWithTitle:destructive actionHandler:block];
                }else{
                    shouldAddDestructButton = YES;
                    [buttonArray insertObject:destructive atIndex:destructiveIndex];
                }
            }
        }
        if (buttonArray.count) {
            for (int i = 0 ; i < buttonArray.count; i ++) {
                if (shouldAddDestructButton && i ==destructiveIndex) {
                    [[SSSystemActionSheet shareInstance] addDestructiveButtonWithTitle:destructive actionHandler:block];
                }else{
                    [[SSSystemActionSheet shareInstance] addButtonWithTitle:[buttonArray objectAtIndex:i] actionHandler:block];
                }
            }
        }
        [[SSSystemActionSheet shareInstance] addCancelButtonWithTitle:cancle actionHandler:block];
        [[SSSystemActionSheet shareInstance] show];
        return [SSSystemActionSheet shareInstance];
    };
}

- (void(^)(void))ss_dismiss{
    return ^(){
        [[SSSystemActionSheet shareInstance] dismiss];
    };
}

- (SSSystemActionSheet *(^)(NSString *title))ss_title{
    return ^(NSString *title){
        [[SSSystemActionSheet shareInstance].actionSettingsDic setObject:title forKey:@"ss_systemActionSheet_title"];
        return [SSSystemActionSheet shareInstance];
    };
}

- (SSSystemActionSheet *(^)(NSString *message))ss_message
{
    return ^(NSString *message){
        [[SSSystemActionSheet shareInstance].actionSettingsDic setObject:message forKey:@"ss_systemActionSheet_message"];
        return [SSSystemActionSheet shareInstance];
    };
}

- (SSSystemActionSheet *(^)(NSAttributedString *attributedTitle))ss_attributedTitle
{
    return ^(NSAttributedString *attributedTitle){
        [[SSSystemActionSheet shareInstance].actionSettingsDic setObject:attributedTitle forKey:@"ss_systemActionSheet_attributedTitle"];
        return [SSSystemActionSheet shareInstance];
    };
}

- (SSSystemActionSheet *(^)(NSAttributedString *attributedMessage))ss_attributedMessage
{
    return ^(NSAttributedString *attributedMessage){
        [[SSSystemActionSheet shareInstance].actionSettingsDic setObject:attributedMessage forKey:@"ss_systemActionSheet_attributedMessage"];
        return [SSSystemActionSheet shareInstance];
    };
}

- (SSSystemActionSheet *(^)(NSString *cancleTitle))ss_cancleTitle
{
    return ^(NSString *cancleTitle){
        [[SSSystemActionSheet shareInstance].actionSettingsDic setObject:cancleTitle forKey:@"ss_systemActionSheet_cancleTitle"];
        return [SSSystemActionSheet shareInstance];
    };
}

- (SSSystemActionSheet *(^)(NSString *destructiveTitle))ss_destructiveTitle
{
    return ^(NSString *destructiveTitle){
        [[SSSystemActionSheet shareInstance].actionSettingsDic setObject:destructiveTitle forKey:@"ss_systemActionSheet_destructiveTitle"];
        return [SSSystemActionSheet shareInstance];
    };
}

- (SSSystemActionSheet *(^)(NSArray <NSString *>*actionTitle))ss_actionTitle
{
    return ^(NSArray <NSString *>*actionTitle){
        [[SSSystemActionSheet shareInstance].actionSettingsDic setObject:actionTitle forKey:@"ss_systemActionSheet_actionTitle"];
        return [SSSystemActionSheet shareInstance];
    };
}

- (SSSystemActionSheet *(^)(void (^handle)(NSUInteger index)))ss_actionHandle{
    return ^(void (^handle)(NSUInteger index)){
        [[SSSystemActionSheet shareInstance].actionSettingsDic setObject:[handle copy] forKey:@"ss_systemActionSheet_actionHandel"];
        return [SSSystemActionSheet shareInstance];
    };
}

#pragma mark - chainable help methods

- (void)setActionSheetAttributedTitle:(NSAttributedString *)attStr{
    if (IOS8Later) {
        [(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction setValue:attStr forKey:@"attributedTitle"];
    }
}

- (void)setActionSheetAttributedMessage:(NSAttributedString *)attStr{
    if (IOS8Later) {
        [(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction setValue:attStr forKey:@"attributedMessage"];
    }
}

- (void)addButtonWithTitle:(NSString *)title actionHandler:(void (^)(NSUInteger index))block
{
    NSAssert(title.length, @"A button without a title cannot be added to the action sheet.");
    NSUInteger btnIndex = [SSSystemActionSheet shareInstance].actionIndex;
    if (IOS8Later) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(btnIndex);
                }
            });
        }];
        [(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction addAction:alertAction];
    }else{
        NSInteger index = [(UIActionSheet *)[SSSystemActionSheet shareInstance].yzAction addButtonWithTitle:title];
        [[SSSystemActionSheet shareInstance] setChainHandler:block forButtonAtIndex:index];
    }
    [SSSystemActionSheet shareInstance].actionIndex ++;
}

- (void)addCancelButtonWithTitle:(NSString *)title actionHandler:(void (^)(NSUInteger index))block
{
    NSUInteger btnIndex = [SSSystemActionSheet shareInstance].actionIndex;
    if (!title.length)
        title = @"取消";
    if (IOS8Later) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(btnIndex);
                }
            });
        }];
        [(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction addAction:alertAction];
    }else{
        NSInteger cancelButtonIndex = [(UIActionSheet *)[SSSystemActionSheet shareInstance].yzAction addButtonWithTitle:title];
        ((UIAlertView *)[SSSystemActionSheet shareInstance].yzAction).cancelButtonIndex = cancelButtonIndex;
        [[SSSystemActionSheet shareInstance] setChainHandler:block forButtonAtIndex:cancelButtonIndex];
    }
}

- (void)addDestructiveButtonWithTitle:(NSString *)title actionHandler:(void (^)(NSUInteger index))block
{
    NSAssert(title.length, @"A button without a title cannot be added to the action sheet.");

    NSUInteger btnIndex = [SSSystemActionSheet shareInstance].actionIndex;
    
    if (IOS8Later) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(btnIndex - 1);
                }
            });
        }];
        [(UIAlertController *)[SSSystemActionSheet shareInstance].yzAction addAction:alertAction];
    }else{
        NSInteger destructiveButtonIndex = [(UIActionSheet *)[SSSystemActionSheet shareInstance].yzAction addButtonWithTitle:title];
        ((UIActionSheet *)[SSSystemActionSheet shareInstance].yzAction).destructiveButtonIndex = destructiveButtonIndex;
        [[SSSystemActionSheet shareInstance] setChainHandler:block forButtonAtIndex:destructiveButtonIndex];
    }
}

- (void)setChainHandler:(void (^)(NSUInteger index))block forButtonAtIndex:(NSInteger)index
{
    if (block)
        [self.actionSettingsDic setObject:block forKey:[NSString stringWithFormat:@"ss_actionHandle_index_%li",index]];
}

@end
