//
//  MapHubBaseView.m
//  MapHub
//
//  Created by Ruokun Ren on 10/10/11.
//  Copyright 2011 Cornell University. All rights reserved.
//

#import "MapHubBaseView.h"
#import "MapHubView.h"

@implementation MapHubBaseView

@synthesize mapView = _mapView;
@synthesize scrollView = _scrollView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [self addGestureRecognizer:pinchGesture];
        [pinchGesture release];

    }
    return self;
}

- (void)handlePinch:(UIPinchGestureRecognizer*)sender
{
    int width[7] = {160, 320, 640, 1280, 2559, 5117, 10234};
    int height[7] = {87, 173, 346, 692, 1384, 2767, 5533};
    int mapScale = self.mapView.scale;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        totalScale = 1.0;
        lastScale = 1.0;
        return;
    }
    totalScale += - lastScale + sender.scale;
    lastScale = sender.scale;
    if (totalScale < 1.0) {
        if (mapScale == 0)
            return;
        if (totalScale < (width[mapScale-1]+0.0)/width[mapScale]){
            mapScale--;
            totalScale = 1.0;
        }
    } else {
        if (mapScale == 6)
            return;
        if (totalScale > (width[mapScale+1]+0.0)/width[mapScale]){
            mapScale++;
            totalScale = 1.0;
        }
    }
    
    if (mapScale == self.mapView.scale) {
        return;
    }
    self.scrollView.contentSize = CGSizeMake(width[mapScale], height[mapScale]);
    [self.mapView changeScale:mapScale width:width[mapScale] height:height[mapScale]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
