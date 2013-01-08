# GIKPopoverBackgroundView

GIKPopoverBackgroundView is a UIPopoverBackgroundView subclass which uses images similar to those found in UIKit to customise the background of a UIPopoverController.

Unlike most other third-party implementations, GIKPopoverBackgroundView doesn't use separate arrow images, so the  appearance is seamless for all orientations.

## Source Images

The figure below shows the background images used by Apple's default implementation:

<img src="https://github.com/GiK/GIKPopoverBackgroundView/raw/gh-pages/AppleDefaultBackgroundImages.png" alt="Images making up Apple's default UIPopoverController background" title="Shared artwork images" style="display:block; margin: 10px auto 30px auto;" class="center">

The DownRight, UpRight, SideBottom, and SideTop images are used when the popover is anchored to a control or rect in the corner or edge of a view. A point in the solid dark blue area is defined as the stretchable region using standard `UIEdgeInsets`.

The Down, Up, and Side images require special handling. To draw a background with an up arrow centered horizontally, the Up image must be stretched twice - once on either side of the arrow.

### Measure once, stretch twice

Unsurprisingly, judicious use of UIImage's `-resizableImageWithCapInsets:` method is made throughout. What might not be apparent, however, is that naively applying `-resizableImageWithCapInsets:` twice just won't work. Specifying a stretchable region doesn't affect the underlying image until it's drawn into a context or a view.

The approach taken in GIKPopoverBackgroundView is to draw a stretchable image into a bitmap-based graphics context with appropriate size using `UIGraphicsBeginImageContextWithOptions`:

``` objective-c
- (UIImage *)imageFromImageContextWithSourceImage:(UIImage *)image size:(CGSize)size
- {
  UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
  [image drawInRect:(CGRect){ .origin = CGPointZero, .size = size }];
  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return result;
}
```

A second set of cap insets are added to the resultant image and it's this new resizable image which is applied to the background `UIImageView`.

### Mirror, mirror

The same technique is used for popover backgrounds with left-facing or 'UpLeft' and 'DownLeft' arrows. The source image is flipped horizontally and drawn into a bitmap-based graphics context before having cap insets applied:

``` objective-c
- (UIImage *)mirroredImage:(UIImage *)image
- {
  UIImage *mirror = [UIImage imageWithCGImage:image.CGImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUpMirrored];
  return [self imageFromImageContextWithSourceImage:mirror size:mirror.size];
}


iOS 5.x and 6.x are supported. Background drop shadows don't appear to work on subclasses of UIPopoverBackgroundView if the deployment target is iOS 5.x. In this instance, a drop shadow is added to the background's layer, and will animate in response to keyboard appearance.

## Credits

GIKPopoverBackgroundView was created by [Gordon Hughes](https://github.com/gik/).

## Contact

[Gordon Hughes](https://github.com/gik/)

[@gordonhughes](http://twitter.com/gordonhughes)

## License

GIKPopoverBackgroundView is available under the MIT license. See the LICENSE file for more information.
