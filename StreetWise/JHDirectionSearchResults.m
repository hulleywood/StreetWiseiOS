//
//  JHDirectionSearchResults.m
//  StreetWise
//
//  Created by James Hulley on 6/29/14.
//  Copyright (c) 2014 James Hulley. All rights reserved.
//

#import "JHDirectionSearchResults.h"

@implementation JHDirectionSearchResults

+ (id)searchResultsWithResponse:(NSDictionary *)responseJSON {
    return [[self alloc] initWithResponse:responseJSON];
}

- (id)initWithResponse:(NSDictionary *)responseJSON {
    self = [super init];
    if (self) {
        self.origin = [responseJSON objectForKey:@"origin"];
        self.destination = [responseJSON objectForKey:@"destination"];
        self.originCoords = [responseJSON objectForKey:@"origin_coords"];
        self.destinationCoords = [responseJSON objectForKey:@"destination_coords"];
        self.paths = [responseJSON objectForKey:@"path"];
    }
    
    return self;
}

@end
