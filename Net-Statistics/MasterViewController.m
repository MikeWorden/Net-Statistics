//
//  MasterViewController.m
//  Net-Statistics
//
//  Created by Michael Worden on 12/29/13.
//  Copyright (c) 2013 Michael Worden. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NetUtils.h"
#import "netInterface.h"
#import "netConnection.h"


//Private Methods/Objects
@interface MasterViewController () {
    
    NSMutableArray *_objects;
    
}
-(NSString *) imageForState: (NSString *) state ;
- (void) updateConnectionList;


@end

@implementation MasterViewController
@synthesize myDevice = _myDevice;

//Lazy Instantiation -- ensure we only do this once
- (iDevice *) myDevice
{
    if (!_myDevice){
        _myDevice = [[iDevice alloc] init];
    }
    return _myDevice;
    
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *scanButton = [[ UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateConnectionList)];
    self.navigationItem.rightBarButtonItem = scanButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    _myDevice = [[iDevice alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _myDevice.netInterfaces.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    netInterface *sectionInterface = _myDevice.netInterfaces[section];
    
    NSArray *connectionList = sectionInterface.netConnections;
    return connectionList.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConnectionData";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        [NSException raise:@"cell == nil.." format:@"No cells with matching CellIdentifier loaded from my storyboard"];
    }
    
   
    netInterface *sectionInterface = _myDevice.netInterfaces[indexPath.section];
    NSArray *connectionList = sectionInterface.netConnections;
    
    netConnection *connection = [connectionList objectAtIndex:indexPath.row];
    
    UILabel *foreignAddressLabel = (UILabel *)[cell viewWithTag:201];
    NSString *foreignAddressText = [NSString stringWithFormat:@"%@", connection.foreignAddress];
    [foreignAddressLabel setText:foreignAddressText];
    
    UILabel *foreignPortLabel = (UILabel *) [cell viewWithTag:202];
    NSString *foreignPortText = [NSString stringWithFormat:@"Port: %@", connection.foreignPort];
    [foreignPortLabel setText:foreignPortText ];
    
    NSString *imageLabel =  [self imageForState: connection.state];
    UIImage * stateImage = [UIImage imageNamed: imageLabel];
    UIImageView *stateImageView = (UIImageView *) [cell viewWithTag:203];
    [stateImageView setImage:stateImage];
    
    UILabel *connectionStateLabel = (UILabel *) [cell viewWithTag:204];
    NSString *connectionStateText = [NSString stringWithFormat:@"%@", connection.state];
    [connectionStateLabel setText:connectionStateText ];
    

    
    
    
   
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}




-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"SectionHeader";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (headerView == nil){
        [NSException raise:@"headerView == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }
    [headerView setBackgroundColor:[UIColor blueColor]];
    
    netInterface *interface = _myDevice.netInterfaces[section];
    NSString *nameText = [NSString stringWithFormat:@"%@:  %@", interface.interfaceType, interface.interfaceDetail];
    
    UILabel *nameLabel = (UILabel *)[headerView viewWithTag:125];
    [nameLabel setText:nameText];

    UILabel *detailLabel = (UILabel *) [headerView viewWithTag:123];
    [detailLabel setText: interface.netAddress];

    return headerView;
}


// Required to work around a bug where the cell layout
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"SectionHeader";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    CGFloat height = [headerView bounds].size.height;
    return height;
}
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        netInterface *sectionInterface = _myDevice.netInterfaces[indexPath.section];
        NSArray *connectionList = sectionInterface.netConnections;
        
        netConnection *connection = [connectionList objectAtIndex:indexPath.row];
        self.detailViewController.detailItem = connection;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([[segue identifier] isEqualToString:@"showConnection"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        netInterface *sectionInterface = _myDevice.netInterfaces[indexPath.section];
        NSArray *connectionList = sectionInterface.netConnections;
        
        netConnection *connection = [connectionList objectAtIndex:indexPath.row];
        self.detailViewController.detailItem = connection;

        [[segue destinationViewController] setDetailItem:connection];
    }
}

-(NSString *) imageForState: (NSString *) state {
    
    NSString *stateImage = @"unknown.png";
    
    if ([state isEqualToString:@"CLOSED"]) {
        stateImage = @"closed.png";
    }
    if ([state isEqualToString:@"CLOSING"]) {
        stateImage = @"closed.png";
    }
    if ([state isEqualToString:@"ESTABLISHED"]) {
        stateImage = @"established.png";
    }
    if ([state isEqualToString:@"SYN_SENT"]) {
        stateImage = @"syn_sent.png";
    }
    if ([state isEqualToString:@"SYN_RECEIVED"]) {
        stateImage = @"syn_received.png";
    }
    if ([state isEqualToString:@"FIN_WAIT1"]) {
        stateImage = @"fin_wait1.png";
    }
    if ([state isEqualToString:@"FIN_WAIT2"]) {
        stateImage = @"fin_wait2.png";
    }
    if ([state isEqualToString:@"LISTEN"]) {
        stateImage = @"listen.png";
    }
    return stateImage;
}


// Deletes all connections & updates the connectionlist -- SLOW!
//TODO:  work around section header bug in UIKit
- (void) updateConnectionList {
    
    
    //Clear out the last record of connections
    NSInteger numSections = [self numberOfSectionsInTableView:self.tableView] ;
    
    int numRowsInSection = 0;
    int i, j;
    NSIndexPath *indexPath;
    
    
    if (_myDevice.netInterfaces != nil) {
        
        for ( i = 0; i < numSections; i++) {
            numRowsInSection = [self.tableView numberOfRowsInSection:i ];
            for (j =1; j <= numRowsInSection; j++) {
                //indexPath is a reference to a spot in our table
                indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
                
                
                // Table deletes have to be done as a transaction that clears the UI and updates the underlying array
                [self.tableView beginUpdates];
                
                //Delete the Entry in the Table UI
                
                UITableViewCell *headerView = [self.tableView cellForRowAtIndexPath:indexPath];
             
                if ([headerView.reuseIdentifier isEqualToString:@"ConnectionData"]) {
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                          withRowAnimation:UITableViewRowAnimationFade];
                }

                
                //Then delete the interface object that created that table
                [[_myDevice.netInterfaces[indexPath.section] netConnections] removeObjectAtIndex:0];
                
                [self.tableView endUpdates];
                
            }
            
        }
        
        [_myDevice updateConnections];
        [self.tableView reloadData];
        
    }
    
}


@end
