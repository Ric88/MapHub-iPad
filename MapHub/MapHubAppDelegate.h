//
//  MapHubAppDelegate.h
//  MapHub
//
//  Created by Ruokun Ren on 10/10/11.
//  Copyright 2011 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapViewController;

@interface MapHubAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MapViewController *viewController;

@end
