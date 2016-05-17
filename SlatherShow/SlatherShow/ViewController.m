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
- (IBAction)alertAction:(UIButton *)sender {
    
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:@"hello erasds sdsd asds sdsds sd " attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:20.0],NSForegroundColorAttributeName : [UIColor redColor]}];
    SlatherShow.make(SSSystemAlertType).ss_title(@"text").ss_attributedMessage(att).ss_message(@"hello").ss_cancleTitle(@"0").ss_actionTitle(@[@"1",@"2",@"3",@"4"]).ss_actionHandle(^(NSUInteger index){
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
