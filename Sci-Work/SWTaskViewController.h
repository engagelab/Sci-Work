//
//  SWTaskViewController.h
//  Sci-Work
//
//  Created by userXD on 17.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWDetailViewController.h"

@interface SWTaskViewController : UITableViewController
{

    NSMutableArray *listofTaskTitles;
    NSMutableArray *listofTaskIds;
}

@property (strong, nonatomic) id groupInfo;
@end
