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
	
    //configure image effects
    self.imageView.reflectionScale = 0.5f;
    self.imageView.reflectionAlpha = 0.25f;
    self.imageView.reflectionGap = 10.0f;
    self.imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.imageView.shadowBlur = 5.0f;
    self.imageView.cornerRadius = 10.0f;
    self.imageView.asynchronous = YES;
    
    //observe image updates
    [self.imageView addObserver:self forKeyPath:@"processedImage" options:(NSKeyValueObservingOptions)0 context:NULL];
}

- (void)observeValueForKeyPath:(__unused NSString *)keyPath
                      ofObject:(id)object
                        change:(__unused NSDictionary *)change
                       context:(__unused void *)context
{
    if (object)
    {
        //success
        [self.activityView stopAnimating];
        self.successLabel.text = @"Download Complete";
        self.button.enabled = YES;
        self.button.alpha = 1.0f;
    }
}

- (IBAction)update
{
    //reset display
    self.imageView.image = nil;
    self.successLabel.text = nil;
    [self.activityView startAnimating];
    self.button.enabled = NO;
    self.button.alpha = 0.25f;
    
    //clear cache
    [[FXImageView processedImageCache] removeAllObjects];
    
    //begin download
    NSString *URLString = @"http://charcoaldesign.co.uk/AsyncImageView/Lake/IMG_0150.jpg";
    URLString = [URLString stringByAppendingFormat:@"?cachebuster=%f", [NSDate timeIntervalSinceReferenceDate]];
    [self.imageView setImageWithContentsOfURL:[NSURL URLWithString:URLString]];
}

- (void)dealloc
{
    //remove observers
    [self.imageView removeObserver:self forKeyPath:@"processedImage" context:NULL];
    
}

@end
