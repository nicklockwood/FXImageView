//
//  ViewController.m
//  ImageFXViewDemo
//
//  Created by Nick Lockwood on 31/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.imageView.reflectionScale = 0.5f;
    self.imageView.reflectionAlpha = 0.25f;
    self.imageView.reflectionGap = 10.0f;
    self.imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.imageView.shadowBlur = 5.0f;
    self.imageView.cornerRadius = 10.0f;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


@end
