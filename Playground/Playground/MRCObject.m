//
//  MRCObject.m
//  Playground
//
//  Created by wangqinghai on 2018/4/26.
//  Copyright © 2018年 wangqinghai. All rights reserved.
//

#import "MRCObject.h"

@implementation MRCObject


- (instancetype)retain {
    NSLog(@"retain %@", self);
    return [super retain];
}

- (oneway void)release {
    NSLog(@"release %@", self);
    [super release];
}

@end




