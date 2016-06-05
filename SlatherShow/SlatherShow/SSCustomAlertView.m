//
//  SSCustomAlertView.m
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/10.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import "SSCustomAlertView.h"

#define kSideMargin         15.0
#define kTopBottomMargin    19.0
#define kAlertWidth         270.0
#define kButtonHeight       44.0

@interface SSCustomAlertView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *alertContainerView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *representationView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UITableView *buttonTableView;
@property (nonatomic, strong) UITableView *otherTableView;
@property (nonatomic, strong) NSString *cancelButtonTitle;
@property (nonatomic, strong) NSMutableArray *otherButtonsTitles;
@property (nonatomic, strong) NSMutableArray *customViewArray;
@property (nonatomic, assign) NSInteger dismissIndex;
@property (nonatomic, assign) BOOL hasCancleButton;

@end

@implementation SSCustomAlertView

#pragma mark - init

+ (SSCustomAlertView *)shareInstance{
    static SSCustomAlertView *alert;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alert = [[self alloc] init];
    });
    return alert;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons
{
    return [self initWithTitle:title message:message clickBlock:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtons];

}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message clickBlock:(CustomAlertClickBlock)clickBlock cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons
{
    self = [super init];
    if (self) {
        self.clickBlock = [clickBlock copy];
        [self setupWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtons];
    }
    return self;
}

- (void)setupWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;
{
    _cancelButtonIndex = -1;
    _firstOtherButtonIndex = -1;
    _cancelButtonTitle = nil;
    _hasCancleButton = NO;
    if (otherButtonTitles != nil && [otherButtonTitles count] > 0 ) {
        _otherButtonsTitles = [[NSMutableArray alloc] initWithArray:otherButtonTitles];
        _firstOtherButtonIndex = 0;
    }
    
    _numberOfButtons = [_otherButtonsTitles count];
    
    if (cancelButtonTitle != nil) {
        _hasCancleButton = YES;
        _numberOfButtons++;
        _cancelButtonTitle = cancelButtonTitle;
        if (_numberOfButtons != 0) {
            _cancelButtonIndex = _numberOfButtons - 1;
        }else{
            _cancelButtonIndex = 0;
        }
    }
    
    CGFloat labelWidth = kAlertWidth - (kSideMargin * 2.0);
    CGFloat yOffset = kTopBottomMargin;
    UIView *lineView;
    
    if (title != nil) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.title = title;
        
        CGSize sizeThatFits = [self.titleLabel sizeThatFits:CGSizeMake(labelWidth, MAXFLOAT)];
        self.titleLabel.frame = CGRectMake(kSideMargin, yOffset, labelWidth, sizeThatFits.height);
        
        yOffset += self.titleLabel.frame.size.height;
    }
    yOffset += 4.0;
    
    if (message != nil) {
        self.messageLabel = [[UILabel alloc] init];
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.message = message;
        
        CGSize sizeThatFits = [self.messageLabel sizeThatFits:CGSizeMake(labelWidth, MAXFLOAT)];
        self.messageLabel.frame = CGRectMake(kSideMargin, yOffset, labelWidth, sizeThatFits.height);
        
        yOffset += self.messageLabel.frame.size.height;
    }
    yOffset += 4.0;
    if (self.customViewArray && self.customViewArray.count > 0) {
        for (int i = 0 ; i < self.customViewArray.count; i ++) {
            UIView *customView = self.customViewArray[i];
            customView.frame = CGRectMake(kSideMargin, yOffset, kAlertWidth - 2 * kSideMargin, customView.frame.size.height);
            yOffset += customView.frame.size.height;
        }
    }
    yOffset += kTopBottomMargin;
    
    if (self.numberOfButtons > 0) {
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, yOffset - 1.0, kAlertWidth, 1.0)];
        lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
        UIView *lineViewInner = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.5, kAlertWidth, 0.5)];
        lineViewInner.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        lineViewInner.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [lineView addSubview:lineViewInner];
    }
    
    BOOL sideBySideButtons = (self.numberOfButtons == 2) && !self.buttonsShouldStack;
    BOOL buttonsShouldStack = !sideBySideButtons;
    
    if (sideBySideButtons) {
        CGFloat halfWidth = (kAlertWidth / 2.0);
        
        UIView *lineVerticalViewInner = [[UIView alloc] initWithFrame:CGRectMake(halfWidth, 0.5, 0.5, kButtonHeight + 0.5)];
        lineVerticalViewInner.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        [lineView addSubview:lineVerticalViewInner];
        
        _buttonTableView = [self tableViewWithFrame:CGRectMake(halfWidth, yOffset, halfWidth, kButtonHeight)];
        _otherTableView = [self tableViewWithFrame:CGRectMake(0.0, yOffset, halfWidth, kButtonHeight)];
        
        yOffset += kButtonHeight;
    }
    else {
        NSInteger numberOfOtherButtons = [self.otherButtonsTitles count];
        
        if (numberOfOtherButtons > 0) {
            CGFloat tableHeight = buttonsShouldStack ? numberOfOtherButtons * kButtonHeight : kButtonHeight;
            
            _buttonTableView = [self tableViewWithFrame:CGRectMake(0.0, yOffset, kAlertWidth, tableHeight)];
            
            yOffset += tableHeight;
        }
        
        if (cancelButtonTitle != nil) {
            _otherTableView = [self tableViewWithFrame:CGRectMake(0.0, yOffset, kAlertWidth, kButtonHeight)];
            
            yOffset += kButtonHeight;
        }
    }
    
    _buttonTableView.tag = 0;
    _otherTableView.tag = 1; // 当只有两个按钮并排显示的时候
    
    [_buttonTableView reloadData];
    [_otherTableView reloadData];
    
    CGFloat alertHeight = yOffset;
    [self setupWithSize:CGSizeMake(kAlertWidth, alertHeight)];
    
    // Add everything to the content view
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.messageLabel];
    if (self.customViewArray && self.customViewArray.count > 0) {
        for (int i = 0 ; i < self.customViewArray.count; i ++) {
            UIView *customView = self.customViewArray[i];
            [self.contentView addSubview:customView];
        }
    }
    [self.contentView addSubview:self.buttonTableView];
    [self.contentView addSubview:self.otherTableView];
    [self.contentView addSubview:lineView];
}

-(void) setTitle:(NSString *)title
{
    _title = title;
    UIFont *titleFont = [UIFont boldSystemFontOfSize:17.0];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //[paragrahStyle setLineSpacing:2];
    NSDictionary *attributes = @{
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 NSFontAttributeName: titleFont
                                 };
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setAttributeTitle:(NSAttributedString *)attributeTitle{
 
    self.titleLabel.attributedText = attributeTitle;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    _attributeTitle = attributeTitle;
}

- (void)setMessage:(NSString *)message
{
    _message = message;
    UIFont *messageFont = [UIFont systemFontOfSize:14.0];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //[paragrahStyle setLineSpacing:2];
    NSDictionary *attributes = @{
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 NSFontAttributeName: messageFont
                                 };
    self.messageLabel.attributedText = [[NSAttributedString alloc] initWithString:message attributes:attributes];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setAttributeMessage:(NSAttributedString *)attributeMessage{
    self.messageLabel.attributedText = attributeMessage;
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    _attributeMessage = attributeMessage;
}

- (void)setupWithSize:(CGSize)size
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    _alertContainerView = [[UIView alloc] initWithFrame:(CGRect){.size = screenSize}];
    _alertContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _backgroundView = [[UIView alloc] initWithFrame:_alertContainerView.frame];
    _backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.58];
    [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapAction:)]];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_alertContainerView addSubview:_backgroundView];
    
    _representationView = [[UIView alloc] initWithFrame:(CGRect){.size = size}];
    _representationView.center = CGPointMake(screenSize.width / 2.0, screenSize.height / 2.0);
    _representationView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_representationView.layer setMasksToBounds:YES];
    [_representationView.layer setCornerRadius:7.0];
    
    _toolbar = [[UIToolbar alloc] initWithFrame:(CGRect){.size = self.representationView.frame.size}];
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.representationView addSubview:_toolbar];
    
    _contentView = [[UIView alloc] initWithFrame:(CGRect){.size = self.representationView.frame.size}];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.representationView addSubview:_contentView];
    [self.representationView addSubview:self];
    [self.alertContainerView addSubview:self.representationView];
}

- (UITableView *)tableViewWithFrame:(CGRect)frame
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    return tableView;
}

- (void)transformAlertContainerViewForOrientation{
#define DegreesToRadians(degrees) (degrees * M_PI / 180)
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGAffineTransform transform;
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            transform = CGAffineTransformMakeRotation(-DegreesToRadians(90));
            break;
        case UIInterfaceOrientationLandscapeRight:
            transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
            break;
        case UIInterfaceOrientationPortrait:
        default:
            transform = CGAffineTransformMakeRotation(DegreesToRadians(0));
            break;
    }
    
    [self.alertContainerView setTransform:transform];
}

#pragma mark - show / dismiss

- (void)show
{
    self.window = [[UIWindow alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].frame];
    self.window.tintColor = self.tintColor;
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view = self.alertContainerView;
    self.window.rootViewController = viewController;
    self.window.backgroundColor = [UIColor clearColor];
    self.window.windowLevel = UIWindowLevelAlert;
    self.window.hidden = NO;
    
    [self transformAlertContainerViewForOrientation];
    [self.window makeKeyAndVisible];
    [self showAlertAnimation];

}

- (void)dismiss{

    self.window.hidden = YES;
    self.window = nil;
    
    [self.buttonTableView deselectRowAtIndexPath:self.buttonTableView.indexPathForSelectedRow animated:NO];
    [self.otherTableView deselectRowAtIndexPath:self.otherTableView.indexPathForSelectedRow animated:NO];
    if (self.clickBlock) {
        self.clickBlock(self,self.dismissIndex);
    }
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    self.dismissIndex = buttonIndex;
    
    if (!animated) {
        [self dismiss];
    }else{
        [self dismissAlertAnimation];
    }
}

- (void)showAlertAnimation{
    [CATransaction begin]; {
        CATransform3D transformFrom = CATransform3DMakeScale(1.26, 1.26, 1.0);
        CATransform3D transformTo = CATransform3DMakeScale(1.0, 1.0, 1.0);
        
        CASpringAnimation *transformAnimation = [CASpringAnimation animationWithKeyPath:@"transform"];
        [transformAnimation setValue:@"show" forKey:@"transformKEY"];
        transformAnimation.damping = 500.0;
        transformAnimation.mass = 3.0;
        transformAnimation.stiffness = 1000.0;
        transformAnimation.duration = 0.5058237314224243;
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:transformFrom];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:transformTo];
        transformAnimation.delegate = self;

        self.representationView.layer.transform = transformTo;
        [self.representationView.layer addAnimation:transformAnimation forKey:@"transform"];
        
        CASpringAnimation *opacityAnimation = [CASpringAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.damping = 500.0;
        opacityAnimation.mass = 3.0;
        opacityAnimation.stiffness = 1000.0;
        opacityAnimation.duration = 0.5058237314224243;
        opacityAnimation.delegate = self;
        opacityAnimation.fromValue = @0.0f;
        opacityAnimation.toValue = @1.0f;
        self.backgroundView.layer.opacity = 1.0;
        self.toolbar.layer.opacity = 1.0;
        self.contentView.layer.opacity = 1.0;
        
        [self.backgroundView.layer addAnimation:opacityAnimation forKey:@"opacity"];
        [self.toolbar.layer addAnimation:opacityAnimation forKey:@"opacity"];
        [self.contentView.layer addAnimation:opacityAnimation forKey:@"opacity"];
    } [CATransaction commit];
}

- (void)dismissAlertAnimation{
    [CATransaction begin]; {
        CATransform3D transformFrom = CATransform3DMakeScale(1.0, 1.0, 1.0);
        CATransform3D transformTo = CATransform3DMakeScale(0.840, 0.840, 1.0);
        
        CASpringAnimation *transformAnimation = [CASpringAnimation animationWithKeyPath:@"transform"];
        transformAnimation.damping = 500.0;
        transformAnimation.mass = 3.0;
        transformAnimation.stiffness = 1000.0;
        transformAnimation.duration = 0.5058237314224243;
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:transformFrom];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:transformTo];
        transformAnimation.delegate = self;
        [transformAnimation setValue:@"dismiss" forKey:@"transformKEY"];
        self.representationView.layer.transform = transformTo;
        
        [self.representationView.layer addAnimation:transformAnimation forKey:@"transform"];
        
        CASpringAnimation *opacityAnimation = [CASpringAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.damping = 500.0;
        opacityAnimation.mass = 3.0;
        opacityAnimation.stiffness = 1000.0;
        opacityAnimation.duration = 0.5058237314224243;
        opacityAnimation.delegate = self;
        opacityAnimation.fromValue = @1.0f;
        opacityAnimation.toValue = @0.0f;
        
        self.backgroundView.layer.opacity = 0.0;
        self.toolbar.layer.opacity = 0.0;
        self.contentView.layer.opacity = 0.0;
        [self.backgroundView.layer addAnimation:opacityAnimation forKey:@"opacity"];
        [self.toolbar.layer addAnimation:opacityAnimation forKey:@"opacity"];
        [self.contentView.layer addAnimation:opacityAnimation forKey:@"opacity"];
    } [CATransaction commit];
}

- (void)backgroundTapAction:(UITapGestureRecognizer *)tap{
    NSLog(@"taped");
}

#pragma mark - CAAnimation Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([[anim valueForKey:@"transformKEY"] isEqualToString:@"show"]) {

    }else if ([[anim valueForKey:@"transformKEY"] isEqualToString:@"dismiss"]){
        
        if (!flag) return;
        [self dismiss];
    }
}

//TODO: Keyboard
#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)notification
{
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    
//    self.representationView.layer.anchorPoint = CGPointMake(0.5, 0.5);
//    self.representationView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2.0, ([[UIScreen mainScreen] bounds].size.height - keyboardSize.height) / 2.0);
}

#pragma mark UITableView dataSource / delegate

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id labelText;
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    
    NSInteger buttonIndex;
    BOOL boldButton = NO;
    BOOL lastRow = NO;
    
    if (self.numberOfButtons == 1) {
        buttonIndex = 0;
        labelText = self.hasCancleButton ? self.cancelButtonTitle : self.otherButtonsTitles[0];
        boldButton = YES;
        lastRow = YES;
    }else if (self.numberOfButtons == 2) {
        buttonIndex = tableView.tag;
        if (self.hasCancleButton) {
            if (buttonIndex == 1) {
                labelText = self.cancelButtonTitle;
            }
            else {
                labelText = self.otherButtonsTitles[0];
            }
        }
        else {
            labelText = self.otherButtonsTitles[buttonIndex];
        }
        
        boldButton = buttonIndex == 1;
        lastRow = YES;
    }
    // More than 2 stacked buttons
    else {

        if (tableView.tag == 1) {
            labelText = self.cancelButtonTitle;
            boldButton = YES;
            lastRow = YES;
            buttonIndex = self.numberOfButtons - 1;
        }
        else {
            buttonIndex = indexPath.row;

            labelText = self.otherButtonsTitles[buttonIndex];
            
            if (!self.hasCancleButton && buttonIndex == ([self.otherButtonsTitles count] - 1)) {
                boldButton = YES;
            }
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    UIView *contentView = cell.contentView;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, contentView.frame.size.height - 0.5, contentView.frame.size.width, 0.5)];
    lineView.tag = 1111;
    lineView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [contentView addSubview:lineView];
    
    cell.tag = buttonIndex;
    lineView.hidden = lastRow;
    cell.textLabel.font = boldButton ? [UIFont boldSystemFontOfSize:17.0] : [UIFont systemFontOfSize:17.0];
    if (labelText && [labelText isKindOfClass:[NSAttributedString class]]) {
        cell.textLabel.attributedText = (NSAttributedString *)labelText;
    }else{
        cell.textLabel.text = labelText;
    }
    cell.textLabel.textColor = [UIColor colorWithRed:0 green:91/255.0 blue:255/255.0 alpha:1];//[UIColor blueColor];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.numberOfButtons <= 2) {
        return 1;
    }else {
        if (tableView.tag == 0) {
            return [self.otherButtonsTitles count];
        }else {
            return 1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self dismissWithClickedButtonIndex:cell.tag animated:YES];
}

# pragma mark - add button

- (NSInteger)addButtonWithTitle:(NSString *)title
{
    NSString *oldTitle = [self.title copy];
    NSString *oldMessage = [self.message copy];
    NSString *oldCancelTitle = [self.cancelButtonTitle copy];
    NSMutableArray *allTitles = [[NSMutableArray alloc] initWithArray:self.otherButtonsTitles copyItems:YES];
    [allTitles addObject:title];
    [self setupWithTitle:oldTitle message:oldMessage cancelButtonTitle:oldCancelTitle otherButtonTitles:allTitles];
    
    return self.numberOfButtons - 1;
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle;
    if (self.cancelButtonTitle) {
        if (buttonIndex == self.numberOfButtons - 1) {
            buttonTitle = self.cancelButtonTitle;
        }else {
            buttonTitle = [self.otherButtonsTitles objectAtIndex:buttonIndex];
        }
    }else {
        buttonTitle = [self.otherButtonsTitles objectAtIndex:buttonIndex];
    }
    return buttonTitle;
}

- (void)addCustomView:(UIView *)customView
{
    if (customView) {
        if (!self.customViewArray) {
            self.customViewArray = [[NSMutableArray alloc] init];
        }
        [self.customViewArray addObject:customView];
    }
    [self setupWithTitle:self.title message:self.message cancelButtonTitle:self.cancelButtonTitle otherButtonTitles:self.otherButtonsTitles];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
}

#pragma mark - chainable alert

- (SSCustomAlertView *(^)(void))ss_alertInit{
    return ^(){
        return [SSCustomAlertView shareInstance];
    };
}

- (SSCustomAlertView *(^)(void))ss_show
{
    return ^(){
       SSCustomAlertView *alert = [[SSCustomAlertView shareInstance] initWithTitle:[SSCustomAlertView shareInstance].title message:[SSCustomAlertView shareInstance].message clickBlock:[SSCustomAlertView shareInstance].clickBlock cancelButtonTitle:[SSCustomAlertView shareInstance].cancelButtonTitle otherButtonTitles:[SSCustomAlertView shareInstance].otherButtonsTitles];
        [alert show];
        return [SSCustomAlertView shareInstance];
    };
}

- (void(^)(void))ss_dismiss{
    return ^(){
        [[SSCustomAlertView shareInstance] dismissAlertAnimation];
    };
}

- (SSCustomAlertView *(^)(NSString *title))ss_title{
    return ^(NSString *title){
        [SSCustomAlertView shareInstance].title = title;
        return [SSCustomAlertView shareInstance];
    };
}

- (SSCustomAlertView *(^)(NSString *message))ss_message
{
    return ^(NSString *message){
        [SSCustomAlertView shareInstance].message = message;
        return [SSCustomAlertView shareInstance];
    };
}

- (SSCustomAlertView *(^)(NSAttributedString *attributedTitle))ss_attributedTitle
{
    return ^(NSAttributedString *attributedTitle){
        [SSCustomAlertView shareInstance].attributeTitle = attributedTitle;
        return [SSCustomAlertView shareInstance];
    };
}

- (SSCustomAlertView *(^)(NSAttributedString *attributedMessage))ss_attributedMessage
{
    return ^(NSAttributedString *attributedMessage){
        [SSCustomAlertView shareInstance].attributeMessage = attributedMessage;
        return [SSCustomAlertView shareInstance];
    };
}

- (SSCustomAlertView *(^)(NSString *cancleTitle))ss_cancleTitle
{
    return ^(NSString *cancleTitle){
        [SSCustomAlertView shareInstance].cancelButtonTitle = cancleTitle;
        return [SSCustomAlertView shareInstance];
    };
}

- (SSCustomAlertView *(^)(NSArray *actionTitle))ss_actionTitle
{
    return ^(NSArray <NSString *>*actionTitle){
        [SSCustomAlertView shareInstance].otherButtonsTitles = [NSMutableArray arrayWithArray:actionTitle];
        return [SSCustomAlertView shareInstance];
    };
}

- (SSCustomAlertView *(^)(UIView *customView))ss_addCustomView;
{
    return ^(UIView *customView){
        if (![SSCustomAlertView shareInstance].customViewArray) {
            [SSCustomAlertView shareInstance].customViewArray = [NSMutableArray array];
        }
        [[SSCustomAlertView shareInstance].customViewArray addObject:customView];
        return [SSCustomAlertView shareInstance];
    };
}

- (SSCustomAlertView *(^)(CustomAlertClickBlock))ss_actionHandle{
    return ^(CustomAlertClickBlock clickblock){
        [SSCustomAlertView shareInstance].clickBlock = [clickblock copy];
        return [SSCustomAlertView shareInstance];
    };
}

@end
