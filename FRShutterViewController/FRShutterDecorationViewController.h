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
    FRShutterDecorationView *_decorationView;
}

- (id)initWithContentViewController:(UIViewController *)vc;
- (CGPoint)originMin;
- (CGPoint)originMax;

@property (nonatomic, readonly, strong) FRShutterDecorationView *decorationView;

@end
