//
//  ViewController.m
//  ImageFXViewDemo
//
//  Created by Nick Lockwood on 31/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#define COVER_HEIGHT_PERCENT .6
#define EDGE_PERCENT .05
#define radians(degrees) (degrees * M_PI/180)

@implementation ViewController

@synthesize carousel = _carousel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //configure carousel
    _carousel.type = iCarouselTypeCoverFlow2;
    
    // load our assets from the ALAssets library
    [self loadAssets:(ALAssetsGroupAlbum | ALAssetsGroupSavedPhotos | ALAssetsGroupEvent)];
    
}

- (void)loadAssets:(NSUInteger) groupType {
    // load up our image assets, defaulting to the first group found (for now)
    if (!assetsLibrary) {
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (!groups) {
        groups = [[NSMutableArray alloc] initWithCapacity:1];
    } else {
        [groups removeAllObjects];
    }
    
    // setup our asynchronous code blocks to process
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group) {
            // place any found groups in an array as we roll through the library
            [groups addObject:group];
        }
        else {
            [_carousel reloadData];
            
            if ([groups count] > 0) {
                [self selectGroupAtIndex:0];
            }
            else {
                [groupLabel setText:@"No Name"];
            }
            
        }
    };
    
    // this block is used if we fail to load groups
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
                NSLog(@"User Denied Access");
                break;
            case ALAssetsLibraryAccessGloballyDeniedError:
                NSLog(@"Global Access Denied");
                break;
            default:
                NSLog(@"Unknown Error");
                break;
        }
        
    };
    
    NSUInteger groupTypes = groupType;
    [assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    
}

- (void)selectGroupAtIndex:(int) index {
    // now deal with our stuff
    if ([groups count] > index)
    {
        [groupLabel setText:[[groups objectAtIndex:index] valueForProperty:ALAssetsGroupPropertyName]];
    }
    
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [groups count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    CGFloat height = _carousel.bounds.size.height * COVER_HEIGHT_PERCENT;
    
    if (view == nil) {
        FXImageView* fxiv = [[FXImageView alloc] initWithFrame:CGRectMake(0, 0, height, height)];
        
        UIImage* (^applyGroup)(UIImage* image);
        applyGroup = ^(UIImage* image){
            UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
            CGContextRef c = UIGraphicsGetCurrentContext();
            
            // drop inside and add the white edges
            float inset = MIN(image.size.width, image.size.height) * EDGE_PERCENT;
            CGRect insetRect = CGRectInset(CGRectMake(0, 0, image.size.width, image.size.height), inset, inset);
            CGContextSetRGBFillColor(c,1,1,1,1);
            
            // draw the tilted tiles
            CGContextSaveGState(c);
            CGContextTranslateCTM(c, 0.5f * insetRect.size.width, 0.5f * insetRect.size.height);
            CGContextRotateCTM (c, radians((rand() % 5 + 2)));
            CGContextTranslateCTM(c, -0.5f * insetRect.size.width, -0.5f * insetRect.size.height);
            CGContextFillRect(c,insetRect);
            CGContextRestoreGState(c);
            
            CGContextSaveGState(c);
            CGContextTranslateCTM(c, 0.5f * insetRect.size.width, 0.5f * insetRect.size.height);
            CGContextRotateCTM (c, radians(-(rand() % 5 + 2)));
            CGContextTranslateCTM(c, -0.5f * insetRect.size.width, -0.5f * insetRect.size.height);
            CGContextSetShadow(c, CGSizeMake(0, 0), 10);
            CGContextFillRect(c,insetRect);
            CGContextRestoreGState(c);
            
            // draw the main image background
            CGContextSaveGState(c);
            CGContextSetShadow(c, CGSizeMake(0, 0), 10);
            CGContextFillRect(c,insetRect);
            CGContextRestoreGState(c);
            
            // drop in again and draw the image
            insetRect = CGRectInset(insetRect, inset/2, inset/2);
            [image drawInRect:insetRect];
            
            //capture resultant image
            UIImage *comp = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            //return composite image
            return comp;
        };
        fxiv.customEffectsBlock = applyGroup;
        fxiv.asynchronous = YES;
        fxiv.customEffectsIdentifier = [NSString stringWithFormat:@"%d",index];
        view = fxiv;
        
    }
    
    //show placeholder
    ((FXImageView *)view).processedImage = [UIImage imageNamed:@"Loading.png"];
    
    ALAssetsGroup* group = [groups objectAtIndex:index];
    
    // grab our low resolution placeholder image
    CGImageRef ref = [group posterImage];
    CGFloat widthScale = _carousel.bounds.size.width * COVER_HEIGHT_PERCENT;
    widthScale = widthScale / CGImageGetWidth(ref);
    CGFloat heightScale = height;
    heightScale = heightScale / CGImageGetHeight(ref);
    CGFloat scaleFactor = MIN(widthScale, heightScale);
    UIImage* coverImage;
    if (ref) {
        coverImage = [UIImage imageWithCGImage:ref scale:1/scaleFactor orientation:UIImageOrientationUp];
    }
    else {
        coverImage = [UIImage imageNamed:@"Sunflower.png"];
    }
    
    
    [(FXImageView*)view setImage:coverImage];
    return view;
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self selectGroupAtIndex:[carousel currentItemIndex]];
    }
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel {
    [self selectGroupAtIndex:[carousel currentItemIndex]];    
}

// called when tapped
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    [self selectGroupAtIndex:index];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [_carousel reloadData];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionWrap:
            return YES;
            break;
        case iCarouselOptionTilt:
            return .8;
            break;
        case iCarouselOptionSpacing:
            return .2;
            break;
        default:
            return value;
            break;
    }
    
}

- (void)dealloc
{
    [_carousel release];
    [groups removeAllObjects];
    [groups release];
    [assetsLibrary release];
    [super dealloc];
}

@end
