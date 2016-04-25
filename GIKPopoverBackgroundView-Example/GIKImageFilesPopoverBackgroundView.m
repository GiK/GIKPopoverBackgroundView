//
//  GIKImageFilesPopoverBackgroundView.m
//  GIKPopoverBackgroundView
//
//  Created by Chris Flesner on 3/18/13.
//  Copyright (c) 2013 Gordon Hughes. All rights reserved.
//

#import "GIKImageFilesPopoverBackgroundView.h"

@implementation GIKImageFilesPopoverBackgroundView

- (UIEdgeInsets)arrowSideTopInsets
{
    UIEdgeInsets insets = {43.0,  9.0,  9.0, 27.0};
    return insets;
}

- (UIImage *)arrowUpImage
{
    return [UIImage imageNamed:@"PopoverBackgroundArrowUp.png"];
}

- (UIImage *)arrowUpRightImage
{
    return [UIImage imageNamed:@"PopoverBackgroundArrowUpRight.png"];
}

- (UIImage *)arrowDownImage
{
    return [UIImage imageNamed:@"PopoverBackgroundArrowDown.png"];
}

- (UIImage *)arrowDownRightImage
{
    return [UIImage imageNamed:@"PopoverBackgroundArrowDownRight.png"];
}

- (UIImage *)arrowSideImage
{
    return [UIImage imageNamed:@"PopoverBackgroundArrowSide.png"];
}

- (UIImage *)arrowSideTopImage
{
    return [UIImage imageNamed:@"PopoverBackgroundArrowSideTop.png"];
}

- (UIImage *)arrowSideBottomImage
{
    return [UIImage imageNamed:@"PopoverBackgroundArrowSideBottom.png"];
}

@end
