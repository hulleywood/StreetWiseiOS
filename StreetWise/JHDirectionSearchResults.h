//
//  JHDirectionSearchResults.h
//  StreetWise
//
//  Created by James Hulley on 6/29/14.
//  Copyright (c) 2014 James Hulley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface JHDirectionSearchResults : NSObject

@property NSString *origin;
@property NSString *destination;
@property CLLocation *originCoords;
@property CLLocation *destinationCoords;
@property NSMutableArray *paths;

+ (id)searchResultsWithResponse:(NSDictionary *)responseText;
- (id)initWithResponse:(NSDictionary *)responseText;

@end
