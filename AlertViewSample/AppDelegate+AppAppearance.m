//
//  AppDelegate+AppAppearance.m
//  TestProject
//
//  Created by Dinesh Kumar on 30/06/15.
//  Copyright © 2015 Dinesh Kumar. All rights reserved.
//

#import "AppDelegate+AppAppearance.h"

@implementation AppDelegate (AppAppearance)

-(void)setAppAppearance {
    [self setNavigatioBarAppearance];
    [self setBarButtonItemAppearance];
    [self setTabBarAppearances];
    [self setSegmentedTintColor];
    [self setSwitchTintColor];
    [self setStatusBarTintColor];
    
}

-(void)setNavigatioBarAppearance {
    [[UINavigationBar appearance] setTitleTextAttributes:@{
        NSForegroundColorAttributeName: [UIColor whiteColor]
    }];
    [[UINavigationBar appearance] setBarTintColor:kThemeColor];
    [[UINavigationBar appearance] setTranslucent:NO];
}

-(void)setBarButtonItemAppearance {
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
}

-(void)setTabBarAppearances {
    [[UITabBar appearance] setBarTintColor:kThemeColor];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTranslucent:NO];
}

-(void)setStatusBarTintColor {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)setSegmentedTintColor {
    [[UISegmentedControl appearance] setTintColor:kThemeColorControl];
}

-(void)setSwitchTintColor {
    [[UISwitch appearance] setOnTintColor:kThemeColorControl];
}

@end
