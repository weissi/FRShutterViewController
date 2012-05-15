//
//  FRShutterDecorationView.h
//  FRShutterViewController
//
//  Created by Johannes Weiß on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRShutterDecorationView : UIView {
    CGGradientRef _savedGradient;
    @private
    UIRectCorner _roundedCorners;
}

- (id)initWithFrame:(CGRect)frame roundedCorners:(UIRectCorner)corners;

@end
