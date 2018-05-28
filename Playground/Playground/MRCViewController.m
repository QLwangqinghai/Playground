//
//  MRCViewController.m
//  Playground
//
//  Created by wangqinghai on 2018/4/26.
//  Copyright © 2018年 wangqinghai. All rights reserved.
//

#import "MRCViewController.h"

@interface MRCViewController ()

@end

@implementation MRCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (instancetype)retain {
    NSLog(@"retain %@", self);
    return [super retain];
}

- (oneway void)release {
    NSLog(@"release %@", self);
    [super release];
}

@end





