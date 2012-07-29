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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UIViewController+FRShutterViewController.h"
#import "FRShutterViewControllerDelegate.h"

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
    UIView *_customDecorationView;
    NSSet *_snappingPositionsPortrait;
    NSSet *_snappingPositionsLandscape;
    id<FRShutterViewControllerDelegate> __weak _delegate;
}

- (id)initWithMasterViewController:(UIViewController *)master
                shutterOrientation:(FRShutterViewControllerOrientation)orientation
                     spineLocation:(FRShutterViewControllerSpineLocation)spineLocation;

- (id)initWithMasterViewController:(UIViewController *)master
                shutterOrientation:(FRShutterViewControllerOrientation)orientation
                     spineLocation:(FRShutterViewControllerSpineLocation)spineLocation
             shutterDecorationView:(UIView *)customDecorationView;

- (void)openDetailViewControllerFully:(UIViewController *)vc animated:(BOOL)animated;

- (void)openDetailViewController:(UIViewController *)vc snapNear:(CGFloat)position animated:(BOOL)animated;

- (void)closeDetailViewControllerAnimated:(BOOL)animated;

@property (nonatomic, readonly) FRShutterViewControllerOrientation orientation;
@property (nonatomic, readonly) FRShutterViewControllerSpineLocation spineLocation;
@property (nonatomic, readonly, strong) UIViewController *masterViewController;
@property (nonatomic, weak) id<FRShutterViewControllerDelegate> delegate;
@property (nonatomic, strong) NSSet *snappingPositionsPortrait;
@property (nonatomic, strong) NSSet *snappingPositionsLandscape;


@end
