//
//  FXImageView.m
//
//  Version 1.3.1
//
//  Created by Nick Lockwood on 31/10/2011.
//  Copyright (c) 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/FXImageView
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "FXImageView.h"
#import "UIImage+FX.h"
#import <objc/message.h>


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif


@interface FXImageOperation : NSOperation

@property (nonatomic, strong) FXImageView *target;

@end


@interface FXImageView ()

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSURL *imageContentURL;

- (void)processImage;

@end


@implementation FXImageOperation

- (void)main
{
    @autoreleasepool
    {
        [_target processImage];
    }
}

@end


@implementation FXImageView

@synthesize cacheKey = _cacheKey;

#pragma mark -
#pragma mark Shared storage

+ (NSOperationQueue *)processingQueue
{
    static NSOperationQueue *sharedQueue = nil;
    if (sharedQueue == nil)
    {
        sharedQueue = [[NSOperationQueue alloc] init];
        [sharedQueue setMaxConcurrentOperationCount:4];
    }
    return sharedQueue;
}

+ (NSCache *)processedImageCache
{
    static NSCache *sharedCache = nil;
    if (sharedCache == nil)
    {
        sharedCache = [[NSCache alloc] init];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(__unused NSNotification *note) {
            
            [sharedCache removeAllObjects];
        }];
    }
    return sharedCache;
}


#pragma mark -
#pragma mark Setup

- (void)setUp
{
    self.shadowColor = [UIColor blackColor];
    _crossfadeDuration = 0.25;
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_imageView];
    [self setImage:super.image];
    super.image = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    if ((self = [super initWithImage:image]))
    {
        [self setUp];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    if ((self = [super initWithImage:image highlightedImage:highlightedImage]))
    {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}


#pragma mark -
#pragma mark Caching

- (NSString *)colorHash:(UIColor *)color
{
    NSString *colorString = @"{0.00,0.00}";
    if (color && ![color isEqual:[UIColor clearColor]])
    {
        NSInteger componentCount = CGColorGetNumberOfComponents(color.CGColor);
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        NSMutableArray *parts = [NSMutableArray arrayWithCapacity:componentCount];
        for (NSInteger i = 0; i < componentCount; i++)
        {
            [parts addObject:[NSString stringWithFormat:@"%.2f", components[i]]];
        }
        colorString = [NSString stringWithFormat:@"{%@}", [parts componentsJoinedByString:@","]];
    }
    return colorString;
}

- (NSNumber *)imageHash:(UIImage *)image
{
    static NSUInteger hashKey = 1;
    static const char FXImageHash;
    NSNumber *number = objc_getAssociatedObject(image, (void *)&FXImageHash);
    if (!number && image)
    {
        objc_setAssociatedObject(image, (void *)&FXImageHash, @(hashKey++), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return number;
}

- (NSString *)cacheKey
{
    if (_cacheKey) return _cacheKey;
    
    return [NSString stringWithFormat:@"%@_%@_%.2f_%.2f_%.2f_%@_%@_%.2f_%.2f_%@",
            _imageContentURL ?: [self imageHash:_originalImage],
            NSStringFromCGSize(self.bounds.size),
            _reflectionGap,
            _reflectionScale,
            _reflectionAlpha,
            [self colorHash:_shadowColor],
            NSStringFromCGSize(_shadowOffset),
            _shadowBlur,
            _cornerRadius,
            @(self.contentMode)];
}

- (void)cacheProcessedImage:(UIImage *)processedImage forKey:(NSString *)cacheKey
{
    [[[self class] processedImageCache] setObject:processedImage forKey:cacheKey];
}

- (UIImage *)cachedProcessedImage
{
    return [[[self class] processedImageCache] objectForKey:[self cacheKey]];
}

#pragma mark -
#pragma mark Processing

- (void)setProcessedImageOnMainThread:(NSArray *)array
{
    //get images
    NSString *cacheKey = array[1];
    UIImage *processedImage = array[0];
    processedImage = ([processedImage isKindOfClass:[NSNull class]])? nil: processedImage;
    
    if (processedImage)
    {
        //cache image
        [self cacheProcessedImage:processedImage forKey:cacheKey];

        //set image
        if ([[self cacheKey] isEqualToString:cacheKey])
        {
            if (_crossfadeDuration)
            {
                //jump through a few hoops to avoid QuartzCore framework dependency
                CAAnimation *animation = [NSClassFromString(@"CATransition") animation];
                [animation setValue:@"kCATransitionFade" forKey:@"type"];
                animation.duration = _crossfadeDuration;
                [self.layer addAnimation:animation forKey:nil];
            }

            //set processed image
            [self willChangeValueForKey:@"processedImage"];
            _imageView.image = processedImage ?: _imageView.image;
            [self didChangeValueForKey:@"processedImage"];
        }
    }
}

- (void)processImage
{
    //get properties
    NSString *cacheKey = [self cacheKey];
    UIImage *image = _originalImage;
    NSURL *imageURL = _imageContentURL;
    CGSize size = self.bounds.size;
    CGFloat reflectionGap = _reflectionGap;
    CGFloat reflectionScale = _reflectionScale;
    CGFloat reflectionAlpha = _reflectionAlpha;
    UIColor *shadowColor = _shadowColor;
    CGSize shadowOffset = _shadowOffset;
    CGFloat shadowBlur = _shadowBlur;
    CGFloat cornerRadius = _cornerRadius;
    UIImage *(^customEffectsBlock)(UIImage *image) = [_customEffectsBlock copy];
    UIViewContentMode contentMode = self.contentMode;
    
    //check cache
    UIImage *processedImage = [self cachedProcessedImage];
    if (!processedImage)
    {
        //load image
        if (imageURL)
        {
            NSURLRequest *request = [NSURLRequest requestWithURL:imageURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
            NSError *error = nil;
            NSURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (error)
            {
                NSLog(@"Error loading image for URL: %@, %@", imageURL, error);
                image = nil;
            }
            else
            {
                image = [UIImage imageWithData:data];
                if ([[[imageURL path] stringByDeletingPathExtension] hasSuffix:@"@2x"])
                {
                    image = [UIImage imageWithCGImage:image.CGImage scale:2.0f orientation:image.imageOrientation];
                }
            }
        }
        
        if (image)
        {
            //crop and scale image
            processedImage = [image imageCroppedAndScaledToSize:size
                                                    contentMode:contentMode
                                                       padToFit:NO];
            
            //apply custom processing
            if (customEffectsBlock)
            {
                processedImage = customEffectsBlock(processedImage);
            }
            
            //clip corners
            if (cornerRadius)
            {
                processedImage = [processedImage imageWithCornerRadius:cornerRadius];
            }
            
            //apply shadow
            if (shadowColor && ![shadowColor isEqual:[UIColor clearColor]] &&
                (shadowBlur || !CGSizeEqualToSize(shadowOffset, CGSizeZero)))
            {
                reflectionGap -= 2.0f * (fabsf(shadowOffset.height) + shadowBlur);
                processedImage = [processedImage imageWithShadowColor:shadowColor
                                                               offset:shadowOffset
                                                                 blur:shadowBlur];
            }
            
            //apply reflection
            if (reflectionScale && reflectionAlpha)
            {
                processedImage = [processedImage imageWithReflectionWithScale:reflectionScale
                                                                          gap:reflectionGap
                                                                        alpha:reflectionAlpha];
            }
        }
    }
    
    //cache and set image
    if ([[NSThread currentThread] isMainThread])
    {
        if (processedImage)
        {
            [self cacheProcessedImage:processedImage forKey:cacheKey];
        }
        [self willChangeValueForKey:@"processedImage"];
        _imageView.image = processedImage ?: _imageView.image;
        [self didChangeValueForKey:@"processedImage"];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(setProcessedImageOnMainThread:)
                               withObject:@[processedImage ?: [NSNull null], cacheKey]
                            waitUntilDone:YES];
    }
}

- (void)queueProcessingOperation:(FXImageOperation *)operation
{
    //suspend operation queue
    NSOperationQueue *queue = [[self class] processingQueue];
    [queue setSuspended:YES];
    
    //check for existing operations
    for (FXImageOperation *op in queue.operations)
    {
        if ([op isKindOfClass:[FXImageOperation class]])
        {
            if (op.target == self && ![op isExecuting])
            {
                //already queued
                [queue setSuspended:NO];
                return;
            }
        }
    }
    
    //make op a dependency of all queued ops
    NSInteger maxOperations = ([queue maxConcurrentOperationCount] > 0) ? [queue maxConcurrentOperationCount]: INT_MAX;
    NSInteger index = [queue operationCount] - maxOperations;
    if (index >= 0)
    {
        NSOperation *op = [queue operations][index];
        if (![op isExecuting])
        {
            [op addDependency:operation];
        }
    }
    
    //add operation to queue
    [queue addOperation:operation];
    
    //resume queue
    [queue setSuspended:NO];
}

- (void)queueImageForProcessing
{
    //create processing operation
    FXImageOperation *operation = [[FXImageOperation alloc] init];
    operation.target = self;
    
    //set operation thread priority
    [operation setThreadPriority:1.0];
    
    //queue operation
    [self queueProcessingOperation:operation];
}

- (void)updateProcessedImage
{
    id processedImage = [self cachedProcessedImage];
    if (!processedImage && !_originalImage && !_imageContentURL)
    {
        processedImage = [NSNull null];
    }
    if (processedImage)
    {
        //use cached version
        [self willChangeValueForKey:@"processedImage"];
        _imageView.image = ([processedImage isKindOfClass:[NSNull class]])? nil: processedImage;
        [self didChangeValueForKey:@"processedImage"];
    }
    else if (_asynchronous)
    {
        //process in background
        [self queueImageForProcessing];
    }
    else
    {
        //process on main thread
        [self processImage];
    }
}

- (void)layoutSubviews
{
    _imageView.frame = self.bounds;
    if (_imageContentURL || self.image)
    {
        [self updateProcessedImage];
    }
}


#pragma mark -
#pragma mark Setters and getters

- (UIImage *)processedImage
{
    return _imageView.image;
}

- (void)setProcessedImage:(UIImage *)image
{
    self.imageContentURL = nil;
    [self willChangeValueForKey:@"image"];
    self.originalImage = nil;
    [self didChangeValueForKey:@"image"];
    _imageView.image = image;
}

- (UIImage *)image
{
    return _originalImage;
}

- (void)setImage:(UIImage *)image
{
    if (_imageContentURL || ![image isEqual:_originalImage])
    {        
        //update processed image
        self.imageContentURL = nil;
        self.originalImage = image;
        [self updateProcessedImage];
    }
}

- (void)setReflectionGap:(CGFloat)reflectionGap
{
    if (_reflectionGap != reflectionGap)
    {
        _reflectionGap = reflectionGap;
        [self setNeedsLayout];
    }
}

- (void)setReflectionScale:(CGFloat)reflectionScale
{
    if (_reflectionScale != reflectionScale)
    {
        _reflectionScale = reflectionScale;
        [self setNeedsLayout];
    }
}

- (void)setReflectionAlpha:(CGFloat)reflectionAlpha
{
    if (_reflectionAlpha != reflectionAlpha)
    {
        _reflectionAlpha = reflectionAlpha;
        [self setNeedsLayout];
    }
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    if (![_shadowColor isEqual:shadowColor])
    {
        _shadowColor = shadowColor;
        [self setNeedsLayout];
    }
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    if (!CGSizeEqualToSize(_shadowOffset, shadowOffset))
    {
        _shadowOffset = shadowOffset;
        [self setNeedsLayout];
    }
}

- (void)setShadowBlur:(CGFloat)shadowBlur
{
    if (_shadowBlur != shadowBlur)
    {
        _shadowBlur = shadowBlur;
        [self setNeedsLayout];
    }
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    if (self.contentMode != contentMode)
    {
        super.contentMode = contentMode;
        [self setNeedsLayout];
    }
}

- (void)setCustomEffectsBlock:(UIImage *(^)(UIImage *))customEffectsBlock
{
    if (![customEffectsBlock isEqual:_customEffectsBlock])
    {
        _customEffectsBlock = [customEffectsBlock copy];
        [self setNeedsLayout];
    }
}

- (void)setCacheKey:(NSString *)cacheKey
{
    if (![cacheKey isEqualToString:_cacheKey])
    {
        _cacheKey = [cacheKey copy];
        [self setNeedsLayout];
    }
}


#pragma mark -
#pragma mark loading

- (void)setImageWithContentsOfFile:(NSString *)file
{
    if ([[file pathExtension] length] == 0)
    {
        file = [file stringByAppendingPathExtension:@"png"];
    }
    if (![file isAbsolutePath])
    {
        file = [[NSBundle mainBundle] pathForResource:file ofType:nil];
    }
    if ([UIScreen mainScreen].scale == 2.0f)
    {
        NSString *temp = [[[file stringByDeletingPathExtension] stringByAppendingString:@"@2x"] stringByAppendingPathExtension:[file pathExtension]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:temp])
        {
            file = temp;
        }
    }
    [self setImageWithContentsOfURL:[NSURL fileURLWithPath:file]];
}

- (void)setImageWithContentsOfURL:(NSURL *)URL
{
    if (![URL isEqual:_imageContentURL])
    {
        //update processed image
        [self willChangeValueForKey:@"image"];
        self.originalImage = nil;
        [self didChangeValueForKey:@"image"];
        self.imageContentURL = URL;
        [self updateProcessedImage];
    }
}

@end
