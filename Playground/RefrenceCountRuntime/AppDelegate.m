//
//  AppDelegate.m
//  RefrenceCountRuntime
//
//  Created by wangqinghai on 2018/5/28.
//  Copyright © 2018年 wangqinghai. All rights reserved.
//

#import "AppDelegate.h"
#import "CObject.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        MRCMemoryTest();
    });
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
