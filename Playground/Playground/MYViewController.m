//
//  MYViewController.m
//  Playground
//
//  Created by wangqinghai on 2018/4/26.
//  Copyright © 2018年 wangqinghai. All rights reserved.
//

#import "MYViewController.h"

@implementation BaseViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.data = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton * btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(10, 70, 160, 40);
    [btn setTitle:@"do background weak" forState:(UIControlStateNormal)];
    [btn addTarget:self action:@selector(doSomethingOnBackgroundThreadWeak) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor blueColor];
    
    UIButton * btn2 = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.view addSubview:btn2];
    btn2.frame = CGRectMake(180, 70, 160, 40);
    [btn2 setTitle:@"do background strongSelf" forState:(UIControlStateNormal)];
    [btn2 addTarget:self action:@selector(doSomethingOnBackgroundThreadStrong) forControlEvents:UIControlEventTouchUpInside];
    btn2.backgroundColor = [UIColor blueColor];
    
    
    UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 120, 300, 30)];
    [self.view addSubview:textView];
    textView.text = @"content";
    self.textView = textView;
    textView.backgroundColor = [UIColor lightGrayColor];
    self.data = textView.text;
    
    UILabel * label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:label];
    label.frame = CGRectMake(10, 170, 300, 200);
    label.font = [UIFont systemFontOfSize:14];
    self.label = label;
}

- (void)doSomethingOnBackgroundThreadStrong {
    
}
- (void)doSomethingOnBackgroundThreadWeak {
    
}


@end



@interface MYViewController ()


@end
@implementation MYViewController


- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)doSomethingOnBackgroundThreadStrong {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [NSThread sleepForTimeInterval:3.0];
        if (strongSelf.data) {
            NSMutableString * string = [NSMutableString stringWithString:@"data: "];
            NSLog(@"begin sleep， 模仿线程-挂起状态");
            [NSThread sleepForTimeInterval:5];
            NSLog(@"after sleep， 模仿线程-运行状态");
            [string appendString:strongSelf.data];
            NSLog(@"%@", string);
        }
    });
}
- (void)doSomethingOnBackgroundThreadWeak {
    __weak typeof(self) weakSelf = self;
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSThread sleepForTimeInterval:3.0];
        if (weakSelf.data) {
            NSMutableString * string = [NSMutableString stringWithString:@"data: "];
            NSLog(@"begin sleep， 模仿线程-挂起状态");
            [NSThread sleepForTimeInterval:5];
            NSLog(@"after sleep， 模仿线程-运行状态");
            [string appendString:weakSelf.data];
            NSLog(@"%@", string);
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
