//
//  MapInfo.h
//  MapHub
//
//  Created by Ruokun Ren on 12/4/11.
//  Copyright (c) 2011 Cornell University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapInfo : NSObject
{
    NSString *mapID;
    NSString *title;
    NSString *tilesetURL;
    int width;
    int height;
}

@property (retain) NSString *mapID;
@property (retain) NSString *title;
@property (retain) NSString *tilesetURL;
@property int width;
@property int height;

@end
