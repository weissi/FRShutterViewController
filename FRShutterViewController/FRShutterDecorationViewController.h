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
@property (nonatomic, readonly, strong) UIViewController *contentViewController;

@end
