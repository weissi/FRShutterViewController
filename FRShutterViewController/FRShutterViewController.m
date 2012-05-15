//
//  FRShutterViewController.m
//  FRShutterViewController
//
//  Created by Johannes Weiß on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRShutterViewController.h"
#import "FRShutterDecorationViewController.h"
#import "FRShutterDecorationView.h"

@interface FRShutterViewController ()

@property (nonatomic, readwrite, strong) FRShutterDecorationViewController *shutterDecorationViewController;
@property (nonatomic, readwrite, strong) UIPanGestureRecognizer *panGR;
@property (nonatomic, readwrite, strong) UIView *customDecorationView;

@end

@implementation FRShutterViewController

#pragma mark - init/dealloc

- (id)initWithMasterViewController:(UIViewController *)master
                shutterOrientation:(FRShutterViewControllerOrientation)orientation
                     spineLocation:(FRShutterViewControllerSpineLocation)spineLocation
{
    return [self initWithMasterViewController:master
                           shutterOrientation:orientation
                                spineLocation:spineLocation
                        shutterDecorationView:nil];
}

- (id)initWithMasterViewController:(UIViewController *)master
                shutterOrientation:(FRShutterViewControllerOrientation)orientation
                     spineLocation:(FRShutterViewControllerSpineLocation)spineLocation
             shutterDecorationView:(UIView *)customDecorationView
{
    if ((self = [super init])) {
        _masterViewController = master;
        _orientation = orientation;
        _spineLocation = spineLocation;
        _customDecorationView = customDecorationView;
    }
    
    [self attachMasterViewController];
    
    return self;
}

- (void)dealloc
{
    self.panGR.delegate = nil;
    [self detachMasterViewController];
}

#pragma mark - internal methods: add/remove master view controller

- (void)attachMasterViewController
{
    [self addChildViewController:self.masterViewController];
    [self.masterViewController didMoveToParentViewController:self];
}

- (void)detachMasterViewController
{
    [self.masterViewController willMoveToParentViewController:nil];
    [self.masterViewController removeFromParentViewController];
}

#pragma mark - UIViewController interface

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.masterViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.masterViewController.view];
    
    if (self.shutterDecorationViewController) {
        const CGRect onscreenFrame = [self shutterDecorationViewControllerViewFrame];
        self.shutterDecorationViewController.view.frame = onscreenFrame;
        [self.view addSubview:self.shutterDecorationViewController.view];
    }
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self doLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    [super didRotateFromInterfaceOrientation:orientation];
    [self doLayout];
}

#pragma mark - internal helper methods

- (void)doLayout
{
    if (self.shutterDecorationViewController != nil) {
        CGRect f = self.shutterDecorationViewController.view.frame;
        f.size = self.view.bounds.size;
        self.shutterDecorationViewController.view.frame = f; /* don't remove this line! */
        f.origin = [self shutterNearestBound];
        self.shutterDecorationViewController.view.frame = f;
    }

}

- (CGPoint)offscreenOrigin {
    if (self.orientation == FRShutterViewControllerOrientationHorizontal) {
        if (self.spineLocation == FRShutterViewControllerSpineLocationMin) {
            return CGPointMake(-1024, 0);
        } else if (self.spineLocation == FRShutterViewControllerSpineLocationMax) {
            return CGPointMake(1024, 0);
        }
    } else if (self.orientation == FRShutterViewControllerOrientationVertical) {
        if (self.spineLocation == FRShutterViewControllerSpineLocationMin) {
            return CGPointMake(0, -1024);
        } else if (self.spineLocation == FRShutterViewControllerSpineLocationMax) {
            return CGPointMake(0, 1024);
        }
    } 
    
    NSAssert(false, @"BUG: unknown orientation / spine location");
    return CGPointZero;
}

- (CGPoint)shutterNearestBound
{
    CGPoint min = [self.shutterDecorationViewController originMin];
    CGPoint max = [self.shutterDecorationViewController originMax];
    CGPoint cur = self.shutterDecorationViewController.view.frame.origin;
    CGFloat distToMin = sqrt(((min.x-cur.x)*(min.x-cur.x)) + ((min.y-cur.y)*((min.y-cur.y))));
    CGFloat distToMax = sqrt(((max.x-cur.x)*(max.x-cur.x)) + ((max.y-cur.y)*((max.y-cur.y))));
    
    if (distToMax < distToMin) {
        return [self.shutterDecorationViewController originMax];
    } else {
        return [self.shutterDecorationViewController originMin];
    }
}

#pragma mark - UIGestureRecognizer delegate interface

- (void)handleGesture:(UIPanGestureRecognizer *)g
{
    UIView *v = self.shutterDecorationViewController.view;
    CGRect f = v.frame;

    switch (g.state) {
        case UIGestureRecognizerStatePossible: {
            //NSLog(@"UIGestureRecognizerStatePossible");
            break;
        }
            
        case UIGestureRecognizerStateBegan: {
            //NSLog(@"UIGestureRecognizerStateBegan");
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            //NSLog(@"UIGestureRecognizerStateChanged");
            switch (self.orientation) {
                case FRShutterViewControllerOrientationHorizontal: {
                    CGFloat xTranslation = [g translationInView:v].x;
                    f.origin.x += xTranslation;
                    v.frame = f;
                    break;
                }
                case FRShutterViewControllerOrientationVertical: {
                    CGFloat yTranslation = [g translationInView:v].y;
                    f.origin.y += yTranslation;
                    v.frame = f;
                    break;
                }
                default:
                    NSAssert(false, @"unknwon orientation");
            }
            [g setTranslation:CGPointZero inView:v];
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            //NSLog(@"UIGestureRecognizerStateEnded");
            CGFloat velocity;
            switch (self.orientation) {
                case FRShutterViewControllerOrientationHorizontal: {
                    velocity = [g velocityInView:v].x;
                    break;
                }
                case FRShutterViewControllerOrientationVertical: {
                    velocity = [g velocityInView:v].y;
                    break;
                }
                default:
                    NSAssert(false, @"unknwon orientation");
            }
            
            if (abs(velocity) > 100) {
                if (velocity > 0) {
                    f.origin = [self.shutterDecorationViewController originMax];
                } else {
                    f.origin = [self.shutterDecorationViewController originMin];
                }
            } else {
                f.origin = [self shutterNearestBound];
            }
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options:UIViewAnimationCurveEaseOut
                             animations:^{
                                 v.frame = f;
                             }
                             completion:^(BOOL finished) {
                             }];
            break;
        }
            
        default:
            break;
    }
}

- (CGRect)shutterDecorationViewControllerViewFrame
{
    CGPoint onscreenOrigin;
    if (self.spineLocation == FRShutterViewControllerSpineLocationMin) {
        onscreenOrigin = [self.shutterDecorationViewController originMax];
    } else if (self.spineLocation == FRShutterViewControllerSpineLocationMax) {
        onscreenOrigin = [self.shutterDecorationViewController originMin];
    } else {
        NSAssert(false, @"unknown spine location");
    }
    const CGRect onscreenFrame = CGRectMake(onscreenOrigin.x,
                                            onscreenOrigin.y,
                                            self.view.bounds.size.width,
                                            self.view.bounds.size.height);
    return onscreenFrame;
}

#pragma mark - Public API

- (void)closeDetailViewControllerAnimated:(BOOL)animated
{
    if (self.shutterViewController == nil) {
        /* nothing to do */
        return;
    }
    
    /* remove old one */
    FRShutterDecorationViewController *oldVc = self.shutterDecorationViewController;
    self.shutterDecorationViewController = nil;
    self.panGR.delegate = nil;
    self.panGR = nil;
    
    CGRect f = oldVc.view.frame;
    f.origin = [self offscreenOrigin];
    [UIView animateWithDuration:animated ? 0.5 : 0.0
                     animations:^{
                         oldVc.view.frame = f;
                     }
                     completion:^(BOOL finished) {
                         [oldVc willMoveToParentViewController:nil];
                         [oldVc.view removeFromSuperview];
                         [oldVc removeFromParentViewController];
                     }];
}

- (void)openDetailViewController:(UIViewController *)vc animated:(BOOL)animated
{
    if (self.shutterDecorationViewController != nil) {
        [self closeDetailViewControllerAnimated:animated];
    }
    NSAssert(self.shutterDecorationViewController == nil, @"self.shutterDecorationViewController != nil");
    
    if (vc == nil) {
        /* we're done :-) */
        return;
    }
    /* no shutter controller yet, create new one */
    self.shutterDecorationViewController =
        [[FRShutterDecorationViewController alloc] initWithContentViewController:vc
                                                           shutterDecorationView:self.customDecorationView];
    [self addChildViewController:self.shutterDecorationViewController];
    CGPoint offscreenOrigin = [self offscreenOrigin];
    const CGRect offscreenFrame = CGRectMake(offscreenOrigin.x,
                                             offscreenOrigin.y,
                                             self.view.bounds.size.width,
                                             self.view.bounds.size.height);
    
    const CGRect onscreenFrame = [self shutterDecorationViewControllerViewFrame];
    self.shutterDecorationViewController.view.frame = offscreenFrame;
    [self.view addSubview:self.shutterDecorationViewController.view];
    
    [UIView animateWithDuration:animated ? 0.5 : 0.0
                     animations:^{
                         self.shutterDecorationViewController.view.frame = onscreenFrame;
                     }
                     completion:^(BOOL finished) {
                         self.panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
                         [self.shutterDecorationViewController.decorationView addGestureRecognizer:self.panGR];
                         [self.shutterDecorationViewController didMoveToParentViewController:self];
                     }];
}

@synthesize orientation = _orientation;
@synthesize spineLocation = _spineLocation;
@synthesize masterViewController = _masterViewController;
@synthesize shutterDecorationViewController = _shutterDecorationViewController;
@synthesize panGR = _panGR;
@synthesize customDecorationView = _customDecorationView;

@end
