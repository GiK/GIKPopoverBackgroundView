//
//  GIKPopoverBackgroundView.m
//
//  Created by Gordon Hughes on 1/7/13.
//  Copyright (c) 2013 Gordon Hughes. All rights reserved.
//

#import "GIKPopoverBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

/**
 Types for the seven required background images. If a popover's arrowDirection is UIPopoverArrowDirectionLeft, the equivalent right-facing image will be mirrored.
 */
typedef enum {
    kArrowUp,
    kArrowUpRight,
    kArrowDown,
    kArrowDownRight,
    kArrowSide,
    kArrowSideTop,
    kArrowSideBottom
} GIKPopoverBackgroundImageType;


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

    CGFloat popoverCornerRadius = [self popoverCornerRadius];
    _popoverExtents = (GIKPopoverExtents){
        .left   = CGRectGetMinX(self.bounds) + popoverCornerRadius,
        .right  = CGRectGetMaxX(self.bounds) - popoverCornerRadius,
        .top    = CGRectGetMinY(self.bounds) + popoverCornerRadius,
        .bottom = CGRectGetMaxY(self.bounds) - popoverCornerRadius
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

    CGFloat popoverArrowHeight = [[self class] arrowHeight];
    if ([self wantsUpOrDownArrow])
    {
        pathRect.origin.y = [self wantsUpArrow] ? popoverArrowHeight : 0.0;
        pathRect.size.height -= popoverArrowHeight;
    }
    else
    {
        pathRect.origin.x = (self.arrowDirection == UIPopoverArrowDirectionLeft) ? popoverArrowHeight : 0.0;
        pathRect.size.width -= popoverArrowHeight;
    }
    
    return [UIBezierPath bezierPathWithRect:pathRect].CGPath;
}

- (UIImage *)upOrDownArrowImage
{
    GIKPopoverBackgroundImageType imageType;
    UIEdgeInsets insets;
    BOOL wantsUpArrow = [self wantsUpArrow];
    
    if ([self isArrowBetweenLeftAndRightEdgesOfPopover])
    {
        imageType = (wantsUpArrow) ? kArrowUp : kArrowDown;
        insets = (wantsUpArrow) ? [self arrowUpInsets] : [self arrowDownInsets];
        return [self twoPartStretchableImageWithType:imageType insets:insets];
    }
    else
    {
        imageType = (wantsUpArrow) ? kArrowUpRight : kArrowDownRight;
        insets = (wantsUpArrow) ? [self arrowUpRightInsets] : [self arrowDownRightInsets];
        return [self stretchableImageWithType:imageType insets:insets mirrored:[self isArrowAtLeftEdgeOfPopover]];
    }
}

- (UIImage *)sideArrowImage
{
    [self adjustCentersIfNecessary];
    
    if ([self isArrowBetweenTopAndBottomEdgesOfPopover])
    {
        return [self twoPartStretchableImageWithType:kArrowSide insets:[self arrowSideInsets]];
    }
    else
    {
        GIKPopoverBackgroundImageType imageType = [self isArrowAtTopEdgeOfPopover] ? kArrowSideTop : kArrowSideBottom;
        UIEdgeInsets insets = [self isArrowAtTopEdgeOfPopover] ? [self arrowSideTopInsets] : [self arrowSideBottomInsets];
        return [self stretchableImageWithType:imageType insets:insets mirrored:(self.arrowDirection == UIPopoverArrowDirectionLeft)];
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

#pragma mark - Sizing and Insets

- (CGFloat)popoverCornerRadius
{
    return kPopoverCornerRadius;
}

- (CGFloat)sideArrowCenterOffset
{
    return kSideArrowCenterOffset;
}

- (UIEdgeInsets)arrowUpInsets
{
    return kArrowUpInsets;
}

- (UIEdgeInsets)arrowUpRightInsets
{
    return kArrowUpRightInsets;
}

- (UIEdgeInsets)arrowDownInsets
{
    return kArrowDownInsets;
}

- (UIEdgeInsets)arrowDownRightInsets
{
    return kArrowDownRightInsets;
}

- (UIEdgeInsets)arrowSideInsets
{
    return kArrowSideInsets;
}

- (UIEdgeInsets)arrowSideTopInsets
{
    return kArrowSideTopInsets;
}

- (UIEdgeInsets)arrowSideBottomInsets
{
    return kArrowSideBottomInsets;
}

- (CGFloat)secondHalfBottomInset
{
    return kSecondHalfBottomInset;
}

- (CGFloat)secondHalfRightInset
{
    return kSecondHalfRightInset;
}

#pragma mark - Stretching

- (UIImage *)stretchableImageWithType:(GIKPopoverBackgroundImageType)imageType insets:(UIEdgeInsets)insets mirrored:(BOOL)mirrored
{
    UIImage *image;

    switch (imageType) {
        case kArrowDown:
            image = [self arrowDownImage];
            break;

        case kArrowDownRight:
            image = [self arrowDownRightImage];
            break;

        case kArrowSide:
            image = [self arrowSideImage];
            break;

        case kArrowSideBottom:
            image = [self arrowSideBottomImage];
            break;

        case kArrowSideTop:
            image = [self arrowSideTopImage];
            break;

        case kArrowUp:
            image = [self arrowUpImage];
            break;

        case kArrowUpRight:
            image = [self arrowUpRightImage];
            break;
    }

    return (mirrored) ? [[self mirroredImage:image] resizableImageWithCapInsets:[self mirroredInsets:insets]] : [image resizableImageWithCapInsets:insets];
}

- (UIImage *)twoPartStretchableImageWithType:(GIKPopoverBackgroundImageType)imageType insets:(UIEdgeInsets)insets
{
    UIImage *image;
    
    switch (imageType) {
        case kArrowDown:
            image = [self arrowDownImage];
            break;

        case kArrowDownRight:
            image = [self arrowDownRightImage];
            break;

        case kArrowSide:
            image = [self arrowSideImage];
            break;

        case kArrowSideBottom:
            image = [self arrowSideBottomImage];
            break;

        case kArrowSideTop:
            image = [self arrowSideTopImage];
            break;

        case kArrowUp:
            image = [self arrowUpImage];
            break;

        case kArrowUpRight:
            image = [self arrowUpRightImage];
            break;
    }
    
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
    return roundf([self wantsUpOrDownArrow] ? _arrowCenter + (image.size.width - 1) / 2.0 : _arrowCenter + (image.size.height / 2) - 1 - [self sideArrowCenterOffset]);
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
    CGFloat secondHalfRightInset = [self secondHalfRightInset];
    return (UIEdgeInsets){ .top = insets.top, .left = stretchedImage.size.width - (secondHalfRightInset + 1), .bottom = insets.bottom, .right = secondHalfRightInset };
}

- (UIEdgeInsets)verticalInsetsForStretchedImage:(UIImage *)stretchedImage insets:(UIEdgeInsets)insets
{
    CGFloat secondHalfBottomInset = [self secondHalfBottomInset];
    return (UIEdgeInsets){ .top = stretchedImage.size.height - (secondHalfBottomInset + 1), .left = insets.left, .bottom = secondHalfBottomInset, .right = insets.right };
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


#pragma mark - Image Generation

- (void)drawUpArrowPopoverImageInPath:(CGMutablePathRef)path withTransform:(CGAffineTransform *)transform
{
    CGPathMoveToPoint(path, transform, 28, 1);
    CGPathAddLineToPoint(path, transform, 46, 19);
    CGPathAddLineToPoint(path, transform, 48, 19);
    CGPathAddArcToPoint(path, transform, 55, 19, 55, 26, 7);
    CGPathAddLineToPoint(path, transform, 55, 42);
    CGPathAddArcToPoint(path, transform, 55, 49, 48, 49, 7);
    CGPathAddLineToPoint(path, transform, 8, 49);
    CGPathAddArcToPoint(path, transform, 1, 49, 1, 42, 7);
    CGPathAddLineToPoint(path, transform, 1, 26);
    CGPathAddArcToPoint(path, transform, 1, 19, 8, 19, 7);
    CGPathAddLineToPoint(path, transform, 10, 19);
    CGPathCloseSubpath(path);
}

- (void)drawUpRightArrowPopoverImageInPath:(CGMutablePathRef)path withTransform:(CGAffineTransform *)transform
{
    CGPathMoveToPoint(path, transform, 28, 1);
    CGPathAddLineToPoint(path, transform, 46, 19);
    CGPathAddCurveToPoint(path, transform, 49, 21, 50, 23, 50, 26);
    CGPathAddLineToPoint(path, transform, 50, 42);
    CGPathAddArcToPoint(path, transform, 50, 49, 43, 49, 7);
    CGPathAddLineToPoint(path, transform, 8, 49);
    CGPathAddArcToPoint(path, transform, 1, 49, 1, 42, 7);
    CGPathAddLineToPoint(path, transform, 1, 26);
    CGPathAddArcToPoint(path, transform, 1, 19, 8, 19, 7);
    CGPathAddLineToPoint(path, transform, 10, 19);
    CGPathCloseSubpath(path);
}

- (void)drawSideArrowPopoverImageInPath:(CGMutablePathRef)path withTransform:(CGAffineTransform *)transform
{
    CGPathMoveToPoint(path, transform, 35, 43);
    CGPathAddLineToPoint(path, transform, 17, 61);
    CGPathAddLineToPoint(path, transform, 17, 63);
    CGPathAddArcToPoint(path, transform, 17, 70, 10, 70, 7);
    CGPathAddLineToPoint(path, transform, 8, 70);
    CGPathAddArcToPoint(path, transform, 1, 70, 1, 63, 7);
    CGPathAddLineToPoint(path, transform, 1, 8);
    CGPathAddArcToPoint(path, transform, 1, 1, 8, 1, 7);
    CGPathAddLineToPoint(path, transform, 10, 1);
    CGPathAddArcToPoint(path, transform, 17, 1, 17, 8, 7);
    CGPathAddLineToPoint(path, transform, 17, 25);
    CGPathCloseSubpath(path);
}

- (void)drawSideBottomArrowPopoverImageInPath:(CGMutablePathRef)path withTransform:(CGAffineTransform *)transform
{
    CGPathMoveToPoint(path, transform, 35, 43);
    CGPathAddLineToPoint(path, transform, 17, 61);
    CGPathAddCurveToPoint(path, transform, 15, 64, 13, 65, 10, 65);
    CGPathAddLineToPoint(path, transform, 8, 65);
    CGPathAddArcToPoint(path, transform, 1, 65, 1, 58, 7);
    CGPathAddLineToPoint(path, transform, 1, 8);
    CGPathAddArcToPoint(path, transform, 1, 1, 8, 1, 7);
    CGPathAddLineToPoint(path, transform, 10, 1);
    CGPathAddArcToPoint(path, transform, 17, 1, 17, 8, 7);
    CGPathAddLineToPoint(path, transform, 17, 25);
    CGPathCloseSubpath(path);

}

// Subclass can override these methods to provide custom artwork
- (UIImage *)arrowUpImage
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    [self drawUpArrowPopoverImageInPath:path withTransform:NULL];
    UIImage *image = [self imageForPath:path withSize:CGSizeMake(57,51)];
    
    CGPathRelease(path);
    return image;
}

- (UIImage *)arrowUpRightImage
{
    CGMutablePathRef path = CGPathCreateMutable();

    [self drawUpRightArrowPopoverImageInPath:path withTransform:NULL];
    UIImage *image = [self imageForPath:path withSize:CGSizeMake(52, 51)];

    CGPathRelease(path);
    return image;
}

- (UIImage *)arrowDownImage
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform flip = CGAffineTransformMake(1, 0, 0, -1, 0, 51);
    
    [self drawUpArrowPopoverImageInPath:path withTransform:&flip];
    UIImage *image = [self imageForPath:path withSize:CGSizeMake(57,51)];
    
    CGPathRelease(path);
    return image;
}

- (UIImage *)arrowDownRightImage
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform flip = CGAffineTransformMake(1, 0, 0, -1, 0, 51);

    [self drawUpRightArrowPopoverImageInPath:path withTransform:&flip];
    UIImage *image = [self imageForPath:path withSize:CGSizeMake(52,51)];

    CGPathRelease(path);
    return image;
}

- (UIImage *)arrowSideImage
{
    CGMutablePathRef path = CGPathCreateMutable();

    [self drawSideArrowPopoverImageInPath:path withTransform:NULL];
    UIImage *image = [self imageForPath:path withSize:CGSizeMake(37, 72)];

    CGPathRelease(path);
    return image;
}

- (UIImage *)arrowSideTopImage
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform flip = CGAffineTransformMake(1, 0, 0, -1, 0, 67);

    [self drawSideBottomArrowPopoverImageInPath:path withTransform:&flip];
    UIImage *image = [self imageForPath:path withSize:CGSizeMake(37, 67)];

    CGPathRelease(path);
    return image;
}

- (UIImage *)arrowSideBottomImage
{
    CGMutablePathRef path = CGPathCreateMutable();

    [self drawSideBottomArrowPopoverImageInPath:path withTransform:NULL];
    UIImage *image = [self imageForPath:path withSize:CGSizeMake(37, 67)];

    CGPathRelease(path);
    return image;
}


- (UIImage *)imageForPath:(CGPathRef)path withSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Draw a gradient
    CGContextAddPath(context, path);
    CGContextClip(context);

    CGColorRef colors[] = { [self popoverGradientFromColor].CGColor, [self popoverGradientToColor].CGColor };
    CFArrayRef colorsArray = CFArrayCreate(NULL, (const void**)colors, sizeof(colors) / sizeof(CGColorRef), &kCFTypeArrayCallBacks);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colorsArray, NULL);
    CFRelease(colorSpace);
    CFRelease(colorsArray);

    CGPoint gradientStart = CGPointMake(size.width / 2, 0);
    CGPoint gradientEnd = CGPointMake(size.width / 2, size.height);
    CGContextDrawLinearGradient(context, gradient, gradientStart, gradientEnd, 0);
    CGGradientRelease(gradient);

    // Draw the border
    [[self popoverBorderColor] setStroke];
    CGContextAddPath(context, path);
    CGContextStrokePath(context);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}


// Subclass can override these methods to provide custom colors
- (UIColor *)popoverBorderColor
{
    return [UIColor blackColor];
}

- (UIColor *)popoverGradientFromColor
{
    // In your subclass, use an alpha of 0.8 to get about the same amount of transparency as the default UIKit popovers
    return [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8];
}

- (UIColor *)popoverGradientToColor
{
    return [UIColor darkGrayColor];
}

@end
