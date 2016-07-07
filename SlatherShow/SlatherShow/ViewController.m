//
//  ViewController.m
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/3.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import "ViewController.h"
#import "SlatherShow.h"
#import "SSSystemActionSheet.h"

@interface ViewController ()<UIActionSheetDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    SlatherShow.systemAlert.show;
    
    NSMutableArray *tets = [NSMutableArray array];
    [tets removeAllObjects];
}
- (IBAction)custom:(id)sender {
//    [SSCustomAlertView showWithTitle:@"ssd" message:@"ssdsd" clickBlock:^(SSCustomAlertView *alertView, NSInteger buttonIndex) {
//        
//    } cancelButtonTitle:@"ssd" otherButtonTitles:nil];
//    
//    SSCustomAlertView *alertView = [[SSCustomAlertView alloc] initWithTitle:@"Test" message:@"Message here" clickBlock:^(SSCustomAlertView *alertView, NSInteger buttonIndex) {
//        NSLog(@"%zd",buttonIndex);
//    }cancelButtonTitle:@"sdsdsdsdsdsdsdsd" otherButtonTitles:@[@"OK"]];
//    alertView.buttonsShouldStack = YES;
////    UITextField *testView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 380, 40)];
////    testView.borderStyle = UITextBorderStyleRoundedRect;
////    testView.placeholder = @"ysdsdsdsd";
////    [alertView addCustomView:testView];
////    UITextField *colorVieww = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 2, 40)];
////    colorVieww.backgroundColor = [UIColor redColor];
////    colorVieww.borderStyle = UITextBorderStyleRoundedRect;
////    colorVieww.placeholder = @"colosdsds";
////    [alertView addCustomView:colorVieww];
////
//////    [alertView addButtonWithTitle:@"3rd"];
//////    [alertView addButtonWithTitle:@"4rd"];
//    [alertView show];
    SlatherShow.makeCusAlert().ss_title(@"test").ss_message(@"hello").ss_cancleTitle(@"Cancle").ss_actionTitle(@[@"OK"]).ss_actionHandle(^(SSCustomAlertView *alertView, NSInteger buttonIndex){
        NSLog(@"butt--%zd",buttonIndex);
    }).ss_setTapDismiss(YES).ss_setButtonStack(YES).ss_show();
    
}
- (IBAction)alertAction:(UIButton *)sender {
    
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:@"hello erasds sdsd asds sdsds sd " attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:20.0],NSForegroundColorAttributeName : [UIColor redColor]}];
    SlatherShow.makeSysAlert().ss_title(@"Test").ss_message(@"Message here").ss_cancleTitle(@"Cancel").ss_actionTitle(@[@"OK"]).ss_actionHandle(^(NSUInteger index){
        switch (index) {
            case 0:
                NSLog(@"000");
                break;
            case 1:
                NSLog(@"111");
                break;
            case 2:
                NSLog(@"222");
                break;
                
            default:
                break;
        }
    }).ss_show();
}
- (IBAction)sysSheet:(id)sender {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"TEST" delegate:self cancelButtonTitle:@"Cancle" destructiveButtonTitle:@"destructive" otherButtonTitles:@"other1",@"2222", nil];
    //    action.destructiveButtonIndex = 1;
    [action showInView:self.view];
    
}
- (IBAction)cusSheet:(id)sender {
    
//    [SSSystemActionSheet showActionSheetWithTitle:@"test" message:@"sdshh" cancelButtonTitle:@"cancle" destructiveButtonTitle:@"spesion" otherButtonTitles:@[@"wwqw",@"sdsd"] handler:^(id alert, NSInteger buttonIndex) {
//        NSLog(@"index %zd",buttonIndex);
//    }];
    SlatherShow.makeSysSheet().ss_title(@"TEST").ss_cancleTitle(@"Cancle").ss_destructiveTitle(@"des").ss_actionTitle(@[@"other1",@"2222"]).ss_actionHandle(^(NSUInteger index){
    
        NSLog(@"----%zd",index);
    }).ss_show();
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 8_3) __TVOS_PROHIBITED;
{

    NSLog(@"index %zd",buttonIndex);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
