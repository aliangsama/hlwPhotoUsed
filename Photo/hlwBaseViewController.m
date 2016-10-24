//
//  hlwBaseViewController.m
//  hlwPhotoUsed
//
//  Created by 黄黎雯 on 2016/10/21.
//  Copyright © 2016年 hlw. All rights reserved.
//

#import "hlwBaseViewController.h"

@interface hlwBaseViewController ()

@end

@implementation hlwBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 重载返回按钮
// 返回
- (void) setupBack {
    UIButton* back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.frame = CGRectMake(0, 0, 50, 20);
     [back setTitle:@"返回" forState:UIControlStateNormal];
     back.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    // [back setImage:[UIImage imageNamed:@"back_highlight"] forState:UIControlStateHighlighted];
    [back setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    // [back setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [back addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = rightItem;
}

#pragma mark - 重载onback
- (void)onBack {
    UIViewController * controller=[self.navigationController.viewControllers objectAtIndex:0];
    if(controller == self) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
