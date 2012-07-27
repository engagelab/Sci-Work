//
//  SWMasterViewController.h
//  Sci-Work
//
//  Created by userXD on 17.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "SWTaskViewController.h"

@interface SWMasterViewController : UITableViewController
{
    // use for rendering TABLEVIEW cells
    NSMutableArray *listofGroupName;
    
    // use for posting video metadata on sci-infrastructure
    NSMutableArray *listofGroupId;
    
    //use for extracting group members
    NSMutableArray *listOfGroupMembers;
}

@end
