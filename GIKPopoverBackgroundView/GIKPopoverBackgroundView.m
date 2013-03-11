//
//  GIKPopoverBackgroundView.m
//
//  Created by Gordon Hughes on 1/7/13.
//  Copyright (c) 2013 Gordon Hughes. All rights reserved.
//

#import "GIKPopoverBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

// A struct containing the min and max horizontal and vertical positions for the popover arrow. If the arrow's position exceeds these limits, the PopoverBackgroundArrow[UpRight|DownRight|SideTop|SideBottom].png images are drawn.
struct GIKPopoverExtents {
    CGFloat left;
    CGFloat right;
    CGFloat top;
    CGFloat bottom;
};
typedef struct GIKPopoverExtents GIKPopoverExtents;

@interface GIKPopoverBackgroundView () {
    GIKPopoverExtents _popoverExtents;
    CGFloat _halfBase;
    CGFloat _arrowCenter;
}

@property (strong, nonatomic) UIImageView *popoverBackground;

@end


@implementation GIKPopoverBackgroundView

@synthesize arrowOffset = _arrowOffset;
@synthesize arrowDirection = _arrowDirection;


#pragma mark - UIPopoverBackgroundView required values

+ (UIEdgeInsets)contentViewInsets
{
    return kPopoverEdgeInsets;
}

+ (CGFloat)arrowHeight
{
    return kPopoverArrowHeight;
}

+ (CGFloat)arrowBase
{
    return kPopoverArrowWidth;
}

- (CGFloat)halfArrowBase
{
    return [GIKPopoverBackgroundView arrowBase] / 2;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _popoverBackground = [[UIImageView alloc] initWithFrame:(CGRect){ .origin = CGPointZero, .size = frame.size }];
        [self addSubview:_popoverBackground];
    }
    return self;
}

- (void)setArrowOffset:(CGFloat)arrowOffset
{
    _arrowOffset = arrowOffset;
    
    if (![UIPopoverBackgroundView respondsToSelector:@selector(wantsDefaultContentAppearance)])
    {
        // -setArrowOffset is called inside an animation block managed by the UIPopoverController. If the frame of our popover is changing because, say, the keyboard is appearing or disappearing, we need to explicitly animate the shadowPath; implicit - in this case, UIKit - animations don't work on the shadowPath - the path will jump to its final value with no inbetweening.
        CGPathRef shadowPathRef = [self shadowPath];
        [self addShadowPathAnimationIfNecessary:shadowPathRef]; // Comment out this line to see the effect of no explicit animation on the shadowPath.
        self.popoverBackground.layer.shadowPath = shadowPathRef;
    }
    [self setNeedsLayout];
}

- (void)addShadowPathAnimationIfNecessary:(CGPathRef)pathRef
{
    // If the layer's animationKeys array contains a string with the value "bounds", we know its frame is changing. Get the timingFunction and duration properties of that animation, and apply them to the shadowPath animation so that the two are in sync.
    NSArray *animationKeys = [self.popoverBackground.layer animationKeys];
    if ([animationKeys containsObject:@"bounds"])
    {
        CAAnimation *boundsAnimation = [self.popoverBackground.layer animationForKey:@"bounds"];
        CABasicAnimation *shadowPathAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        shadowPathAnimation.toValue = [NSValue valueWithPointer:pathRef];
        shadowPathAnimation.timingFunction = boundsAnimation.timingFunction;
        shadowPathAnimation.duration = boundsAnimation.duration;
        [self.popoverBackground.layer addAnimation:shadowPathAnimation forKey:@"shadowPath"];
    }
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    [self addDropShadowIfNecessary]; // Once we know the arrow's direction, we can add a drop shadow manually if we're on iOS 5.x.
    [self setNeedsLayout];
}

- (void)addDropShadowIfNecessary
{
    // Popover background drop shadows don't appear to work on iOS 5.x, so we have to draw the shadow manually. iOS 6.0 adds the +wantsDefaultAppearance class method. Check for the existence (or absence) of this method.
    if (![UIPopoverBackgroundView respondsToSelector:@selector(wantsDefaultContentAppearance)])
    {
        CALayer *layer = self.popoverBackground.layer;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 0.9;
        layer.shadowRadius = 20.0;
        layer.shadowOffset = (CGSize){ .width = 0.0, .height = 10.0 };
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
        
    _popoverExtents = (GIKPopoverExtents){
        .left   = CGRectGetMinX(self.bounds) + kPopoverCornerRadius,
        .right  = CGRectGetMaxX(self.bounds) - kPopoverCornerRadius,
        .top    = CGRectGetMinY(self.bounds) + kPopoverCornerRadius,
        .bottom = CGRectGetMaxY(self.bounds) - kPopoverCornerRadius
    };
    
    _halfBase = [self halfArrowBase];
    _arrowCenter = [self arrowCenter];
    
    // Because layoutSubviews is called on device rotation, the popoverBackground's center and bounds are reset so that any left arrow adjustments or frame resizing can be recalculated from their initial values.
    self.popoverBackground.center = self.center;
    self.popoverBackground.bounds = self.bounds;
    
    self.popoverBackground.image = [self wantsUpOrDownArrow] ? [self upOrDownArrowImage] : [self sideArrowImage];    
}


#pragma mark - Custom Layout

- (CGPathRef)shadowPath
{
    CGRect pathRect = self.bounds;
    
    if ([self wantsUpOrDownArrow])
    {
        pathRect.origin.y = [self wantsUpArrow] ? kPopoverArrowHeight : 0.0;
        pathRect.size.height -= kPopoverArrowHeight;
    }
    else
    {
        pathRect.origin.x = (self.arrowDirection == UIPopoverArrowDirectionLeft) ? kPopoverArrowHeight : 0.0;
        pathRect.size.width -= kPopoverArrowHeight;
    }
    
    return [UIBezierPath bezierPathWithRect:pathRect].CGPath;
}

- (UIImage *)upOrDownArrowImage
{
    NSString *imageName;
    UIEdgeInsets insets;
    BOOL wantsUpArrow = [self wantsUpArrow];
    
    if ([self isArrowBetweenLeftAndRightEdgesOfPopover])
    {
        imageName = (wantsUpArrow) ? kArrowUp : kArrowDown;
        insets = (wantsUpArrow) ? kArrowUpInsets : kArrowDownInsets;
        return [self twoPartStretchableImageNamed:imageName insets:insets];
    }
    else
    {
        imageName = (wantsUpArrow) ? kArrowUpRight : kArrowDownRight;
        insets = (wantsUpArrow) ? kArrowUpRightInsets : kArrowDownRightInsets;
        return [self stretchableImageNamed:imageName insets:insets mirrored:[self isArrowAtLeftEdgeOfPopover]];
    }
}

- (UIImage *)sideArrowImage
{
    [self adjustCentersIfNecessary];
    
    if ([self isArrowBetweenTopAndBottomEdgesOfPopover])
    {
        return [self twoPartStretchableImageNamed:kArrowSide insets:kArrowSideInsets];
    }
    else
    {
        NSString *imageName = [self isArrowAtTopEdgeOfPopover] ? kArrowSideTop : kArrowSideBottom;
        UIEdgeInsets insets = [self isArrowAtTopEdgeOfPopover] ? kArrowSideTopInsets : kArrowSideBottomInsets;
        return [self stretchableImageNamed:imageName insets:insets mirrored:(self.arrowDirection == UIPopoverArrowDirectionLeft)];
    }
}

- (CGFloat)arrowCenter
{
    CGFloat mid = ([self wantsUpOrDownArrow]) ? CGRectGetMidX(self.bounds) : CGRectGetMidY(self.bounds);
    return mid + self.arrowOffset;
}


- (BOOL)wantsUpOrDownArrow { return ([self wantsUpArrow] || self.arrowDirection == UIPopoverArrowDirectionDown); }

- (BOOL)wantsUpArrow { return (self.arrowDirection == UIPopoverArrowDirectionUp); }

- (BOOL)isArrowBetweenLeftAndRightEdgesOfPopover { return ![self isArrowAtRightEdgeOfPopover] && ![self isArrowAtLeftEdgeOfPopover]; }

- (BOOL)isArrowAtLeftEdgeOfPopover { return (_arrowCenter - _halfBase < _popoverExtents.left); }

- (BOOL)isArrowAtRightEdgeOfPopover { return (_arrowCenter + _halfBase > _popoverExtents.right); }

- (BOOL)isArrowBetweenTopAndBottomEdgesOfPopover { return ![self isArrowAtTopEdgeOfPopover] && ![self isArrowAtBottomEdgeOfPopover]; }

- (BOOL)isArrowAtTopEdgeOfPopover { return (_arrowCenter - _halfBase < _popoverExtents.top); }

- (BOOL)isArrowAtBottomEdgeOfPopover { return (_arrowCenter + _halfBase > _popoverExtents.bottom); }


- (void)adjustCentersIfNecessary
{
     // fix centers of left-pointing popovers so that their shadows are drawn correctly.   
    if (self.arrowDirection == UIPopoverArrowDirectionLeft)
    {
        self.center = (CGPoint){ .x = self.center.x + [GIKPopoverBackgroundView arrowHeight], .y = self.center.y };
        self.popoverBackground.center = (CGPoint){ .x = self.popoverBackground.center.x - [GIKPopoverBackgroundView arrowHeight], .y = self.popoverBackground.center.y };
    }
}


#pragma mark - Stretching

- (UIImage *)stretchableImageNamed:(NSString *)name insets:(UIEdgeInsets)insets mirrored:(BOOL)mirrored
{
    UIImage *image = [UIImage imageNamed:name];
    return (mirrored) ? [[self mirroredImage:image] resizableImageWithCapInsets:[self mirroredInsets:insets]] : [image resizableImageWithCapInsets:insets];
}

- (UIImage *)twoPartStretchableImageNamed:(NSString *)name insets:(UIEdgeInsets)insets
{
    UIImage *image = [UIImage imageNamed:name];
    
    if (self.arrowDirection == UIPopoverArrowDirectionLeft)
    {
        image = [self mirroredImage:image];
        insets = [self mirroredInsets:insets];
    }
    
    UIImage *firstHalfImage = [image resizableImageWithCapInsets:insets];
    UIImage *stretchedImage = [self imageFromImageContextWithSourceImage:firstHalfImage size:[self contextSizeForFirstHalfImage:image]];
    return [stretchedImage resizableImageWithCapInsets:[self secondHalfInsetsForStretchedImage:stretchedImage insets:insets]];
}

- (CGFloat)firstHalfStretchAmountForImage:(UIImage *)image
{
    return roundf([self wantsUpOrDownArrow] ? _arrowCenter + (image.size.width - 1) / 2.0 : _arrowCenter + (image.size.height / 2) - 1 - kSideArrowCenterOffset);
}

- (CGSize)contextSizeForFirstHalfImage:(UIImage *)image
{
    CGFloat stretch = [self firstHalfStretchAmountForImage:image];
    return [self wantsUpOrDownArrow] ? (CGSize){ .width = stretch, .height = image.size.height } : (CGSize){ .width = image.size.width, .height = stretch };
}

- (UIEdgeInsets)secondHalfInsetsForStretchedImage:(UIImage *)stretchedImage insets:(UIEdgeInsets)insets
{
    return [self wantsUpOrDownArrow] ? [self horizontalInsetsForStretchedImage:stretchedImage insets:insets] : [self verticalInsetsForStretchedImage:stretchedImage insets:insets];
}

- (UIEdgeInsets)horizontalInsetsForStretchedImage:(UIImage *)stretchedImage insets:(UIEdgeInsets)insets
{
    return (UIEdgeInsets){ .top = insets.top, .left = stretchedImage.size.width - (kSecondHalfRightInset + 1), .bottom = insets.bottom, .right = kSecondHalfRightInset };
}

- (UIEdgeInsets)verticalInsetsForStretchedImage:(UIImage *)stretchedImage insets:(UIEdgeInsets)insets
{
    return (UIEdgeInsets){ .top = stretchedImage.size.height - (kSecondHalfBottomInset + 1), .left = insets.left, .bottom = kSecondHalfBottomInset, .right = insets.right };
}

- (UIImage *)mirroredImage:(UIImage *)image
{
    UIImage *mirror = [UIImage imageWithCGImage:image.CGImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUpMirrored];
    return [self imageFromImageContextWithSourceImage:mirror size:mirror.size];
}

- (UIEdgeInsets)mirroredInsets:(UIEdgeInsets)insets
{
    // Swap left and right insets for a mirrored image.
    return UIEdgeInsetsMake(insets.top, insets.right, insets.bottom, insets.left);
}

- (UIImage *)imageFromImageContextWithSourceImage:(UIImage *)image size:(CGSize)size
{
    // Stretching/tiling only takes place when the image is drawn, so the mirrored or stretched image is first drawn into a context before applying additional stretching.
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:(CGRect){ .origin = CGPointZero, .size = size }];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end
