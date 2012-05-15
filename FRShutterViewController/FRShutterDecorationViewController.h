//
//  FRShutterController.h
//  FRShutterViewController
//
//  Created by Johannes Weiß on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRShutterDecorationView;

@interface FRShutterDecorationViewController : UIViewController {
    UIViewController *_contentViewController;
    UIView *_decorationView;
    UIView *_customDecorationView;
}

- (id)initWithContentViewController:(UIViewController *)vc shutterDecorationView:(UIView *)customDecorationView;
- (CGPoint)originMin;
- (CGPoint)originMax;

@property (nonatomic, readonly, strong) UIView *decorationView;

@end
