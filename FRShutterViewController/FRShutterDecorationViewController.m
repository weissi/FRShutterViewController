//
//  FRShutterController.m
//  FRShutterViewController
//
//  Created by Johannes Weiß on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FRShutterDecorationViewController.h"
#import "FRShutterDecorationView.h"
#import "FRShutterViewController.h"

#define FRShutterViewControllerShutterDecorationSize ((CGFloat)44)

@interface FRShutterDecorationViewController ()

@property (nonatomic, readwrite, strong) UIViewController *contentViewController;
@property (nonatomic, readwrite, strong) FRShutterDecorationView *decorationView;

@end

@implementation FRShutterDecorationViewController

#pragma mark - init/dealloc

- (id)initWithContentViewController:(UIViewController *)vc {
    if ((self = [super init])) {
        NSAssert(vc != nil, @"FRShutterDecorationViewController: content view controller is nil");
        _contentViewController = vc;
        
        [self attachContentViewController];
    }
    
    return self;
}

- (void)dealloc
{
    [self detachContentViewController];
}

#pragma mark - internal methods

- (FRShutterViewController *)shutterViewController
{
    UIViewController *parent = self.parentViewController;
    NSAssert([parent class] == [FRShutterViewController class], @"FRShutterDecorationViewController's parent wrong");
    return (FRShutterViewController *)parent;
}

- (CGRect)decorationFrame
{
    FRShutterViewController *svc = [self shutterViewController];
    const CGSize allSize = self.view.frame.size;
    
    switch(svc.orientation + (10 * svc.spineLocation)) {
        case FRShutterViewControllerOrientationHorizontal + 10 * FRShutterViewControllerSpineLocationMin: {
            return CGRectMake(allSize.width - FRShutterViewControllerShutterDecorationSize,
                              0,
                              FRShutterViewControllerShutterDecorationSize,
                              allSize.height);
        }
        case FRShutterViewControllerOrientationHorizontal + 10 * FRShutterViewControllerSpineLocationMax: {
            return CGRectMake(0,
                              0,
                              FRShutterViewControllerShutterDecorationSize,
                              allSize.height);
        }
        case FRShutterViewControllerOrientationVertical + 10 * FRShutterViewControllerSpineLocationMin: {
            return CGRectMake(0,
                              allSize.height - FRShutterViewControllerShutterDecorationSize,
                              allSize.width,
                              FRShutterViewControllerShutterDecorationSize);
        }
        case FRShutterViewControllerOrientationVertical + 10 * FRShutterViewControllerSpineLocationMax: {
            return CGRectMake(0,
                              0,
                              allSize.width,
                              FRShutterViewControllerShutterDecorationSize);
        }
        default:
            NSAssert(false, @"decorationFrame: unknown orientation / spine location");
    }
    return CGRectZero;
}

- (CGRect)contentFrame
{
    FRShutterViewController *svc = [self shutterViewController];
    const CGSize allSize = self.view.frame.size;
    
    switch(svc.orientation + (10 * svc.spineLocation)) {
        case FRShutterViewControllerOrientationHorizontal + 10 * FRShutterViewControllerSpineLocationMin: {
            return CGRectMake(0,
                              0,
                              allSize.width - FRShutterViewControllerShutterDecorationSize,
                              allSize.height);
        }
        case FRShutterViewControllerOrientationHorizontal + 10 * FRShutterViewControllerSpineLocationMax: {
            return CGRectMake(FRShutterViewControllerShutterDecorationSize,
                              0,
                              allSize.width - FRShutterViewControllerShutterDecorationSize,
                              allSize.height);
        }
        case FRShutterViewControllerOrientationVertical + 10 * FRShutterViewControllerSpineLocationMin: {
            return CGRectMake(0,
                              0,
                              allSize.width,
                              allSize.height - FRShutterViewControllerShutterDecorationSize);
        }
        case FRShutterViewControllerOrientationVertical + 10 * FRShutterViewControllerSpineLocationMax: {
            return CGRectMake(0,
                              FRShutterViewControllerShutterDecorationSize,
                              allSize.width,
                              allSize.height - FRShutterViewControllerShutterDecorationSize);
        }
        default:
            NSAssert(false, @"contentFrame: unknown orientation / spine location");
    }
    return CGRectZero;
}

- (CGPoint)originMin
{
    FRShutterViewController *svc = [self shutterViewController];
    const CGSize allSize = self.view.frame.size;
    
    switch(svc.orientation + (10 * svc.spineLocation)) {
        case FRShutterViewControllerOrientationHorizontal + 10 * FRShutterViewControllerSpineLocationMin: {
            return CGPointMake(-allSize.width+FRShutterViewControllerShutterDecorationSize,
                               0);
        }
        case FRShutterViewControllerOrientationHorizontal + 10 * FRShutterViewControllerSpineLocationMax: {
            return CGPointMake(0,
                               0);
        }
        case FRShutterViewControllerOrientationVertical + 10 * FRShutterViewControllerSpineLocationMin: {
            return CGPointMake(0,
                               -allSize.height+FRShutterViewControllerShutterDecorationSize);
        }
        case FRShutterViewControllerOrientationVertical + 10 * FRShutterViewControllerSpineLocationMax: {
            return CGPointMake(0,
                               0);
        }
        default:
            NSAssert(false, @"originMin: unknown orientation / spine location");
    }
    return CGPointZero;
}

- (CGPoint)originMax
{
    FRShutterViewController *svc = [self shutterViewController];
    const CGSize allSize = self.view.frame.size;
    
    switch(svc.orientation + (10 * svc.spineLocation)) {
        case FRShutterViewControllerOrientationHorizontal + 10 * FRShutterViewControllerSpineLocationMin: {
            return CGPointMake(0,
                               0);
        }
        case FRShutterViewControllerOrientationHorizontal + 10 * FRShutterViewControllerSpineLocationMax: {
            return CGPointMake(allSize.width-FRShutterViewControllerShutterDecorationSize,
                               0);
        }
        case FRShutterViewControllerOrientationVertical + 10 * FRShutterViewControllerSpineLocationMin: {
            return CGPointMake(0,
                               0);
        }
        case FRShutterViewControllerOrientationVertical + 10 * FRShutterViewControllerSpineLocationMax: {
            return CGPointMake(0,
                               allSize.height-FRShutterViewControllerShutterDecorationSize);
        }
        default:
            NSAssert(false, @"originMax: unknown orientation / spine location");
    }
    return CGPointZero;
}

- (void)doViewLayout {
    self.decorationView.frame = [self decorationFrame];
    self.contentViewController.view.frame = [self contentFrame];
}

- (void)attachContentViewController
{
    [self addChildViewController:self.contentViewController];
    [self.contentViewController didMoveToParentViewController:self];
}

- (void)detachContentViewController
{
    [self.contentViewController willMoveToParentViewController:nil];
    [self.contentViewController removeFromParentViewController];
}

#pragma mark - UIViewController interface methods

- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.decorationView = [[FRShutterDecorationView alloc] init];
    
    [self.view addSubview:self.decorationView];
    [self.view addSubview:self.contentViewController.view];
}

- (void)viewWillLayoutSubviews {
    self.view.layer.shadowRadius = 10.0;
    self.view.layer.shadowOffset = CGSizeMake(-2.0, -3.0);
    self.view.layer.shadowOpacity = 0.5;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    
    [self doViewLayout];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    NSLog(@"FRShutterDecorationController (%@): viewDidUnload", self);
    
    self.decorationView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@synthesize contentViewController = _contentViewController;
@synthesize decorationView = _decorationView;

@end
