//
//  MapHubView.h
//  MapHub
//
//  Created by Ruokun Ren on 10/10/11.
//  Copyright 2011 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapHubView : UIView {
    
}

@property int scale;

- (UIImage *)tileAtRow:(int)row column:(int)column;
- (void) changeScale:(int)scale width:(int)width height:(int)height;

@end
