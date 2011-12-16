//
//  MaphubClient.m
//  MapHub
//
//  Created by Ruokun Ren on 12/4/11.
//  Copyright (c) 2011 Cornell University. All rights reserved.
//

#import "MaphubClient.h"

@implementation MaphubClient

@synthesize maps, gotMaps, controller;

- (void)queryMaps
{   
    gotMaps = false;
    maps = [[NSMutableDictionary alloc] initWithCapacity:10];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://128.253.195.81:8080/de.vogella.jersey.first/rest/MapHub/Maps"]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:receivedData];
    [parser setDelegate:self];
    [parser parse];
    [receivedData release];
    //NSURLConnection *maphubConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //if (maphubConnection) {
    //    receivedData = [[NSMutableData data] retain];
    //}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if ([elementName isEqualToString:@"map"]) {
        currentMap = [MapInfo alloc];
    } else if ([elementName isEqualToString:@"id"]) {
        state = PARSINGID;
    } else if ([elementName isEqualToString:@"title"]) {
        state = PARSINGTITLE;
    } else if ([elementName isEqualToString:@"tileset-url"]) {
        state = PARSINGTILESET;
    } else if ([elementName isEqualToString:@"width"]) {
        state = PARSINGWIDTH;
    } else if ([elementName isEqualToString:@"height"]) {
        state = PARSINGHEIGHT;
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    switch (state) {
        case PARSINGID:
            [currentMap setMapID:[NSString stringWithString:string]];
            [maps setObject:currentMap forKey:string];
            break;
        case PARSINGTITLE:
            [currentMap setTitle:[NSString stringWithString:string]];
            break;
        case PARSINGTILESET:
            [currentMap setTilesetURL:[NSString stringWithString:string]];
            break;
        case PARSINGWIDTH:
            [currentMap setWidth:[string intValue]];
            break;
        case PARSINGHEIGHT:
            [currentMap setHeight:[string intValue]];
            break;
        default:
            break;
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    state = NONE;
    if ([elementName isEqualToString:@"maps"]) {
        gotMaps = true;
        [NSThread detachNewThreadSelector:@selector(showMap:) toTarget:controller withObject:elementName];
    }
}

@end
