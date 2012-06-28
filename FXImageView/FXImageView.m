//
//  FXImageView.m
//
//  Version 1.0
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


@interface FXImageView ()

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *selfReference;

@end


@implementation FXImageView

@synthesize originalImage = _originalImage;
@synthesize imageView = _imageView;
@synthesize selfReference = _selfReference;
@synthesize asynchronous = _asynchronous;
@synthesize reflectionGap = _reflectionGap;
@synthesize reflectionScale = _reflectionScale;
@synthesize reflectionAlpha = _reflectionAlpha;
@synthesize shadowColor = _shadowColor;
@synthesize shadowOffset = _shadowOffset;
@synthesize shadowBlur = _shadowBlur;

- (void)setUp
{
    self.shadowColor = [UIColor blackColor];
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)setProcessedImage:(UIImage *)image
{
    _imageView.image = image;
}

- (void)processImage:(UIImage *)image
{
    @synchronized ([self class])
    {
        if (image == _originalImage)
        {
            @autoreleasepool
            {
                //prevent premature release
                self.selfReference = self;
        
                //crop and scale image
                image = [image imageCroppedAndScaledToSize:self.bounds.size
                                               contentMode:self.contentMode
                                                  padToFit:NO];
                
                //apply reflection
                if (_reflectionScale > 0.0f)
                {
                    image = [image imageWithReflectionWithScale:_reflectionScale
                                                            gap:_reflectionGap
                                                          alpha:_reflectionAlpha];
                }
                
                //apply shadow
                if (_shadowColor && (_shadowBlur || !CGSizeEqualToSize(_shadowOffset, CGSizeZero)))
                {
                    image = [image imageWithShadowColor:_shadowColor
                                                 offset:_shadowOffset
                                                   blur:_shadowBlur];
                }
                
                //set resultant image
                if ([[NSThread currentThread] isMainThread])
                {
                    [self setProcessedImage:image];
                }
                else
                {
                    [self performSelectorOnMainThread:@selector(setProcessedImage:)
                                           withObject:image
                                        waitUntilDone:YES];
                }
                
                //release self reference
                self.selfReference = nil;
            }
        }
    }
}

- (void)layoutSubviews
{
    _imageView.frame = self.bounds;
    if (_originalImage)
    {
        if (_asynchronous)
        {
            [self performSelectorInBackground:@selector(processImage:) withObject:_originalImage];
        }
        else
        {
            [self processImage:_originalImage];
        }
    }
}

- (UIImage *)image
{
    return _originalImage;
}

- (void)setImage:(UIImage *)image
{
    if (image != _originalImage)
    {
        self.originalImage = image;
        if (image)
        {
            if (_asynchronous)
            {
                [self performSelectorInBackground:@selector(processImage:) withObject:image];
            }
            else
            {
                [self processImage:image];
            }
        }
        else
        {
            _imageView.image = nil;
        }
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
    if (_shadowColor != shadowColor)
    {
        
#if !__has_feature(objc_arc)
        
        [_shadowColor release];
        _shadowColor = [shadowColor retain];
        
#else
        
        _shadowColor = shadowColor;
        
#endif
        
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

#if !__has_feature(objc_arc)

- (void)dealloc
{
    [_originalImage release];
    [_imageView release];
    [_shadowColor release];
    [super dealloc];
}

#endif

@end
