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
        NSString *originAddress = [responseJSON objectForKey:@"origin"];
        NSArray *originArray = [self createCoordsArrayFromDict:[responseJSON objectForKey:@"origin_coords"]];
        CLLocationCoordinate2D originLocation = [self createLocationFromPoints:originArray].coordinate;
        self.origin = [[JHLocation alloc] initWithName:@"Origin" address:originAddress coordinate:originLocation];
        
        NSString *destinationAddress = [responseJSON objectForKey:@"destination"];
        NSArray *destinationArray = [self createCoordsArrayFromDict:[responseJSON objectForKey:@"destination_coords"]];
        CLLocationCoordinate2D destinationLocation = [self createLocationFromPoints:destinationArray].coordinate;
        self.destination = [[JHLocation alloc] initWithName:@"Destination" address:destinationAddress coordinate:destinationLocation];
        
        [self createPolyLines:[responseJSON objectForKey:@"paths"]];
    }
    
    return self;
}

- (void)createPolyLines:(NSArray *)responsePaths {
    int numberOfPaths = 4;
    self.paths = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numberOfPaths; i++) {
        MKPolyline *path = [self createPolyLineFromPoints:responsePaths[i]];
        [self.paths addObject:path];
    }
}

- (MKPolyline *)createPolyLineFromPoints:(NSArray *)pathPoints {
    NSInteger numberOfPoints = pathPoints.count;
    CLLocationCoordinate2D coords[numberOfPoints];
    
    for (int i = 0; i < numberOfPoints; i++) {
        CLLocation *location = [self createLocationFromPoints:pathPoints[i]];
        
        CLLocationCoordinate2D coordinate = location.coordinate;
        coords[i] = coordinate;
    }
    
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coords count:numberOfPoints];
    return polyLine;
}

- (CLLocation *)createLocationFromPoints:(NSArray *)inputPoints {
    NSNumber *lon = [inputPoints objectAtIndex:1];
    NSNumber *lat = [inputPoints objectAtIndex:0];
    
    double latitude = [lat doubleValue];
    double longitude = [lon doubleValue];
    
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

- (NSArray *)createCoordsArrayFromDict:(NSDictionary *)inputCoords {
    return @[[inputCoords objectForKey:@"lat"], [inputCoords objectForKey:@"lon"]];
}

@end
