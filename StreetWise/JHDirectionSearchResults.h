//
//  JHDirectionSearchResults.h
//  StreetWise
//
//  Created by James Hulley on 6/29/14.
//  Copyright (c) 2014 James Hulley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHDirectionSearchResults : NSObject

@property NSString *origin;
@property NSString *destination;
@property NSArray *originCoords;
@property NSArray *destinationCoords;
@property NSArray *paths;

+ (id)searchResultsWithResponse:(NSDictionary *)responseText;
- (id)initWithResponse:(NSDictionary *)responseText;

@end
