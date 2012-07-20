//
//  SWTaskViewController.m
//  Sci-Work
//
//  Created by userXD on 17.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWTaskViewController.h"


@interface SWTaskViewController ()

-(void) fetchTaskTitlesFromServer;
-(void)extractTaskTitles: (NSMutableArray*)json;

@end





@implementation SWTaskViewController
@synthesize groupName = _groupName;




- (void)setGroupName:(id)newGroupName
{
    if (_groupName != newGroupName) {
        [_groupName release];
        _groupName = [newGroupName retain];
        NSLog(@"groupName: %@",_groupName);
        // Update the view.
        //[self configureView];
    }
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchTaskTitlesFromServer];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
  
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [listofTaskTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDate *object = [listofTaskTitles objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [object description];
    
    return cell;

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetails"])
    {
        //SWDetailViewController *viewController = [segue destinationViewController];

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *object = [listofTaskTitles objectAtIndex:indexPath.row];
        
        //send data to detailed view controller
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:object forKey:@"taskName"];
        [dic setValue:_groupName forKey:@"groupName"];
                                             
        //object = [object stringByAppendingString:(NSString*)_groupName];
        //[viewController setJsonYoutubeRequest:dic];
        //viewController.detailItem = [self.tableView indexPathForSelectedRow];
        
        [[segue destinationViewController] setDetailItem:dic];
        
        [dic release];

    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}



//utility methods

-(void) fetchTaskTitlesFromServer
{
    NSString *urlString = [NSString stringWithFormat:@"http://imediamac11.uio.no:9000/task/project/4ff6ce6b300436aabefc1b1a"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSError *error;
    
    NSMutableArray *json = (NSMutableArray*)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSLog(@"%@", [json objectAtIndex:0]);
    
    [self extractTaskTitles:json];
    
}


-(void)extractTaskTitles:(NSMutableArray *)json
{
    NSMutableArray *taskTitles = [NSMutableArray array];
    
    for (NSDictionary *dict in json)
    {
        NSString *title = [[NSString alloc] init] ;
        title = [dict objectForKey:@"title"];
        [taskTitles addObject:title];
    }
    
    listofTaskTitles = [[NSMutableArray alloc]initWithArray:taskTitles];       
    
    NSLog(@"Group Names Array = %@", listofTaskTitles);
}


@end
