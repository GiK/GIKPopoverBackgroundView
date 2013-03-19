//
//  GIKRenderedImagesPopoverBackgroundView.m
//  GIKPopoverBackgroundView
//
//  Created by Chris Flesner on 3/18/13.
//  Copyright (c) 2013 Gordon Hughes. All rights reserved.
//

#import "GIKRenderedImagesPopoverBackgroundView.h"

@implementation GIKRenderedImagesPopoverBackgroundView

- (UIColor *)popoverBorderColor
{
    return [UIColor colorWithRed:0.439216 green:0.431373 blue:0.407843 alpha:1];
}

- (UIColor *)popoverGradientFromColor
{
    return [UIColor colorWithRed:0.980392 green:0.976471 blue:0.964706 alpha:1];
}

- (UIColor *)popoverGradientToColor
{
    return [UIColor colorWithRed:0.858824 green:0.835294 blue:0.807843 alpha:1];
}

@end
