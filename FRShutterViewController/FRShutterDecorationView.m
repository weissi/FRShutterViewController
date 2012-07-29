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
    if (self->_savedGradient != NULL) {
        CGGradientRelease(self->_savedGradient);
    }
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
