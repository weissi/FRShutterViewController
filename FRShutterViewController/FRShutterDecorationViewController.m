/*
 * This file is part of FRShutterViewController.
 *
 * Copyright (c) 2012, Johannes Weiß <weiss@tux4u.de>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * The name of the author may not be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <QuartzCore/QuartzCore.h>
#import "FRShutterDecorationViewController.h"
#import "FRShutterDecorationView.h"
#import "FRShutterViewController.h"

@interface FRShutterDecorationViewController ()

@property (nonatomic, readwrite, strong) UIViewController *contentViewController;
@property (nonatomic, readwrite, strong) UIView *decorationView;
@property (nonatomic, readonly, strong) UIView *customDecorationView;

@end

@implementation FRShutterDecorationViewController

#pragma mark - init/dealloc

- (id)initWithContentViewController:(UIViewController *)vc shutterDecorationView:(UIView *)customDecorationView
{
    if ((self = [super init])) {
        NSAssert(vc != nil, @"FRShutterDecorationViewController: content view controller is nil");
        _contentViewController = vc;
        _customDecorationView = customDecorationView;

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

- (CGFloat)positionMax
{
    FRShutterViewController *svc = [self shutterViewController];
    const CGSize allSize = self.view.frame.size;

    switch(svc.orientation) {
        case FRShutterViewControllerOrientationHorizontal: {
            return allSize.width - FRShutterViewControllerShutterDecorationSize;
        }
        case FRShutterViewControllerOrientationVertical: {
            return allSize.height - FRShutterViewControllerShutterDecorationSize;
        }
    }
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

    if (self.customDecorationView == nil) {
        self.decorationView = [[FRShutterDecorationView alloc] initWithFrame:CGRectZero roundedCorners:0];
    } else {
        self.decorationView = self.customDecorationView;
    }

    [self.view addSubview:self.decorationView];
    [self.view addSubview:self.contentViewController.view];
}

- (void)viewDidLoad
{
    self.contentViewController.view.clipsToBounds = YES;
}

- (void)viewWillLayoutSubviews {
    self.view.layer.shadowRadius = 10.0;
    self.view.layer.shadowOffset = CGSizeMake(-2.0, -3.0);
    self.view.layer.shadowOpacity = 0.5;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;

    [self doViewLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
@synthesize customDecorationView = _customDecorationView;

@end
