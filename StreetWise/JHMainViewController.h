//
//  JHMainViewController.h
//  StreetWise
//
//  Created by James Hulley on 6/29/14.
//  Copyright (c) 2014 James Hulley. All rights reserved.
//

#import "JHFlipsideViewController.h"
#import "JHDirectionSearchResults.h"
#import <MapKit/MapKit.h>

@interface JHMainViewController : UIViewController <JHFlipsideViewControllerDelegate, UIPopoverControllerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@property (nonatomic, retain) MKPolyline *routeLine;
@property (nonatomic, retain) MKPolylineView *routeLineView;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)getSearchResults:(id)sender;

@property (strong, nonatomic) JHDirectionSearchResults *searchResults;

@property (weak, nonatomic) IBOutlet UITextField *originField;
@property (weak, nonatomic) IBOutlet UITextField *destinationField;

@end
