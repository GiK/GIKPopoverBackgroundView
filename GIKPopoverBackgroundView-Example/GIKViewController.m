//
//  GIKViewController.m
//  GIKPopoverBackgroundView
//
//  Created by Gordon Hughes on 1/7/13.
//  Copyright (c) 2013 Gordon Hughes. All rights reserved.
//

#import "GIKViewController.h"
#import "GIKPopoverBackgroundView.h"

@interface GIKViewController () {
    UIPopoverController *popoverController;
    NSString *segueIdentifier;
}

@end

@implementation GIKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]])
    {
        segueIdentifier = segue.identifier;
        popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
        popoverController.popoverBackgroundViewClass = [GIKPopoverBackgroundView class];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (popoverController && popoverController.popoverVisible)
    {
        [popoverController dismissPopoverAnimated:YES];
        [self performSegueWithIdentifier:segueIdentifier sender:nil];
    }
}


#pragma mark - iOS 6 rotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


#pragma mark - iOS 5 rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
