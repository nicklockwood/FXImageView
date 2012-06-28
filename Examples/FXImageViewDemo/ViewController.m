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
	
    _imageView.asynchronous = YES;
    _imageView.reflectionScale = 0.5f;
    _imageView.reflectionAlpha = 0.25f;
    _imageView.reflectionGap = 10.0f;
    _imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
    _imageView.shadowBlur = 5.0f;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc
{
    [_imageView release];
    [super dealloc];
}

@end
