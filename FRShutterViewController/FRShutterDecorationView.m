//
//  FRShutterDecorationView.m
//  FRShutterViewController
//
//  Created by Johannes Weiß on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FRShutterDecorationView.h"

@implementation FRShutterDecorationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        UIImage *img = [UIImage imageNamed:@"akte.png"];
        UIImageView *v = [[UIImageView alloc] initWithImage:img];
        [self addSubview:v];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
