Purpose
--------------

FXImageView is a class designed to simplify the application of common visual effects such as reflections and drop-shadows to images. FXImageView includes sophisticated queuing and caching logic to maximise performance when rendering these effects in real time.

As a bonus, FXImageView includes a standalone UIImage category for cropping, scaling and applying effects directly to an image.


Supported iOS & SDK Versions
-----------------------------

* Supported build target - iOS 5.1 / Mac OS 10.7 (Xcode 4.3, Apple LLVM compiler 3.1)
* Earliest supported deployment target - iOS 4.3 / Mac OS 10.6
* Earliest compatible deployment target - iOS 4.0 / Mac OS 10.6

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this iOS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

FXImageView is designed to automatically work with both ARC and non-ARC projects through conditional compilation. There is no need to exclude FXImageView files from the ARC validation process, or to convert FXImageView using the ARC conversion tool.


Installation
---------------

To use FXImageView, just drag the class files into your project. You can create FXImageViews programatically, or create them in Interface Builder by dragging an ordinary UIImageView into your view and setting its class to FXImageView.


UIImage extension methods
---------------------------

    - (UIImage *)imageCroppedToRect:(CGRect)rect;
    
Returns a copy of the image cropped to the specified rectangle (in image coordinates).
    
    - (UIImage *)imageScaledToSize:(CGSize)size;
    
Returns a copy of  the image scaled to the specified size. This method may change the aspect ratio of the image.
    
    - (UIImage *)imageScaledToFitSize:(CGSize)size;
    
Returns a copy of the image scaled to fit the specified size without changing its aspect ratio. The resultant image may be smaller than the size specified in one dimension if the aspect ratios do not match. No padding will be added.
    
    - (UIImage *)imageScaledToFillSize:(CGSize)size;
    
Returns a copy of the image scaled to fit the specified size without changing its aspect ratio. If the image aspect ratio does not match the aspect ratio of the size specified, the image will be cropped to fit.
    
    - (UIImage *)imageCroppedAndScaledToSize:(CGSize)size
                                 contentMode:(UIViewContentMode)contentMode
                                    padToFit:(BOOL)padToFit;
    
Returns a copy of the image scaled and/or cropped to the specified size using the specified UIViewContentMode. This method is useful for matching the effect of UIViewContentMode on an image when displayed in a UIImageView. If the padToFit argument is NO, the resultant image may be smaller than the size specified is the aspect ratios do not match. If padToFit is YES, additional transparent pixels will be added around the image to pad it out to the size specified.
    
    - (UIImage *)reflectedImageWithScale:(CGFloat)scale;
    
Returns a vertically reflected copy of the image that tapers off to transparent with a gradient. The scale parameter determines that point at which the image tapers off and should have a value between 0.0 and 1.0.
    
    - (UIImage *)imageWithReflectionWithScale:(CGFloat)scale gap:(CGFloat)gap alpha:(CGFloat)alpha;
    
Returns a copy of the image that includes a reflection with the specified scale, separation gap and alpha (opacity). The original image will be vertically centered within the new image, with he space above the image padded out with transparent pixels matching the height of the reflection below. This makes it easier to position the image within a UIImageView.
    
    - (UIImage *)imageWithShadowColor:(UIColor *)color offset:(CGSize)offset blur:(CGFloat)blur;
    
Returns a copy of the image with a drop shadow rendered with the specified color, offset and blur. Regardless of the offset value, the original image will be vertically centered within the new image to make it easier to position the image within a UIImageView.

    - (UIImage *)imageWithAlpha:(CGFloat)alpha;

Returns a copy of the image with the specified alpha (opacity). The alpha is multiplied by the image's original alpha channel, so this method can only be used to make the image more transparent, not more opaque.


FXImageView class methods
-----------------------

    + (NSOperationQueue *)processingQueue;
    
This is the shared NSOperationQueue used for queuing FXImageView images for processing. You can use this method to manipulate the `maxConcurrentOperationCount` for the queue, which may be useful when fine tuning performance. The default maximum concurrent operation count is 4.
    
    + (NSCache *)processedImageCache;
    
This is the shared NSCache used to cache processed FXImageView images for reuse. iOS automatically manages clearing this cache when iOS runs low on memory, but you may wish to manipulate the `countLimit` value, or manually clear the cache at specific points in your app.


FXImageView properties
----------------

    @property (nonatomic, assign, getter = isAsynchronous) BOOL asynchronous;
    
The shadow and reflection effects take time to render. In many cases this will be imperceptible, but for high-performance applications such as a scrolling carousel, this rendering delay may cause stuttering in the animation. This method toggles whether the shadow and reflection effects are applied immediately on the main thread (asynchronous = NO), or rendered in a background thread (asynchronous = YES). By rendering the effects in the background, the performance issues can be avoided. Defaults to NO.
    
    @property (nonatomic, assign) CGFloat reflectionGap;
    
The gap between the image and its reflection, measured in pixels (or points on a Retina Display device). This defaults to zero.
    
    @property (nonatomic, assign) CGFloat reflectionScale;
    
The height of the reflection relative to the image. Should be in the range 0.0 to 1.0. Defaults to 0.0 (no reflection).
    
    @property (nonatomic, assign) CGFloat reflectionAlpha;
    
The opacity of the reflection. Should be in the range 0.0 to 1.0. Defaults to 0.0 (completely transparent).

	@property (nonatomic, strong) UIColor *shadowColor;
	
The colour of the shadow (defaults to black).
	
	@property (nonatomic, assign) CGSize shadowOffset;
	
The offset for the shadow, in points/pixels. Defaults to CGSizeZero (no shadow).

	@property (nonatomic, assign) CGFloat shadowBlur;
	
The softness of the image shadow. Defaults to zero, which creates a hard shadow.

    @property (nonatomic, strong) UIImage *processedImage;

The resultant image after applying reflection and shadow effects. It can sometimes be useful to set and get this directly, for example you may wish to set a placeholder image whilst the image is being processed, or retrieve and store the processed image so it can be cached for re-use later without needing to be re-generated from the original image (note that FXImageView already includes in-memory caching of processed images).