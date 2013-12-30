//
//  DetailViewController.m
//  Net-Statistics
//
//  Created by Michael Worden on 12/29/13.
//  Copyright (c) 2013 Michael Worden. All rights reserved.
//

#import "DetailViewController.h"
#import "netConnection.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        netConnection *connection = self.detailItem;
        
        self.lblForeignAddress.text = connection.foreignAddress;
        self.lblLocalAddress.text = connection.localAddress;
        self.lblForeignPort.text = connection.foreignPort;
        self.lblLocalPort.text = connection.localPort;
        self.lblTXBytes.text = [NSString stringWithFormat:@"%@", connection.txBytes];
        self.lblRCVBytes.text = [NSString stringWithFormat:@"%@", connection.rxBytes];
        self.lblTXQueue.text = [NSString stringWithFormat:@"%@", connection.txQueue];
        self.lblRCVQueue.text = [NSString stringWithFormat:@"%@", connection.rxQueue];
        self.lblState.text = connection.state;
        
        
        //        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}



@end