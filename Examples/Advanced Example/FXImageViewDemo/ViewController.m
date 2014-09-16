//
//  ViewController.m
//  ImageFXViewDemo
//
//  Created by Nick Lockwood on 31/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (nonatomic, copy) NSArray *imagePaths;
@property (nonatomic, weak) IBOutlet iCarousel *carousel;

@end


@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        //get image paths
        self.imagePaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg" inDirectory:@"Lake"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //configure carousel
    _carousel.type = iCarouselTypeCoverFlow2;
}

- (NSInteger)numberOfItemsInCarousel:(__unused iCarousel *)carousel
{
    return [_imagePaths count];
}

- (UIView *)carousel:(__unused  iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    //create new view if no view is available for recycling
    if (view == nil)
    {
        FXImageView *imageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.asynchronous = YES;
        imageView.reflectionScale = 0.5f;
        imageView.reflectionAlpha = 0.25f;
        imageView.reflectionGap = 10.0f;
        imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
        imageView.shadowBlur = 5.0f;
        imageView.cornerRadius = 10.0f;
        
        view = imageView;
    }
    
    //load image
    [(FXImageView *)view setImageWithContentsOfFile:_imagePaths[index]];
    
    return view;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
