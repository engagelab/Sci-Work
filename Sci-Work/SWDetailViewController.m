//
//  SWDetailViewController.m
//  Sci-Work
//
//  Created by userXD on 17.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWDetailViewController.h"

@interface SWDetailViewController ()
- (void)configureView;
@end

@implementation SWDetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;

//video
@synthesize vpicker;


- (void)dealloc
{
    [_detailItem release];
    [_detailDescriptionLabel release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];

        // Update the view.
        [self configureView];
    }
}



- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}





- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.detailDescriptionLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)recordVideo:(id)sender 
{

    //check if image picker does not exist then create new picker and assing to current view
    if (!vpicker) {
        vpicker = [[UIImagePickerController alloc] init];
        vpicker.delegate = self;
    }
    
    //Check if the camera is available
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) 
    {
        
        //find available media types
        NSArray* mediaTypes = [ UIImagePickerController
                               availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        
        //is video one of the available types?
        if ([mediaTypes containsObject:(NSString*) kUTTypeMovie]) {
            
            //restrict source type to camera
            vpicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //vpicker.sourceType = UIImagePickerControllerCameraCaptureModeVideo;
            //            vpicker.startVideoCapture;
            //            vpicker.showsCameraControls;
            //restrict media type to video
            vpicker.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeMovie];
        }
        else {
            // if no video support 
            NSLog(@"Your device does not support recording videos");
        }
        
    }
    
    // finally, present the picker!
    [self presentModalViewController:vpicker animated:YES];
    
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    //grab url of recorded video
    NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
    NSLog(@"The temporary URL is: %@", url);
    
    //create the liberary object
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    //create the completion block
    ALAssetsLibraryWriteImageCompletionBlock completion = ^(NSURL *assetsURL, NSError *error)
    {
        
        NSLog(@"Success! The new URL is: %@", assetsURL);
    };
    
    
    //saving the video
    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:url completionBlock:completion];
    [assetsLibrary release];
    
    //dismiss the picker
    [picker dismissModalViewControllerAnimated:YES];
}


@end
