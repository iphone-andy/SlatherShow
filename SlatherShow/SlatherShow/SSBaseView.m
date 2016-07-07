//
//  SSBaseView.m
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/10.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import "SSBaseView.h"

@implementation SSWindowController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [[UIApplication sharedApplication] statusBarStyle];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait)
        return UIInterfaceOrientationMaskPortrait;
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown)
        return UIInterfaceOrientationMaskPortraitUpsideDown;
    else if (orientation == UIInterfaceOrientationLandscapeLeft)
        return UIInterfaceOrientationMaskLandscapeLeft;
    else if (orientation == UIInterfaceOrientationLandscapeRight)
        return UIInterfaceOrientationMaskLandscapeRight;
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    return orientation;
}

- (BOOL)prefersStatusBarHidden
{
    return [UIApplication sharedApplication].statusBarHidden;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end

@implementation SSBaseView

- (void)show{
    NSAssert(NO, @"subclass should reload show method");
}

- (void)dismiss{
    NSAssert(NO, @"subclass should reload dismiss method");
}

@end
