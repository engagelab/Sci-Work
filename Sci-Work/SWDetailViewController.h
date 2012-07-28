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
#import "GData.h"
#import "GDataEntryYouTubeUpload.h"

#import "URLParser.h"


@interface SWDetailViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    GDataServiceTicket *mUploadTicket;
    NSURL *mUploadLocationURL;
    UIImagePickerController *vpicker;
    
    NSMutableDictionary *jsonRequest;

}

@property (retain, nonatomic) UIImagePickerController *vpicker;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (nonatomic, retain) NSMutableDictionary *jsonRequest;

- (IBAction)recordVideo:(id)sender;
- (IBAction)postitButtonPressed:(id)sender;

@end
