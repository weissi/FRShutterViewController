//
//  FRShutterViewController.h
//  FRShutterViewController
//
//  Created by Johannes Weiß on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UIViewController+FRShutterViewController.h"

@class FRShutterDecorationViewController;

typedef enum {
    FRShutterViewControllerOrientationHorizontal,
    FRShutterViewControllerOrientationVertical
} FRShutterViewControllerOrientation;

typedef enum {
    FRShutterViewControllerSpineLocationMin,
    FRShutterViewControllerSpineLocationMax
} FRShutterViewControllerSpineLocation;

@interface FRShutterViewController : UIViewController<UIGestureRecognizerDelegate> {
    @private
    UIViewController *_masterViewController;
    FRShutterDecorationViewController *_shutterDecorationViewController;
    FRShutterViewControllerOrientation _orientation;
    UIPanGestureRecognizer *_panGR;
}

- (id)initWithMasterViewController:(UIViewController *)master
                shutterOrientation:(FRShutterViewControllerOrientation)orientation
                     spineLocation:(FRShutterViewControllerSpineLocation)spineLocation;

- (void)openDetailViewController:(UIViewController *)vc animated:(BOOL)animated;

- (void)closeDetailViewControllerAnimated:(BOOL)animated;

@property (nonatomic, readonly) FRShutterViewControllerOrientation orientation;
@property (nonatomic, readonly) FRShutterViewControllerSpineLocation spineLocation;
@property (nonatomic, readonly, strong) UIViewController *masterViewController;

@end
