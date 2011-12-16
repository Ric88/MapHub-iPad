//
//  MapHubViewController.m
//  MapHub
//
//  Created by Ruokun Ren on 10/10/11.
//  Copyright 2011 Cornell University. All rights reserved.
//

#import "MapHubViewController.h"

#import "MapHubView.h"
#import "MapHubBaseView.h"

@implementation MapHubViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect baseRect = CGRectMake(0, 20, 1024, 748);
    MapHubBaseView *baseView = [[MapHubBaseView alloc] initWithFrame:baseRect];
    baseView.backgroundColor = [UIColor blackColor];
    self.view = baseView;
    
    int imageWidth = 1280;
    int imageHeight = 692;
    CGRect scrollRect = CGRectMake(0, 0, 1024, 748);
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollRect];
    scrollView.contentSize = CGSizeMake(imageWidth, imageHeight);
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    CGRect bigImageRect = CGRectMake(0, 0, imageWidth, imageHeight);
    
    MapHubView *tilesView = [[MapHubView alloc] initWithFrame:bigImageRect];
    [scrollView addSubview:tilesView];
    baseView.mapView = tilesView;
    [tilesView release];
    
    [self.view addSubview:scrollView];
    baseView.scrollView = scrollView;
    [scrollView release];
    [baseView release];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
