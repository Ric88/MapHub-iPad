//
//  TilesView.h
//  MapHub_iPad
//
//  Created by Ruokun Ren on 10/25/11.
//  Copyright (c) 2011 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TILE_SIZE 256
#define TILE_PER_GROUP 256
#define MAX_SCALE 20
#define MAX_LOOP 5

@interface TilesView : UIView{
    NSString *mapPath;
    int mapWidth;
    int mapHeight;
    int currentScale;
    int maxScale;
    int tileNum[MAX_SCALE];
    CGSize viewSize[MAX_SCALE];
    CGSize tileSize[MAX_SCALE];
}

@property int currentScale, maxScale, mapWidth, mapHeight;
@property (atomic, retain) NSString *mapPath;

- (void)changeMap:(NSString*)newMapPath width:(int)width height:(int)height;

- (void)setupScaleWidth:(int)maxWidth height:(int)maxHeight;

- (void)changeScale:(int)scale;

- (UIImage *)tileAtRow:(int)row column:(int)column;

- (CGSize)getContentSize;

- (CGPoint)getContentOffset;

@end
