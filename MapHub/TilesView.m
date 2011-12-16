//
//  TilesView.m
//  MapHub_iPad
//
//  Created by Ruokun Ren on 10/25/11.
//  Copyright (c) 2011 Cornell University. All rights reserved.
//

#import "TilesView.h"
#import "TiledLayer.h"

@implementation TilesView

@synthesize currentScale, maxScale, mapWidth, mapHeight, mapPath;

+ (Class)layerClass{
    return [TiledLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)changeMap:(NSString *)newMapPath width:(int)width height:(int)height
{
    mapPath = [[NSString alloc] initWithString:newMapPath];
    mapWidth = width;
    mapHeight = height;
    currentScale = 0;
    [self setupScaleWidth: width height:height];
}

- (void)setupScaleWidth:(int)width height:(int)height
{
    int largerEdge = MAX(width, height);
    maxScale = 0;
    for (; largerEdge > TILE_SIZE; largerEdge = (largerEdge+1)/2) {
        ++maxScale;
    }
    for (int s = maxScale; s >= 0; --s) {
        viewSize[s].width = width;
        viewSize[s].height = height;
        tileSize[s].width = (width+TILE_SIZE-1) / TILE_SIZE;
        tileSize[s].height = (height+TILE_SIZE-1) / TILE_SIZE;
        tileNum[s] = tileSize[s].width * tileSize[s].height;
        width = (width+1) / 2;
        height = (height+1) / 2;
    }
}

- (void)changeScale:(int)scale
{
    currentScale = scale;
    CGRect newFrame = CGRectMake(512, 374, viewSize[scale].width, viewSize[scale].height);
    self.frame = newFrame;
    [self setNeedsDisplayInRect:CGRectMake(0, 0, viewSize[scale].width, viewSize[scale].height)];
}

- (UIImage*)tileAtRow:(int)row column:(int)column
{
    int group, tileNumTotal = 0;
    for (int s = 0; s < currentScale; ++s) {
        tileNumTotal += tileNum[s];
    }
    tileNumTotal += row * tileSize[currentScale].width + column;
    group = tileNumTotal / TILE_PER_GROUP;
    NSString *tileLocation = [NSString stringWithFormat:@"%@/TileGroup%d/%d-%d-%d.jpg", mapPath, group, currentScale, column, row];
    NSURL *url = [NSURL URLWithString:tileLocation];
    UIImage *tile = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]]; 
    for (int loop = 0; loop < MAX_LOOP && !tile; ++loop) {
    //while (!tile) {
        tile = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
    }
    return tile;
}

- (CGSize)getContentSize
{
    return viewSize[currentScale];
}

- (CGPoint)getContentOffset
{
    return self.center;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    int column = (rect.origin.x / TILE_SIZE);
    int row = (rect.origin.y / TILE_SIZE);
    
    UIImage *tile = [self tileAtRow:row column:column];
    
    CGRect tileRect = CGRectMake(tile.size.width * column,
                                 tile.size.height * row,
                                 tile.size.width,
                                 tile.size.height);
    
    tileRect = CGRectIntersection(self.bounds, tileRect);
    
    [tile drawInRect:rect];
}


@end
