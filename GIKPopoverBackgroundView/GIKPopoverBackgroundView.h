//
//  GIKPopoverBackgroundView.h
//
//  Created by Gordon Hughes on 1/7/13.
//  Copyright (c) 2013 Gordon Hughes. All rights reserved.
//

// To use, import this header in your class and add the following after the popover controller's declaration/instantiation:

// popoverController.popoverBackgroundViewClass = [GIKPopoverBackgroundView class];

// Layout of images will be handled automatically, and it works with all values of UIPopoverArrowDirection.

#import <UIKit/UIKit.h>

/**
 Image-specific values for calulating the background's layout.
 */
static const CGFloat kPopoverArrowWidth         = 37.0; // Returned by +arrowBase, irrespective of orientation. The length of the base of the arrow's triangle.
static const CGFloat kPopoverArrowHeight        = 19.0; // Returned by +arrowHeight, irrespective of orientation. The height of the arrow from base to tip.
static const CGFloat kPopoverCornerRadius       = 7.0;  // Used in a bounds check to determine if the arrow is too close to the popover's edge.
static const CGFloat kSideArrowCenterOffset     = 7.0;  // Added to the arrow's center for ...Side.png image to account for the taller top half.

/**
 Filenames for the seven required background images. If a popover's arrowDirection is UIPopoverArrowDirectionLeft, the equivalent right-facing image will be mirrored.
 */
static NSString * const kArrowUp         = @"PopoverBackgroundArrowUp.png";
static NSString * const kArrowUpRight    = @"PopoverBackgroundArrowUpRight.png";
static NSString * const kArrowDown       = @"PopoverBackgroundArrowDown.png";
static NSString * const kArrowDownRight  = @"PopoverBackgroundArrowDownRight.png";
static NSString * const kArrowSide       = @"PopoverBackgroundArrowSide.png";
static NSString * const kArrowSideTop    = @"PopoverBackgroundArrowSideTop.png";
static NSString * const kArrowSideBottom = @"PopoverBackgroundArrowSideBottom.png";

/**
 Content and background insets.
 */
static const UIEdgeInsets kPopoverEdgeInsets = { 8.0,  8.0,  8.0,  8.0}; // Distance between the edge of the background view and the edge of the content view.

/**
 Image-specific cap insets which specify a 1 point by 1 point area to be stretched. Changing the background images will likely require a different set of insets.
 */
static const UIEdgeInsets kArrowUpInsets            = {41.0,  9.0,  9.0, 47.0};
static const UIEdgeInsets kArrowUpRightInsets       = {41.0,  9.0,  9.0, 42.0};
static const UIEdgeInsets kArrowDownInsets          = {23.0,  9.0, 27.0, 47.0};
static const UIEdgeInsets kArrowDownRightInsets     = {23.0,  9.0, 27.0, 42.0};
static const UIEdgeInsets kArrowSideInsets          = {24.0,  9.0, 47.0, 27.0};
static const UIEdgeInsets kArrowSideTopInsets       = {43.0,  9.0,  9.0, 27.0};
static const UIEdgeInsets kArrowSideBottomInsets    = {23.0,  9.0, 43.0, 27.0};

static const CGFloat kSecondHalfBottomInset         = 9.0; // Value for .bottom inset in the second half of a two-part vertical stretch operation.
static const CGFloat kSecondHalfRightInset          = 9.0; // Value for .right inset in the seconf half of a two-part horizontal stretch operation.

@interface GIKPopoverBackgroundView : UIPopoverBackgroundView
{
    CGFloat _arrowOffset;
    UIPopoverArrowDirection _arrowDirection;
}

@property (nonatomic, assign) CGFloat arrowOffset;
@property (nonatomic, assign) UIPopoverArrowDirection arrowDirection;

+ (CGFloat)arrowHeight;
+ (CGFloat)arrowBase;
+ (UIEdgeInsets)contentViewInsets;

@end
