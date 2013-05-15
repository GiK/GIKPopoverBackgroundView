# GIKPopoverBackgroundView

GIKPopoverBackgroundView is a UIPopoverBackgroundView subclass which uses images similar to those found in UIKit to customise the background of a UIPopoverController.

Unlike most other third-party implementations, GIKPopoverBackgroundView doesn't use separate background and arrow images, so the  appearance is seamless for all orientations.

## Source Images

The figure below shows the background images used by Apple's default implementation:

<img src="https://github.com/GiK/GIKPopoverBackgroundView/raw/gh-pages/AppleDefaultBackgroundImages.png" alt="Images making up Apple's default UIPopoverController background" title="Shared artwork images" style="display:block; margin: 10px auto 30px auto;" class="center">

The DownRight, UpRight, SideBottom, and SideTop images are used when the popover is anchored to a control or rect in the corner or edge of a view. A point in the solid dark blue area is defined as the stretchable region using standard `UIEdgeInsets`.

The Down, Up, and Side images require special handling. To draw a background with an up arrow centered horizontally, the Up image must be stretched twice - once on either side of the arrow.

## Photoshop Source

Arrows were created using shape layers and layer styles in Photoshop. The .PSD contains both 1x and 2x shapes for each arrow. Notes for each layer document the Gradient Overlay style's colour stops and values.

The file is [Slicy](http://macrabbit.com/slicy/) ready for easy exporting to .PNG.

## In Action

[This short screencast](http://d.pr/v/49MN) of the example app demonstrates popovers drawn in a number of orientations from various anchor points. The navigation bar and toolbar of a popover controller take on the appearance of the background view with no additional development effort.

## Implementation Details

### Measure once, stretch twice

Unsurprisingly, judicious use of UIImage's `-resizableImageWithCapInsets:` method is made throughout. For popovers which require two stretching operations, naively applying cap insets twice won't work. Specifying a stretchable region doesn't affect the underlying image until the image is drawn into a context or a view.

The approach taken in GIKPopoverBackgroundView is to draw a stretchable image into a bitmap-based graphics context with appropriate size:

``` objective-c
- (UIImage *)imageFromImageContextWithSourceImage:(UIImage *)image size:(CGSize)size
{
  UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
  [image drawInRect:(CGRect){ .origin = CGPointZero, .size = size }];
  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return result;
}
```

A second set of cap insets are added to the resultant image and it's this new resizable image which is applied to the popover background's `UIImageView`.

### Mirror, mirror

The same technique is used for popover backgrounds with any left-facing 'Side' arrows, 'UpLeft', or 'DownLeft' arrows. The source image is flipped horizontally and drawn into a bitmap-based graphics context before having cap insets applied:

``` objective-c
- (UIImage *)mirroredImage:(UIImage *)image
{
  UIImage *mirror = [UIImage imageWithCGImage:image.CGImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUpMirrored];
  return [self imageFromImageContextWithSourceImage:mirror size:mirror.size];
}
```

### Drop shadows and iOS 5.x

Background drop shadows don't work on subclasses of UIPopoverBackgroundView if the deployment target is iOS 5.x. If iOS 5 is detected, the drop shadow is drawn using the `shadowPath` of the background layer.

Further complicating matters on iOS 5, the `shadowPath` property of `CALayer` doesn't respond to implicit animations such as changes to a layer's bounds. If the popover's geometry changes, an explicit animation must be added to the background layer to animate the shadow.

The documentation for `UIPopoverBackgroundView` states that `-setArrowOffset:` is called inside an animation block managed by the UIPopoverController. This would seem to be the ideal place to sync  the bounds and shadowPath animations. When `-setArrowOffset:` is called, we check the `animationKeys` array of the layer for the existance of a `bounds` key. If found, we know the background's frame is changing - possibly as the result of the keyboard appearing or disappearing. We apply the `timingFunction` and `duration` properties of the bounds animation to a new `CABasicAnimation` for the `shadowPath`.

``` objective-c
- (void)addShadowPathAnimationIfNecessary:(CGPathRef)pathRef
{
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
```

## Usage

To use, add GIKPopoverBackgroundView.h and GIKPopoverBackgroundView.m to your Xcode project. Feel free to use the supplied images (found in the example project) and their default `UIEdgeInsets` values. In the view controller which manages your popover controller, set the popover controller's `popoverBackgroundViewClass` property:

``` objective-c
popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
popoverController.popoverBackgroundViewClass = [GIKPopoverBackgroundView class];
```

## Sample Project

The included sample project covers a number of scenarios where source images are stretched twice, mirrored, and animated in response to keyboard appearance.

## Requirements

GIKPopoverBackgroundView uses ARC and requires iOS 5.0 or above.

## //TODO:

- ~~Add source .PSD files for the backgrounds to the repository.~~
- Discuss how cap insets were chosen to effect two-stage stretching.

## Credits

GIKPopoverBackgroundView was created by [Gordon Hughes](https://github.com/gik/).

## Contact

[Gordon Hughes](https://github.com/gik/)

[@gordonhughes](http://twitter.com/gordonhughes)

## License

GIKPopoverBackgroundView is available under the MIT license. See the LICENSE file for more information.
