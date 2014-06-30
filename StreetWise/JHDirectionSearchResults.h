//
//  JHDirectionSearchResults.h
//  StreetWise
//
//  Created by James Hulley on 6/29/14.
//  Copyright (c) 2014 James Hulley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "JHLocation.h"

@interface JHDirectionSearchResults : NSObject

@property JHLocation *origin;
@property JHLocation *destination;
//@property CLLocation *originCoords;
//@property CLLocation *destinationCoords;
@property NSMutableArray *paths;

+ (id)searchResultsWithResponse:(NSDictionary *)responseJSON;
- (id)initWithResponse:(NSDictionary *)responseJSON;

@end
