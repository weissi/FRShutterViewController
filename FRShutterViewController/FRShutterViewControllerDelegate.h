//
//  FRShutterViewControllerDelegate.h
//  FRShutterViewController
//
//  Created by Johannes Weiß on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FRShutterViewControllerDelegate <NSObject>

@optional

- (void)willOpenDetailViewController:(UIViewController *)vc;
- (void)didOpenDetailViewController:(UIViewController *)vc;
- (void)willCloseDetailViewController:(UIViewController *)vc;
- (void)didCloseDetailViewController;
- (void)shutterWillMoveToPosition:(CGFloat)pos animated:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)shutterDidMoveToPosition:(CGFloat)pos;

@end
