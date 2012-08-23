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
@synthesize activityView = _activityView;
@synthesize successLabel = _successLabel;
@synthesize button = _button;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //configure image effects
    _imageView.reflectionScale = 0.5f;
    _imageView.reflectionAlpha = 0.25f;
    _imageView.reflectionGap = 10.0f;
    _imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
    _imageView.shadowBlur = 5.0f;
    _imageView.cornerRadius = 10.0f;
    _imageView.asynchronous = YES;
    
    //observe image updates
    [_imageView addObserver:self forKeyPath:@"processedImage" options:0 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object)
    {
        //success
        [_activityView stopAnimating];
        _successLabel.text = @"Download Complete";
        _button.enabled = YES;
        _button.alpha = 1.0f;
    }
}

- (IBAction)update
{
    //reset display
    //_imageView.image = nil;
    _successLabel.text = nil;
    [_activityView startAnimating];
    _button.enabled = NO;
    _button.alpha = 0.25f;
    
    //clear cache
    [[FXImageView processedImageCache] removeAllObjects];
    
    //begin download
    NSString *URLString = @"http://charcoaldesign.co.uk/AsyncImageView/Lake/IMG_0150.jpg";
    URLString = [URLString stringByAppendingFormat:@"?cachebuster=%f", [NSDate timeIntervalSinceReferenceDate]];
    [_imageView setImageWithContentsOfURL:[NSURL URLWithString:URLString]];
}

- (void)dealloc
{
    //remove observers
    [_imageView removeObserver:self forKeyPath:@"processedImage" context:NULL];
    
    [_imageView release];
    [_activityView release];
    [_successLabel release];
    [super dealloc];
}

@end
