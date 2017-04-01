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
	
    self.imageView.reflectionScale = 0.5;
    self.imageView.reflectionAlpha = 0.25;
    self.imageView.reflectionGap = 10.0;
    self.imageView.shadowOffset = CGSizeMake(0.0, 2.0);
    self.imageView.shadowBlur = 5.0;
    self.imageView.cornerRadius = 10.0;
}

@end
