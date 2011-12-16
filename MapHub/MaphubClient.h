//
//  MaphubClient.h
//  MapHub
//
//  Created by Ruokun Ren on 12/4/11.
//  Copyright (c) 2011 Cornell University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapInfo.h"

enum{
    NONE = 0,
    PARSINGID,
    PARSINGTITLE,
    PARSINGTILESET,
    PARSINGWIDTH,
    PARSINGHEIGHT
};

@interface MaphubClient: NSObject <NSXMLParserDelegate>
{
    NSMutableDictionary *maps;
    MapInfo *currentMap;
    NSData *receivedData;
    int state;
    Boolean gotMaps;
    UIViewController *controller;
}

@property (retain, nonatomic)NSMutableDictionary *maps;
@property Boolean gotMaps;
@property (retain, nonatomic)UIViewController *controller;

- (void)queryMaps;

@end
