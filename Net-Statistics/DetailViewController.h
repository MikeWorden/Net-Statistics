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
@end
