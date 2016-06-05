//
//  ViewController.m
//  SlatherShow
//
//  Created by 邱灿清 on 16/5/3.
//  Copyright © 2016年 邱灿清. All rights reserved.
//

#import "ViewController.h"
#import "SlatherShow.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    SlatherShow.systemAlert.show;
    
}
- (IBAction)custom:(id)sender {
    
    SSCustomAlertView *alertView = [[SSCustomAlertView alloc] initWithTitle:@"Test" message:@"Message here" clickBlock:^(SSCustomAlertView *alertView, NSInteger buttonIndex) {
        NSLog(@"%zd",buttonIndex);
    }cancelButtonTitle:@"sdsdsdsdsdsdsdsd" otherButtonTitles:@[@"OK"]];
    UITextField *testView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 380, 40)];
    testView.borderStyle = UITextBorderStyleRoundedRect;
    testView.placeholder = @"ysdsdsdsd";
    [alertView addCustomView:testView];
    UITextField *colorVieww = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 2, 40)];
    colorVieww.backgroundColor = [UIColor redColor];
    colorVieww.borderStyle = UITextBorderStyleRoundedRect;
    colorVieww.placeholder = @"colosdsds";
    [alertView addCustomView:colorVieww];

//    [alertView addButtonWithTitle:@"3rd"];
//    [alertView addButtonWithTitle:@"4rd"];

//    for (NSInteger titleIndex = 0; titleIndex < alertView.numberOfButtons; titleIndex++) {
//        NSLog(@"%@: button title for index %zd is: %@", [alertView class], titleIndex, [alertView buttonTitleAtIndex:titleIndex]);
//    }
    
//    NSLog(@"%@: First other button index: %li", [alertView class], (long)alertView.firstOtherButtonIndex);
//    NSLog(@"%@: Cancel button index: %li", [alertView class], (long)alertView.cancelButtonIndex);
//    NSLog(@"%@: Number of buttons: %li", [alertView class], (long)alertView.numberOfButtons);
    
    [alertView show];
    
}
- (IBAction)alertAction:(UIButton *)sender {
    
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:@"hello erasds sdsd asds sdsds sd " attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:20.0],NSForegroundColorAttributeName : [UIColor redColor]}];
    SlatherShow.make(SSSystemAlertType).ss_title(@"Test").ss_message(@"Message here").ss_cancleTitle(@"Cancel").ss_actionTitle(@[@"OK"]).ss_actionHandle(^(NSUInteger index){
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
