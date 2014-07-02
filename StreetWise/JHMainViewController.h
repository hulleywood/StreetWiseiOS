//
//  JHMainViewController.h
//  StreetWise
//
//  Created by James Hulley on 6/29/14.
//  Copyright (c) 2014 James Hulley. All rights reserved.
//

#import "JHDirectionSearchResults.h"
#import <MapKit/MapKit.h>

@interface JHMainViewController : UIViewController <MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (assign) int currentPathIndex;
@property (nonatomic, strong) NSArray *localSearchResults;

@property (nonatomic, retain) MKPolyline *routeLine;
@property (nonatomic, retain) MKPolylineView *routeLineView;
@property (strong, nonatomic) JHDirectionSearchResults *serverSearchResults;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)getSearchResults:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *pathSlider;
- (IBAction)sliderWasMoved:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *originField;
@property (weak, nonatomic) IBOutlet UITextField *destinationField;

- (IBAction)displayAppInfo:(id)sender;
- (IBAction)locationSearchAutoComplete:(id)sender;
@property (weak, nonatomic) UITextField *currentlySearchingFor;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
