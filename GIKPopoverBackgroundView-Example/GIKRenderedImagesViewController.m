//
//  GIKRenderedImagesViewController.m
//  GIKPopoverBackgroundView
//
//  Created by Gordon Hughes on 1/7/13.
//  Copyright (c) 2013 Gordon Hughes. All rights reserved.
//

#import "GIKRenderedImagesViewController.h"
#import "GIKRenderedImagesPopoverBackgroundView.h"

@interface GIKRenderedImagesViewController () {
    UIPopoverController *popoverController;
    NSString *segueIdentifier;
}

@end

@implementation GIKRenderedImagesViewController

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
        popoverController.popoverBackgroundViewClass = [GIKRenderedImagesPopoverBackgroundView class];
        
        if ([segue.identifier isEqualToString:@"popover2"])
        {
            UINavigationBar *navBar = [(UINavigationController *)popoverController.contentViewController navigationBar];
            [self applyTitleTextAttributesToNavigationBar:navBar];
        }
    }
}

- (void)applyTitleTextAttributesToNavigationBar:(UINavigationBar *)navBar
{
    NSDictionary *attributes = @{ UITextAttributeTextColor : [UIColor colorWithRed:122.0/255.0 green:120.0/255.0 blue:114.0/255.0 alpha:1.0],
                                  UITextAttributeTextShadowColor : [UIColor whiteColor],
                                  UITextAttributeTextShadowOffset : [NSValue valueWithCGSize:(CGSize){ .width = 0.0, .height = 1.0}] };

    [navBar setTitleTextAttributes:attributes];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (popoverController && popoverController.popoverVisible)
    {
        [popoverController dismissPopoverAnimated:YES];
        [self performSegueWithIdentifier:segueIdentifier sender:nil];
    }
}

- (IBAction)switchToUsingFiles:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - iOS 6 rotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


#pragma mark - iOS 5 rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
