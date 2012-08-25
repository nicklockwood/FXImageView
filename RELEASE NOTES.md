Version 1.2.3

- Fixed potential crash when using custom effects block
- Replaced customEffectsIdentifier property with more generally useful cacheKey
- Fixed a compiler warning in UIImage+FX category

Version 1.2.2

- Fixed some additional caching bugs
- FXImageView is now KVO-compliant for the image and processedImage properties
- Added KVO example

Version 1.2.1

- Removed setWithBlock: method due to unresolvable caching issue
- Added some additional UIImage+FX methods
- Fixed some caching bugs

Version 1.2

- Added corner radius clipping effect
- Added custom effects block property for applying custom effects
- Added setWithContentsOfFile/URL: methods for dynamic loading/downloading
- Added setWithBlock: method for dynamic image generation or loading logic

Version 1.1.2

- Fixed potential crash when processingQueue maxConcurrentOperationCount is set to -1 (unlimited)
- Added Advanced Example

Version 1.1.1

- Performance improvements

Version 1.1

- Added LIFO queuing for process operations
- Added caching for processed images
- Fixed some bugs

Version 1.0

- Initial release