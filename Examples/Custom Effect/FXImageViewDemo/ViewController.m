//
//  ViewController.m
//  ImageFXViewDemo
//
//  Created by Nick Lockwood on 31/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize imageView = _imageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _imageView.reflectionScale = 0.5f;
    _imageView.reflectionAlpha = 0.25f;
    _imageView.reflectionGap = 10.0f;
    _imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
    _imageView.shadowBlur = 5.0f;
    _imageView.cornerRadius = 10.0f;
    _imageView.customEffectsBlock = ^(UIImage *image){
        
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //apply mask
        UIImage *mask = [UIImage imageNamed:@"mask.png"];
        CGContextClipToMask(context, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), mask.CGImage);
        
        //draw image
        [image drawAtPoint:CGPointZero];

        //capture resultant image
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //return image
        return image;
    };
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


@end
