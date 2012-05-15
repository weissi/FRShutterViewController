//
//  FRShutterDecorationView.m
//  FRShutterViewController
//
//  Created by Johannes Weiß on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
