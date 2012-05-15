/*     This file is part of FRShutterViewController.
 *
 * FRShutterViewController is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FRShutterViewController is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with FRShutterViewController.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 *  Copyright (c) 2012, Johannes Weiß <weiss@tux4u.de> for factis research GmbH.
 */

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
    UIView *_customDecorationView;
}

- (id)initWithMasterViewController:(UIViewController *)master
                shutterOrientation:(FRShutterViewControllerOrientation)orientation
                     spineLocation:(FRShutterViewControllerSpineLocation)spineLocation;

- (id)initWithMasterViewController:(UIViewController *)master
                shutterOrientation:(FRShutterViewControllerOrientation)orientation
                     spineLocation:(FRShutterViewControllerSpineLocation)spineLocation
             shutterDecorationView:(UIView *)customDecorationView;

- (void)openDetailViewController:(UIViewController *)vc animated:(BOOL)animated;

- (void)closeDetailViewControllerAnimated:(BOOL)animated;

@property (nonatomic, readonly) FRShutterViewControllerOrientation orientation;
@property (nonatomic, readonly) FRShutterViewControllerSpineLocation spineLocation;
@property (nonatomic, readonly, strong) UIViewController *masterViewController;

@end
