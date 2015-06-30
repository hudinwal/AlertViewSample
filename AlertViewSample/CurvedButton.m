//
//  CurvedButton.m
//  AlertViewSample
//
//  Created by Dinesh Kumar on 30/06/15.
//  Copyright (c) 2015 TheBanyanTree. All rights reserved.
//

#import "CurvedButton.h"
#import "AppDelegate+AppAppearance.h"

@implementation CurvedButton

-(void)awakeFromNib {
//    self.layer.cornerRadius = 3.0;
//    self.layer.masksToBounds = YES;
    
    [self setTitleColor:[UIColor whiteColor]
               forState:UIControlStateNormal];
    [self setBackgroundColor:kThemeColorAction];
}

@end
