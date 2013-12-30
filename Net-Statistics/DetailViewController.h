//
//  DetailViewController.h
//  Net-Statistics
//
//  Created by Michael Worden on 12/29/13.
//  Copyright (c) 2013 Michael Worden. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblLocalAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblForeignAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblLocalPort;
@property (weak, nonatomic) IBOutlet UILabel *lblForeignPort;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (weak, nonatomic) IBOutlet UILabel *lblTXBytes;
@property (weak, nonatomic) IBOutlet UILabel *lblRCVBytes;
@property (weak, nonatomic) IBOutlet UILabel *lblTXQueue;
@property (weak, nonatomic) IBOutlet UILabel *lblRCVQueue;
@end