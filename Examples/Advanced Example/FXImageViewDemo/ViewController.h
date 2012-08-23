//
//  ViewController.h
//  ImageFXViewDemo
//
//  Created by Nick Lockwood on 31/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "FXImageView.h"
#import "iCarousel.h"

@interface ViewController : UIViewController <iCarouselDataSource, iCarouselDelegate> {
    // asset library
    ALAssetsLibrary*                assetsLibrary;      ///< The asset library pointer used while accessing assets
    NSMutableArray*                 groups;             ///< An array of [ALAssetsGroup] objects that hold all groups in a library
    
    IBOutlet UILabel*               groupLabel;         ///< The label indicating the common name of the selected group
}

@property (nonatomic, strong) IBOutlet iCarousel *carousel;

@end
