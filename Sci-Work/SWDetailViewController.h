//
//  SWDetailViewController.h
//  Sci-Work
//
//  Created by userXD on 17.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface SWDetailViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    
    UIImagePickerController *vpicker;

}

@property (retain, nonatomic) UIImagePickerController *vpicker;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;


- (IBAction)recordVideo:(id)sender;

@end
