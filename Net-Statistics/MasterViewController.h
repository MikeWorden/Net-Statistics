//
//  MasterViewController.h
//  Net-Statistics
//
//  Created by Michael Worden on 12/29/13.
//  Copyright (c) 2013 Michael Worden. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
