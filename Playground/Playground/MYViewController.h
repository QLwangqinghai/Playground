//
//  MYViewController.h
//  Playground
//
//  Created by wangqinghai on 2018/4/26.
//  Copyright © 2018年 wangqinghai. All rights reserved.
//

#import "MRCViewController.h"

@interface BaseViewController : MRCViewController
@property (nonatomic, weak, nullable) UILabel * label;
@property (nonatomic, weak, nullable) UITextView * textView;
@property (atomic, nonnull) NSString * data;

- (void)doSomethingOnBackgroundThreadStrong;
- (void)doSomethingOnBackgroundThreadWeak;

@end





@interface MYViewController : BaseViewController

@end
