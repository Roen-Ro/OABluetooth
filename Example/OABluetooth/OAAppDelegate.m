//
//  OAAppDelegate.m
//  OABluetooth
//
//  Created by zxllf23@163.com on 11/18/2018.
//  Copyright (c) 2018 zxllf23@163.com. All rights reserved.
//

#import "OAAppDelegate.h"


#import "BleScanTableViewController.h"

@implementation OAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    UIWindow *window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    [self.window makeKeyAndVisible];
    window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[[BleScanTableViewController alloc]init]];
    
    return YES;
}


@end


