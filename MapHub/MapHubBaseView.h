//
//  MapHubBaseView.h
//  MapHub
//
//  Created by Ruokun Ren on 10/10/11.
//  Copyright 2011 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapHubView;

@interface MapHubBaseView : UIView {
    CGFloat totalScale;
    CGFloat lastScale;
}

@property (nonatomic, retain) MapHubView *mapView;
@property (nonatomic, retain) UIScrollView *scrollView;

@end
