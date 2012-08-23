//
//  ViewController.h
//  ImageFXViewDemo
//
//  Created by Nick Lockwood on 31/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXImageView.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet FXImageView *imageView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, strong) IBOutlet UILabel *successLabel;
@property (nonatomic, strong) IBOutlet UIButton *button;

- (IBAction)update;

@end
