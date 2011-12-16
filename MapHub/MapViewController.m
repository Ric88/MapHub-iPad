//
//  MapViewController.m
//  MapHub_iPad
//
//  Created by Ruokun Ren on 10/25/11.
//  Copyright (c) 2011 Cornell University. All rights reserved.
//

#import "MapViewController.h"
#import "MapView.h"
#import "TilesView.h"
#import "AnnotationView.h"
#import "MaphubClient.h"

@implementation MapViewController

@synthesize mapView, tilesView, annotationView, stepper, drawPolygon, mapPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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

- (void)loadView
{
    client = [MaphubClient alloc];
    [client setController:self];
    [client queryMaps];
    
    CGRect baseRect = CGRectMake(0, 20, 1024, 748);
    self.view = [[UIView alloc] initWithFrame:baseRect];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect screenRect = CGRectMake(0, 0, 1024, 748);
    mapList = [[UIScrollView alloc] initWithFrame:screenRect];
    
    UITapGestureRecognizer *selectGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectMap:)];
    [selectGuesture setNumberOfTapsRequired:2];
    
    [mapList addGestureRecognizer:selectGuesture];
    [self.view addSubview:mapList];
    
    int k = 0;
    for (NSString *key in [client maps]) {
        int row = k/3;
        int col = k%3;
        MapInfo *tmpMap = [[client maps] objectForKey:key];
        CGPoint thumbnailCenter = CGPointMake(192+col*320, 192+row*320);
        NSString *mapLocation = [NSString stringWithFormat:@"%@/TileGroup0/0-0-0.jpg", [tmpMap tilesetURL]];
        NSURL *url = [NSURL URLWithString:mapLocation];
        UIImage *mapImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
        Thumbnail *mapOverview = [[Thumbnail alloc] initWithImage:mapImage];
        [mapOverview setCenter:thumbnailCenter];
        [mapOverview setMapInfo:[[client maps] objectForKey:key]];
        [mapList addSubview:mapOverview];
        k++;
    }
        
    CGSize listSize = CGSizeMake(1024, 64+k/3*320);
    [mapList setContentSize:listSize];
    [self.view setNeedsDisplay];
}

- (IBAction)changeScaleValue:(id)sender
{
    [self changeScale:[(UIStepper *)sender value]];
}

- (IBAction)selectMap:(id)sender
{
    for (Thumbnail* mapOverview in [mapList subviews]) {
        CGPoint loc = [sender locationInView:mapOverview];
        if (loc.x < 0 || loc.y < 0 || loc.x >= mapOverview.frame.size.width || loc.y >= mapOverview.frame.size.height) {
            continue;
        }
        
        mapSize.width = [mapOverview mapInfo].width;
        mapSize.height = [mapOverview mapInfo].height;
        mapPath = [[mapOverview mapInfo] tilesetURL];
         
        CGRect screenRect = CGRectMake(0, 0, 1024, 748);
        mapView = [[MapView alloc] initWithFrame:screenRect];
        mapView.delegate = self;
        mapView.backgroundColor = [UIColor whiteColor];
        mapView.decelerationRate = UIScrollViewDecelerationRateFast;
        [self.view addSubview:mapView];
         
        CGRect mapRect = CGRectMake(0, 0, mapSize.width, mapSize.height);
        tilesView = [[TilesView alloc] initWithFrame:mapRect];
        [tilesView changeMap:mapPath width:mapSize.width height:mapSize.height];
        [mapView addSubview:tilesView];
         
        CGRect annotationRect = CGRectMake(0, 0, mapSize.width+1024, mapSize.height+748);
        annotationView = [[AnnotationView alloc] initWithFrame:annotationRect];
        [mapView addSubview:annotationView];
        [annotationView setParentView:self.view];
         
        CGSize contentSize = [tilesView getContentSize];
        mapView.contentSize = CGSizeMake(contentSize.width + 1024, contentSize.height + 748);
        [mapView setContentOffset:CGPointMake(contentSize.width/2, contentSize.height/2) animated:false];
        [self changeScale:tilesView.maxScale/2];
        
        [annotationView loadAnnotations:[mapOverview mapInfo].mapID];
         
        stepper = [[UIStepper alloc] initWithFrame:CGRectMake(20, 20, 80, 40)];
        [stepper addTarget:self action:@selector(changeScaleValue:) forControlEvents:UIControlEventValueChanged];
        stepper.maximumValue = tilesView.maxScale;
        stepper.minimumValue = 0;
        stepper.value = stepper.maximumValue/2;
        [self.view addSubview:stepper];
         
        drawPolygon = [[UIButton alloc] initWithFrame:CGRectMake(960, 20, 40, 40)];
        [drawPolygon setBackgroundImage:[UIImage imageNamed:@"draw_polygon_off"] forState:UIControlStateNormal];
        [drawPolygon addTarget:self action:@selector(changeAnnotation:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:drawPolygon];
        break;
    }
}

- (void)changeScale:(int)scale
{
    CGPoint preOffset = [mapView contentOffset];
    CGSize preSize = [tilesView getContentSize];
    preOffset.x /= preSize.width;
    preOffset.y /= preSize.height;
    [tilesView changeScale:scale];
    CGSize newSize = [tilesView getContentSize];
    CGPoint newOffset = CGPointMake(newSize.width * preOffset.x, newSize.height * preOffset.y);
    [mapView setContentSize:CGSizeMake(newSize.width + 1024, newSize.height + 748)];
    [mapView setContentOffset:newOffset animated:false];
    //[annotationView setFrame:CGRectMake(512, 374, newSize.width, newSize.height)];
    [annotationView setTransform:CGAffineTransformMakeScale(newSize.width/mapSize.width, newSize.height/mapSize.height)];
    [annotationView setCenter:[tilesView center]];
    [annotationView setScaling:newSize.width/mapSize.width];
    [annotationView setNeedsDisplay];
}

- (IBAction)changeAnnotation:(id)sender
{
    if (sender == drawPolygon) {
        if(annotationView.state == NotDrawing){
            annotationView.state = BezierStateNone;
            [drawPolygon setBackgroundImage:[UIImage imageNamed:@"draw_polygon_on"] forState:UIControlStateNormal];
        } else {
            annotationView.state = NotDrawing;
            [drawPolygon setBackgroundImage:[UIImage imageNamed:@"draw_polygon_off"] forState:UIControlStateNormal];
        }
    }
}

- (void)showMap:(NSString*)mapID
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
