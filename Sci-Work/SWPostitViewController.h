//
//  SWPostitViewController.h
//  Sci-Work
//
//  Created by userXD on 28.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWPostitViewController : UIViewController
- (IBAction)cancelButtonPressed:(id)sender;

- (IBAction)postButtonPressed:(id)sender;
@property (retain, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) id detailItem;
@end
