//
//  SWPostitViewController.m
//  Sci-Work
//
//  Created by userXD on 28.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPostitViewController.h"

@interface SWPostitViewController ()

-(void) submitPosit:(NSMutableDictionary*)postit;
-(void) restfulPostMethodCore :(NSMutableURLRequest*)urlRequest;

@end

@implementation SWPostitViewController

@synthesize textView;
@synthesize detailItem = _detailItem;




- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];
    }
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}




- (void)dealloc {
    [textView release];
    [super dealloc];
    [_detailItem release];
}






- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}






- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];

}





- (IBAction)postButtonPressed:(id)sender {
    
    
//    NSMutableDictionary *posit = [[NSMutableDictionary alloc] init];
//    [posit setObject:textView.text forKey:@"content"];
//    [posit setObject:@"groupId" forKey:@"groupId"];
//    [posit setObject:@"taskId" forKey:@"taskId"];
//    [posit setObject:@"runId" forKey:@"runId"];
    [_detailItem setObject:textView.text forKey:@"content"];
    [_detailItem setObject:@"10" forKey:@"xpos"];
    [_detailItem setObject:@"10" forKey:@"ypos"];
     [_detailItem setObject:@"3" forKey:@"runId"];
    
    [self submitPosit:_detailItem ];
    [self dismissModalViewControllerAnimated:YES];}





-(void)submitPosit:(NSMutableDictionary*)postit
{
    NSError *error; 
    NSData *jsonDataLocal = [NSJSONSerialization dataWithJSONObject:postit 
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
        
        NSString *urlAsString = @"http://imediamac11.uio.no:9000/task/postit/";
        
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
             
             UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Hey!!!!" message:@"Posit now avialble on web" delegate:self cancelButtonTitle:@"Done" otherButtonTitles: nil];
             [alert show];
             [alert release];
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
