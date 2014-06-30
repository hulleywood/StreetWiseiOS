//
//  JHMainViewController.h
//  StreetWise
//
//  Created by James Hulley on 6/29/14.
//  Copyright (c) 2014 James Hulley. All rights reserved.
//

#import "JHFlipsideViewController.h"
#import <MapKit/MapKit.h>

@interface JHMainViewController : UIViewController <JHFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)searchPaths:(id)sender;

@end
