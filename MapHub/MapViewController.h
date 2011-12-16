//
//  MapViewController.h
//  MapHub_iPad
//
//  Created by Ruokun Ren on 10/25/11.
//  Copyright (c) 2011 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TilesView.h"
#import "MapView.h"
#import "AnnotationView.h"
#import "MaphubClient.h"
#import "Thumbnail.h"

@interface MapViewController : UIViewController <UIScrollViewDelegate>{
    MapView *mapView;
    TilesView *tilesView;
    AnnotationView *annotationView;
    UIStepper *stepper;
    UIButton *drawPolygon;
    CGSize mapSize;
    NSString *mapPath;
    MaphubClient *client;
    UIScrollView *mapList;
}

@property (nonatomic, retain) MapView *mapView;
@property (nonatomic, retain) TilesView *tilesView;
@property (nonatomic, retain) AnnotationView *annotationView;
@property (nonatomic, retain) UIStepper *stepper;
@property (nonatomic, retain) UIButton *drawPolygon;
@property (nonatomic, retain) NSString *mapPath;

- (void)changeScale:(int)scale;

@end
