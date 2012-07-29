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

#import <UIKit/UIKit.h>
#import "FRShutterViewController.h"
#import "FRShutterDecorationViewController.h"
#import "FRShutterDecorationView.h"

@interface FRShutterViewController ()

@property (nonatomic, readwrite, strong) FRShutterDecorationViewController *shutterDecorationViewController;
@property (nonatomic, readwrite, strong) UIPanGestureRecognizer *panGR;
@property (nonatomic, readwrite, strong) UIView *customDecorationView;

@end

typedef enum {
    Left,
    Right,
    Any
} Direction;

#define kFRShutterViewControllerMinimalFlingVelocity ((CGFloat)400)

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
        _snappingPositionsPortrait = [NSSet set];
    }

    [self attachMasterViewController];

    return self;
}

- (void)dealloc
{
    [self detachGestureRecognizer];
    [self detachMasterViewController];
}

#pragma mark - getters / setters
- (void)setSnappingPointsPortrait:(NSSet *)snappingPointsPortrait
{
    if (snappingPointsPortrait == nil) {
        _snappingPositionsPortrait = [NSSet set];
    } else {
        _snappingPositionsPortrait = [snappingPointsPortrait copy];
    }
}

- (void)setSnappingPointsLandscape:(NSSet *)snappingPointsLandscape
{
    if (snappingPointsLandscape == nil) {
        _snappingPositionsLandscape = [NSSet set];
    } else {
        _snappingPositionsLandscape = [snappingPointsLandscape copy];
    }
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
    self.masterViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                                      UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.masterViewController.view];

    if (self.shutterDecorationViewController) {
        self.shutterDecorationViewController.view.frame = [self frameFromPosition:[self fullyOpenPosition]];
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

- (void)doHorizontalShutter:(void (^)())blockH verticalShutter:(void (^)())blockV
{
    switch (self.orientation) {
        case FRShutterViewControllerOrientationHorizontal: {
            blockH();
            break;
        }

        case FRShutterViewControllerOrientationVertical: {
            blockV();
            break;
        }

        default:
            NSAssert(false, @"BUG: unknown orientation");
            break;
    }
}

- (void)doLayout
{
    if (self.shutterDecorationViewController != nil) {
        CGRect f = self.shutterDecorationViewController.view.frame;
        f.size = self.view.bounds.size;
        self.shutterDecorationViewController.view.frame = f; /* don't remove this line! */
        f = [self frameFromPosition:[self nearestSnappingPositionInDirection:Any]];
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

- (NSSet *)snappingPositionsForCurrentInterfaceOrientation
{
    switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            return self.snappingPositionsLandscape;
        }
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        default: {
            return self.snappingPositionsPortrait;
        }
    }
}

+ (CGFloat)distancePosition:(CGFloat)pos toReference:(CGFloat)ref inDirection:(Direction)direction
{
    switch (direction) {
        case Left: {
            if (ref > pos) {
                return MAXFLOAT;
            } else {
                return fabsf(ref - pos);
            }
        }
        case Right: {
            if (ref < pos) {
                return MAXFLOAT;
            } else {
                return fabsf(ref - pos);
            }
        }
        default: {
            /* to here */
            return fabsf(ref - pos);
        }
    }

}

- (CGFloat)nearestSnappingPositionInDirection:(Direction)direction
{
    const CGFloat curPos = [self positionFromFrame:self.shutterDecorationViewController.view.frame];
    return [self nearestSnappingPositionFromPosition:curPos
                                         inDirection:direction];
}

- (CGFloat)nearestSnappingPositionFromPosition:(CGFloat)curPos inDirection:(Direction)direction
{

    CGFloat nearestSnappingPositionInSet = -1;
    CGFloat distNearestSnappingPointInSet = MAXFLOAT;

    const CGFloat min = 0;
    const CGFloat max = [self.shutterDecorationViewController positionMax];
    const CGFloat distToMin = [FRShutterViewController distancePosition:curPos toReference:min inDirection:direction];
    const CGFloat distToMax = [FRShutterViewController distancePosition:curPos toReference:max inDirection:direction];

    if (distToMax < distToMin) {
        nearestSnappingPositionInSet = max;
        distNearestSnappingPointInSet = distToMax;
    } else {
        nearestSnappingPositionInSet = min;
        distNearestSnappingPointInSet = distToMin;
    }

    for (NSNumber *posNum in [self snappingPositionsForCurrentInterfaceOrientation]) {
        const CGFloat pos = [posNum floatValue];
        const CGFloat dist = [FRShutterViewController distancePosition:curPos toReference:pos inDirection:direction];

        if (dist < distNearestSnappingPointInSet) {
            nearestSnappingPositionInSet = pos;
            distNearestSnappingPointInSet = dist;
        }
    }

    return nearestSnappingPositionInSet;
}

- (void)attachGestureRecognizer
{
    self.panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
}

- (void)detachGestureRecognizer
{
    [self.panGR removeTarget:self action:NULL];
    self.panGR.delegate = nil;
    self.panGR = nil;
}

- (CGFloat)fullyOpenPosition
{
    switch (self.spineLocation) {
        case FRShutterViewControllerSpineLocationMin:
            /* HACK: Just use the maximum possible screen position */
            return 1024;
        case FRShutterViewControllerSpineLocationMax:
            /* HACK: Just use the minimum possible screen position */
            return 0;
    }
}

- (CGRect)frameFromPosition:(CGFloat)pos
{
    const CGSize allSize = self.view.bounds.size;
    CGPoint p;

    switch(self.orientation + (10 * self.spineLocation)) {
        case FRShutterViewControllerOrientationHorizontal + 10 * FRShutterViewControllerSpineLocationMin: {
            p = CGPointMake(-allSize.width+pos+FRShutterViewControllerShutterDecorationSize, 0);
            break;
        }
        case FRShutterViewControllerOrientationHorizontal + 10 * FRShutterViewControllerSpineLocationMax: {
            p = CGPointMake(pos, 0);
            break;
        }
        case FRShutterViewControllerOrientationVertical + 10 * FRShutterViewControllerSpineLocationMin: {
            p = CGPointMake(0, -allSize.height+pos+FRShutterViewControllerShutterDecorationSize);
            break;
        }
        case FRShutterViewControllerOrientationVertical + 10 * FRShutterViewControllerSpineLocationMax: {
            p = CGPointMake(0, pos);
            break;
        }
        default:
            NSAssert(false, @"originMin: unknown orientation / spine location");
    }

    const CGRect f = CGRectMake(p.x, p.y, allSize.width, allSize.height);
    return f;
}

- (CGFloat)positionFromFrame:(CGRect)frame
{
    const CGSize allSize = self.view.bounds.size;
    const CGPoint p = frame.origin;

    switch(self.orientation + (10 * self.spineLocation)) {
        case FRShutterViewControllerOrientationHorizontal + 10 * FRShutterViewControllerSpineLocationMin: {
            return p.x+allSize.width-FRShutterViewControllerShutterDecorationSize;
        }
        case FRShutterViewControllerOrientationHorizontal + 10 * FRShutterViewControllerSpineLocationMax: {
            return p.x;
        }
        case FRShutterViewControllerOrientationVertical + 10 * FRShutterViewControllerSpineLocationMin: {
            return p.y+allSize.height-FRShutterViewControllerShutterDecorationSize;
        }
        case FRShutterViewControllerOrientationVertical + 10 * FRShutterViewControllerSpineLocationMax: {
            return p.y;
        }
        default:
            NSAssert(false, @"positionFromFrame: unknown orientation / spine location");
            return 0;
    }
}

#pragma mark - UIGestureRecognizer delegate interface

- (void)handleGesture:(UIPanGestureRecognizer *)g
{
    UIView *v = self.shutterDecorationViewController.view;
    __block CGRect f = v.frame;

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
            __block CGFloat newShutterCoordinate = -1;

            [self doHorizontalShutter:^{
                CGFloat xTranslation = [g translationInView:v].x;
                f.origin.x += xTranslation;
                v.frame = f;
                newShutterCoordinate = v.frame.origin.x;
            } verticalShutter:^{
                CGFloat yTranslation = [g translationInView:v].y;
                f.origin.y += yTranslation;
                v.frame = f;
                newShutterCoordinate = v.frame.origin.y;
            }];

            const CGFloat newShutterPosition = [self positionFromFrame:f];

            if ([self.delegate respondsToSelector:@selector(shutterWillMoveToPosition:animated:duration:)]) {
                [self.delegate shutterWillMoveToPosition:newShutterPosition animated:NO duration:0];
            }
            if ([self.delegate respondsToSelector:@selector(shutterDidMoveToPosition:)]) {
                [self.delegate shutterDidMoveToPosition:newShutterPosition];
            }
            [g setTranslation:CGPointZero inView:v];
            break;
        }

        case UIGestureRecognizerStateEnded: {
            //NSLog(@"UIGestureRecognizerStateEnded");
            CGFloat velocity;
            CGFloat animationVelocity = -1;
            CGFloat currentShutterPosition = -1;

            switch (self.orientation) {
                case FRShutterViewControllerOrientationHorizontal: {
                    velocity = [g velocityInView:v].x;
                    currentShutterPosition = f.origin.x;
                    break;
                }
                case FRShutterViewControllerOrientationVertical: {
                    velocity = [g velocityInView:v].y;
                    currentShutterPosition = f.origin.y;
                    break;
                }
                default:
                    NSAssert(false, @"unknown orientation");
            }

            CGFloat newShutterPosition;
            if (fabsf(velocity) > kFRShutterViewControllerMinimalFlingVelocity) {
                if (velocity > 0) {
                    newShutterPosition = [self nearestSnappingPositionInDirection:Right];
                } else {
                    newShutterPosition = [self nearestSnappingPositionInDirection:Left];
                }
                animationVelocity = fabsf(velocity);
            } else {
                newShutterPosition = [self nearestSnappingPositionInDirection:Any];
                animationVelocity = kFRShutterViewControllerMinimalFlingVelocity;
            }

            const CGFloat duration = fabsf(newShutterPosition - currentShutterPosition) / animationVelocity;
            if ([self.delegate respondsToSelector:@selector(shutterWillMoveToPosition:animated:duration:)]) {
                [self.delegate shutterWillMoveToPosition:newShutterPosition animated:YES duration:duration];
            }

            f = [self frameFromPosition:newShutterPosition];
            [UIView animateWithDuration:duration
                                  delay:0.0
                                options:UIViewAnimationCurveEaseOut
                             animations:^{
                                 v.frame = f;
                             }
                             completion:^(BOOL finished) {
                                 if ([self.delegate respondsToSelector:@selector(shutterDidMoveToPosition:)]) {
                                     [self.delegate shutterDidMoveToPosition:newShutterPosition];
                                 }
                             }];
            break;
        }

        default:
            break;
    }
}

#pragma mark - Public API

- (void)closeDetailViewControllerAnimated:(BOOL)animated
{
    if (self.shutterViewController == nil) {
        /* nothing to do */
        return;
    }

    /* remove old one */
    if ([self.delegate respondsToSelector:@selector(willCloseDetailViewController:)]) {
        [self.delegate willCloseDetailViewController:self.shutterDecorationViewController.contentViewController];
    }

    FRShutterDecorationViewController *oldVc = self.shutterDecorationViewController;
    self.shutterDecorationViewController = nil;
    [self detachGestureRecognizer];

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

                         if ([self.delegate respondsToSelector:@selector(didCloseDetailViewController)]) {
                             [self.delegate didCloseDetailViewController];
                         }
                     }];
}

- (void)openDetailViewControllerFully:(UIViewController *)vc animated:(BOOL)animated
{
    [self openDetailViewController:vc snapNear:[self fullyOpenPosition] animated:animated];
}

- (void)openDetailViewController:(UIViewController *)vc snapNear:(CGFloat)position animated:(BOOL)animated
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
    if ([self.delegate respondsToSelector:@selector(willOpenDetailViewController:)]) {
        [self.delegate willOpenDetailViewController:vc];
    }

    self.shutterDecorationViewController =
        [[FRShutterDecorationViewController alloc] initWithContentViewController:vc
                                                           shutterDecorationView:self.customDecorationView];
    [self addChildViewController:self.shutterDecorationViewController];
    CGPoint offscreenOrigin = [self offscreenOrigin];
    const CGRect offscreenFrame = CGRectMake(offscreenOrigin.x,
                                             offscreenOrigin.y,
                                             self.view.bounds.size.width,
                                             self.view.bounds.size.height);

    self.shutterDecorationViewController.view.frame = offscreenFrame;
    const CGFloat onscreenPosition = [self nearestSnappingPositionFromPosition:position inDirection:Any];
    const CGRect onscreenFrame = [self frameFromPosition:onscreenPosition];
    [self.view addSubview:self.shutterDecorationViewController.view];

    const NSTimeInterval animationDuration = animated ? 0.5 : 0.0;

    if ([self.delegate respondsToSelector:@selector(shutterWillMoveToPosition:animated:duration:)]) {
        [self.delegate shutterWillMoveToPosition:onscreenPosition animated:animated duration:animationDuration];
    }

    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.shutterDecorationViewController.view.frame = onscreenFrame;
                     }
                     completion:^(BOOL finished) {
                         [self attachGestureRecognizer];
                         [self.shutterDecorationViewController.decorationView addGestureRecognizer:self.panGR];
                         [self.shutterDecorationViewController didMoveToParentViewController:self];
                         if ([self.delegate respondsToSelector:@selector(didOpenDetailViewController:)]) {
                             [self.delegate didOpenDetailViewController:vc];
                         }
                         if ([self.delegate respondsToSelector:@selector(shutterDidMoveToPosition:)]) {
                             [self.delegate shutterDidMoveToPosition:onscreenPosition];
                         }
                     }];
}

@synthesize orientation = _orientation;
@synthesize spineLocation = _spineLocation;
@synthesize masterViewController = _masterViewController;
@synthesize shutterDecorationViewController = _shutterDecorationViewController;
@synthesize panGR = _panGR;
@synthesize customDecorationView = _customDecorationView;
@synthesize delegate = _delegate;
@synthesize snappingPositionsPortrait = _snappingPositionsPortrait;
@synthesize snappingPositionsLandscape = _snappingPositionsLandscape;

@end
