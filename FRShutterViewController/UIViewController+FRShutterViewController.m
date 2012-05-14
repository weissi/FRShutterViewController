//
//  UIViewController+FRShutterViewController.m
//  FRShutterViewController
//
//  Created by Johannes Weiß on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+FRShutterViewController.h"

#import "FRShutterViewController.h"

@implementation UIViewController (FRShutterViewController)

- (FRShutterViewController *)shutterViewController {
    UIViewController *here = self;
    
    while (here != nil) {
        if([here class] == [FRShutterViewController class]) {
            return (FRShutterViewController *)here;
        }
        
        here = here.parentViewController;
    }
    
    return nil;
}

@end
