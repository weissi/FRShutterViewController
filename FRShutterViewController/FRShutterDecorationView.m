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

#import "FRShutterDecorationView.h"

@implementation FRShutterDecorationView

- (id)initWithFrame:(CGRect)frame roundedCorners:(UIRectCorner)corners
{
    self = [super initWithFrame:frame];
    if (self) {
        _roundedCorners = corners;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc
{
    self->_savedGradient = NULL;
}

- (CGGradientRef)gradient {
    if (NULL == _savedGradient) {
        CGFloat colors[12] = {
            223.0/255.0, 225.0/255.0, 230.0/255.0, 1.0,
            167.0/244.0, 171.0/255.0, 184.0/255.0, 1.0,
            223.0/255.0, 225.0/255.0, 230.0/255.0, 1.0,
        };
        CGFloat locations[3] = { 0.05f, 0.5f, 0.95f };

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

        _savedGradient = CGGradientCreateWithColorComponents(colorSpace,
                                                             colors,
                                                             locations,
                                                             3);

        CGColorSpaceRelease(colorSpace);
    }

    return _savedGradient;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                               byRoundingCorners:_roundedCorners cornerRadii:CGSizeMake(10, 10)];
    [path addClip];

    CGPoint start;
    CGPoint end;
    if (self.bounds.size.width > self.bounds.size.height) {
        start = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds));
        end  = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds));
    } else {
        start = CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMidY(self.bounds));
        end  = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMidY(self.bounds));
    }

    CGGradientRef gradient = [self gradient];

    CGContextDrawLinearGradient(ctx, gradient, start, end, 0);
}

@end
