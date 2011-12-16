//
//  MapHubView.m
//  MapHub
//
//  Created by Ruokun Ren on 10/10/11.
//  Copyright 2011 Cornell University. All rights reserved.
//

#import "MapHubView.h"

#import "MapHubLayer.h"

#define TILE_SIZE 256

@implementation MapHubView

@synthesize scale;

+ (Class)layerClass {
    return [MapHubLayer class];
}

- (UIImage *)tileAtRow:(int)row column:(int)column
{
    /*NSString *tileName = [NSString stringWithFormat:@"%d-%d-%d", scale, column, row];
    NSString *path = [[NSBundle mainBundle] pathForResource:tileName ofType:@"jpg"];
    
    UIImage *tile = [[UIImage alloc] initWithContentsOfFile:path];*/
    int groupBound[5][3] = {{5,8,11},{6,5,7},{6,11,23},{6,17,39},{6,21,39}};
    int group = 0;
    for (; group < 5; ++group) {
        if (scale < groupBound[group][0]) break;
        else if (scale == groupBound[group][0] && row < groupBound[group][1]) break;
        else if (scale == groupBound[group][0] && row == groupBound[group][1] && column <= groupBound[group][2]) break;
    }
    NSString *tileLocation = [NSString stringWithFormat:@"http://europeana.mminf.univie.ac.at/maps/g3200.ct000951/TileGroup%d/%d-%d-%d.jpg", group, scale, column, row];
    NSURL *url = [NSURL URLWithString:tileLocation];
    UIImage *tile = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]]; 
    return tile;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        scale = 3;
/*      test 1
        UIBezierPath* aPath = [UIBezierPath bezierPath];
        
        // Set the starting point of the shape.
        [aPath moveToPoint:CGPointMake(100.0, 0.0)];
        
        // Draw the lines
        [aPath addLineToPoint:CGPointMake(200.0, 40.0)];
        [aPath addLineToPoint:CGPointMake(160, 140)];
        [aPath addLineToPoint:CGPointMake(40.0, 140)];
        [aPath addLineToPoint:CGPointMake(0.0, 40.0)];
        [aPath closePath];*/
        
/*      test 2
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 1);
        
        // draw the gray pointed shape:
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 14.0, 0.0);
        CGPathAddLineToPoint(path, NULL, 0.0, 0.0); 
        CGPathAddLineToPoint(path, NULL, 55.0, 50.0); 
        CGContextAddPath(context, path);
        CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
        CGContextDrawPath(context, kCGPathFillStroke);
        CGPathRelease(path);*/
    }
    return self;
}

- (void)changeScale:(int)toScale width:(int)width height:(int)height
{
    scale = toScale;
    CGRect bigImageRect = CGRectMake(0, 0, width, height);
    self.frame = bigImageRect;
    //[self setNeedsDisplay];
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    
    // Set the starting point of the shape.
    [aPath moveToPoint:CGPointMake(100.0, 0.0)];
    
    // Draw the lines
    [aPath addLineToPoint:CGPointMake(200.0, 40.0)];
    [aPath addLineToPoint:CGPointMake(160, 140)];
    [aPath addLineToPoint:CGPointMake(40.0, 140)];
    [aPath addLineToPoint:CGPointMake(0.0, 40.0)];
    [aPath closePath];
    [self setNeedsDisplayInRect:bigImageRect];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    int column = (rect.origin.x / TILE_SIZE);
    int row = (rect.origin.y / TILE_SIZE);
    
    UIImage *tile = [self tileAtRow:row column:column];
    
    CGRect tileRect = CGRectMake(tile.size.width * column,
                                 tile.size.height * row,
                                 tile.size.width,
                                 tile.size.height);
    
    tileRect = CGRectIntersection(self.bounds, tileRect);
    
    [tile drawInRect:rect];
    
    //[tile release];
}
/*
- (void)mThreadDrawRect:(NSValue*)value{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    CGRect rect = value.CGRectValue;
    int column = (rect.origin.x / TILE_SIZE);
    int row = (rect.origin.y / TILE_SIZE);
    
    UIImage *tile = [self tileAtRow:row column:column];
    
    CGRect tileRect = CGRectMake(tile.size.width * column,
                                 tile.size.height * row,
                                 tile.size.width,
                                 tile.size.height);
    
    tileRect = CGRectIntersection(self.bounds, tileRect);
    
    [tile drawInRect:rect];
    [pool drain];
}*/

- (void)dealloc
{
    [super dealloc];
}


@end
