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

-(void) postVideo;

-(void) postImage:(NSData*)imageData;

-(void) restfulPostMethodCore :(NSMutableURLRequest*)urlRequest;


//youtube
-(void)uploadToYoutbue:(NSURL*)videourl;
- (GDataServiceTicket *)uploadTicket;
- (void)setUploadTicket:(GDataServiceTicket *)ticket;


- (GDataServiceGoogleYouTube *)youTubeService;

- (void)ticket:(GDataServiceTicket *)ticket
hasDeliveredByteCount:(unsigned long long)numberOfBytesRead
ofTotalByteCount:(unsigned long long)dataLength;

@end

@implementation SWDetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;

//video
@synthesize vpicker;
@synthesize jsonRequest = _jsonRequest;


- (void)dealloc
{
    [_detailItem release];
    [_detailDescriptionLabel release];
    
    [mUploadTicket release];
    [mUploadLocationURL release];
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
        
        //intialize 
        [self setJsonRequest:newDetailItem];
    }
}



- (void)setJsonRequest:(NSMutableDictionary *)jsonRequestNew
{
    if (_jsonRequest != jsonRequestNew) {
        [_jsonRequest release];
        _jsonRequest = [jsonRequestNew retain];
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
    //_jsonRequest = [[NSMutableDictionary alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.detailDescriptionLabel = nil;
    //[_jsonRequest release];
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
            //vpicker.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeMovie];
            
            //To designate all available media types for a source
            vpicker.mediaTypes =     [UIImagePickerController availableMediaTypesForSourceType:
                                      
                                      UIImagePickerControllerSourceTypeCamera];//[NSArray arrayWithObject:(NSString*)kUTTypeMovie];
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

    //grab the media type
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];

    //create the liberary object
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    //create the completion block
    ALAssetsLibraryWriteImageCompletionBlock completion = ^(NSURL *assetsURL, NSError *error)
    {
        NSLog(@"Success! The new URL is: %@", assetsURL);
        
    };
                    
    /* Check if the media type is photo or vidoe and call respective action*/
    if ([mediaType isEqualToString:@"public.image"]) 
    {
        NSLog(@"it is an image");
        NSDictionary *metadata=[info objectForKey:UIImagePickerControllerMediaMetadata];
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        /*
         turning the image into a NSData object
         getting the image back out of the UIImageView
         setting the quality to 90
         */
        NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
        
        [self postImage:imageData];
        
        [assetsLibrary writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:completion];
        
    }
    else if ([mediaType isEqualToString:@"public.movie"]) 
    {
        NSLog(@"it is a movie");
        //grab url of recorded video
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        
        NSLog(@"The temporary URL is: %@", url);
        
        //upload movie to youtube
        [self uploadToYoutbue:url];
        
        //saving the video to local assest liberary
        [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:url completionBlock:completion];
        
    }

    
    //post video to youtube
    //[self uploadToYoutbue:[url absoluteString]];
    //post youtube link and metadata to sci-infrastructure server
    
    
    [assetsLibrary release];
    
    //dismiss the picker
    [picker dismissModalViewControllerAnimated:YES];
}









// GDATA YOUTUBE service




-(void)uploadToYoutbue:(NSURL*)videoPath;
{
    
    GDataServiceGoogleYouTube *service = [self youTubeService];
    
    NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:kGDataServiceDefaultUser];
    NSData *data = [NSData dataWithContentsOfURL:videoPath];
    NSString *filename = [videoPath lastPathComponent];
    
    
    // gather all the metadata needed for the mediaGroup
    NSString *titleStr = @"Video for Miracle";
    GDataMediaTitle *title = [GDataMediaTitle textConstructWithString:titleStr];
    
    NSString *categoryStr = @"Education";
    GDataMediaCategory *category = [GDataMediaCategory mediaCategoryWithString:categoryStr];
    [category setScheme:kGDataSchemeYouTubeCategory];
    
    //
    NSString *descStr = @"comming soon...";
    GDataMediaDescription *desc = [GDataMediaDescription textConstructWithString:descStr];
    
    //tags are possible with youtube videos
    NSString *keywordsStr = @"InterMedia";
    GDataMediaKeywords *keywords = [GDataMediaKeywords keywordsWithString:keywordsStr];
    
    BOOL isPrivate = NO;
    
    GDataYouTubeMediaGroup *mediaGroup = [GDataYouTubeMediaGroup mediaGroup];
    [mediaGroup setMediaTitle:title];
    [mediaGroup setMediaDescription:desc];
    [mediaGroup addMediaCategory:category];
    [mediaGroup setMediaKeywords:keywords];
    [mediaGroup setIsPrivate:isPrivate];

   
    
    NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:filename
                                               defaultMIMEType:@"video/mp4"];
    
    
    // create the upload entry with the mediaGroup and the file
    GDataEntryYouTubeUpload *entry;
    entry = [GDataEntryYouTubeUpload uploadEntryWithMediaGroup:mediaGroup
                                                          data:data 
                                                      MIMEType:mimeType 
                                                          slug:filename];
    //unlist from public search
    [entry addAccessControl:[GDataYouTubeAccessControl 
                             accessControlWithAction:@"list" permission:@"denied"]]; 

    
    SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
    [service setServiceUploadProgressSelector:progressSel];
    
    GDataServiceTicket *ticket;
    ticket = [service fetchEntryByInsertingEntry:entry
                                      forFeedURL:url
                                        delegate:self
                               didFinishSelector:@selector(uploadTicket:finishedWithEntry:error:)];
        
    [self setUploadTicket:ticket];
}



// progress callback
- (void)ticket:(GDataServiceTicket *)ticket
hasDeliveredByteCount:(unsigned long long)numberOfBytesRead
ofTotalByteCount:(unsigned long long)dataLength {
    
    //double p = (double)numberOfBytesRead / (double)dataLength;
    //NSLog(@"video upload progress: %@",p);
    //[DDLogVerbose(@"progress %d",p);
    
    //[mUploadProgressIndicator setProgress:p animated:YES];
}



// upload callback
- (void)uploadTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
               error:(NSError *)error {
    
    if (error == nil) {
        
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Hey!!!!" message:@"Video upload completed..." delegate:self cancelButtonTitle:@"Done" otherButtonTitles: nil];
        [alert show];
        [alert release];
        
        //fetch youtube url
        NSString *url = [[[[videoEntry mediaGroup] mediaPlayers] objectAtIndex:0] URLString];
        URLParser *parser = [[URLParser alloc] initWithURLString:url];
        NSString *v = [parser valueForVariable:@"v"];
        
        // insert youtube url into jsonYoutubeRequest
        [_jsonRequest setValue:v
                      forKey:@"uri"];
        
        NSLog(@"_jsonRequest : %@",_jsonRequest);
        
        // post this video metadata on sci-infra
        [self postVideo];

    } else {
        
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Hey upload failed!!!!" message:@"Try again..." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        
    }
    
   // [mUploadProgressIndicator setProgress:0.0];
    
    [self setUploadTicket:nil];
}



#pragma mark -

// get a YouTube service object
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleYouTube *)youTubeService {
    
    static GDataServiceGoogleYouTube* service = nil;
    
    if (!service) {
        service = [[GDataServiceGoogleYouTube alloc] init];
        
        [service setShouldCacheResponseData:YES];
        [service setServiceShouldFollowNextLinks:YES];
        [service setIsServiceRetryEnabled:YES];
    }
    
    NSString *devKey = @"AI39si5ks7j5bAJYbTpdjCDECT3m7r_wx5ZV7vM8ZY0wCayYqpajmWwVgHkscRtMvkfbvM1GgAkigqMPyXNi-0PAHvr_BmdPAQ";
    [service setYouTubeDeveloperKey:devKey];
    [service setUserCredentialsWithUsername:@"encoresignup@gmail.com" password:@"enc0relab"];
    
    return service;
}





- (GDataServiceTicket *)uploadTicket {
    return mUploadTicket;
}

- (void)setUploadTicket:(GDataServiceTicket *)ticket {
    [mUploadTicket release];
    mUploadTicket = [ticket retain];
}

- (NSURL *)uploadLocationURL {
    return mUploadLocationURL;
}

- (void)setUploadLocationURL:(NSURL *)url {
    [mUploadLocationURL release];
    mUploadLocationURL = [url retain];
}


// End of youtube service







-(void) postVideo
{
    
    [_jsonRequest setValue:@"Video for Miracle"
                    forKey:@"title"];
    
    [_jsonRequest setValue:[NSNumber numberWithUnsignedInteger:3]
                    forKey:@"runId"];
    
    NSError *error; 
    NSData *jsonDataLocal = [NSJSONSerialization dataWithJSONObject:_jsonRequest 
                                                            options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                              error:&error];
    if (! jsonDataLocal) {
        NSLog(@"Got an error: %@", error);
    } 
    else 
    {
        // body as json string
        NSString *body = [[NSString alloc] initWithData:jsonDataLocal encoding:NSUTF8StringEncoding];
        
        NSData *jsonBodyData =[body dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *urlAsString = @"http://imediamac11.uio.no:9000/group/video/";
        
        NSURL *url = [NSURL URLWithString:urlAsString];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:3000.0f];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setHTTPBody:jsonBodyData];
        
        [self restfulPostMethodCore: urlRequest];
        
    }
    
}


-(void) postImage:(NSData*)imageData
{
    
    [_jsonRequest setValue:@"Video for Miracle"
                    forKey:@"title"];
    
    [_jsonRequest setValue:[NSNumber numberWithUnsignedInteger:3]
                    forKey:@"runId"];
    
    NSError *error; 
    NSData *jsonDataLocal = [NSJSONSerialization dataWithJSONObject:_jsonRequest 
                                                            options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                              error:&error];
    if (! jsonDataLocal) {
        NSLog(@"Got an error: %@", error);
    } 
    else 
    {

        // setting up the URL to post to
        NSString *urlString = @"http";
        
        // setting up the request object now
        NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] init] autorelease];
        [urlRequest setURL:[NSURL URLWithString:urlString]];
        [urlRequest setHTTPMethod:@"POST"];
        
        /*
         add some header info now
         we always need a boundary when we post a file
         also we need to set the content type
         
         You might want to generate a random boundary.. this is just the same
         as my output from wireshark on a valid html post
         */
        NSString *stringBoundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
        [urlRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];


        /*
         now lets create the body of the post
         */
        NSMutableData *postBody = [NSMutableData data];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"source\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithString:@"lighttable"] dataUsingEncoding:NSUTF8StringEncoding]];  // So Light Table show up as source in Twitter post
        
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"title\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithString:@"book title"] dataUsingEncoding:NSUTF8StringEncoding]];  // title
        
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"isbn\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithString:@"isbn info"] dataUsingEncoding:NSUTF8StringEncoding]];  // isbn
        
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"price\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithString:@"price is"] dataUsingEncoding:NSUTF8StringEncoding]];  // Price
        
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"condition\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithString:@"condition is"] dataUsingEncoding:NSUTF8StringEncoding]];  // Price
        
        
        NSString *imageFileName = [NSString stringWithFormat:@"photo.jpeg"];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upload\"; filename=\"%@\"\r\n",imageFileName] dataUsingEncoding:NSUTF8StringEncoding]];
        //[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upload\"\r\n\n\n"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postBody appendData:imageData];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        //  [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSLog(@"postBody=%@", [[NSString alloc] initWithData:postBody encoding:NSASCIIStringEncoding]);
        [urlRequest setHTTPBody:postBody];
        
        NSLog(@"Image data=%@",[[NSString alloc] initWithData:imageData encoding:NSASCIIStringEncoding]);
        
        // Spawn a new thread so the UI isn't blocked while we're uploading the image
        [NSThread detachNewThreadSelector:@selector(uploadingDataWithURLRequest:) toTarget:self withObject:urlRequest]; 

        
    }
    
}




-(void) restfulPostMethodCore :(NSMutableURLRequest*)urlRequest
{
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error) {
         if ([data length] >0 &&
             error == nil){
             NSString *json = [[NSString alloc] initWithData:data
                                                    encoding:NSUTF8StringEncoding];
             NSLog(@"JSON = %@", json);
         }
         else if ([data length] == 0 &&
                  error == nil){
             NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             NSLog(@"Error happened = %@", error);
         }
     }];
}


@end
