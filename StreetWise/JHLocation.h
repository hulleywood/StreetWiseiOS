//
//  JHLocation.h
//  StreetWise
//
//  Created by James Hulley on 6/30/14.
//  Copyright (c) 2014 James Hulley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface JHLocation : NSObject <MKAnnotation>

- (id)initWithName:(NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate;

- (MKMapItem*)mapItem;

@end
