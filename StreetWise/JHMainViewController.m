//
//  JHMainViewController.m
//  StreetWise
//
//  Created by James Hulley on 6/29/14.
//  Copyright (c) 2014 James Hulley. All rights reserved.
//

#import "JHMainViewController.h"
#import "AFHTTPRequestOperationManager.h"

#define METERS_PER_MILE 1609.344

@interface JHMainViewController ()

@end

@implementation JHMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
//    [_mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    CLLocationCoordinate2D zoomLocation;
//    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.02);
//    MKCoordinateRegion viewRegion = MKCoordinateRegionMake(_mapView.userLocation.coordinate, span);
    
    if (_mapView.userLocation.location != nil) {
        NSLog(@"User location!");
        zoomLocation = _mapView.userLocation.location.coordinate;
    } else {
        zoomLocation.latitude = 37.7833;
        zoomLocation.longitude = -122.4167;
    }
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    [_mapView setRegion:viewRegion animated:YES];
}

- (IBAction)getSearchResults:(id)sender {
    //    MKCoordinateRegion mapRegion = [_mapView region];
    //    CLLocationCoordinate2D centerLocation = mapRegion.center;
    
    NSString *url = @"http://streetwise.herokuapp.com/directions/:id";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *parameters = @{ @"origin": @"1502 hyde st, san francisco",
                                  @"destination": @"633 folsom st, san francisco" };
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *e = nil;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:0
                              error:&e ];
//        NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"Response: %@", json);
        [self initiateSearchResultsFromResponse:json];
        [self renderSearchResults];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self renderError:error];
    }];
}

- (void)initiateSearchResultsFromResponse:(NSDictionary *)responseJSON
{
    self.searchResults = [JHDirectionSearchResults searchResultsWithResponse:responseJSON];
    NSLog(@"Origin: %@", self.searchResults.origin.subtitle);
    NSLog(@"Destination: %@", self.searchResults.destination.subtitle);
}

#pragma mark - Render Methods

- (void)renderSearchResults
{
    [self renderEndPoints];
    [self renderPathsOnMap];
}

- (void)renderEndPoints
{
    [_mapView addAnnotation:self.searchResults.origin];
    [_mapView addAnnotation:self.searchResults.destination];
}

- (void)renderPathsOnMap
{
    [_mapView addOverlays:self.searchResults.paths level:MKOverlayLevelAboveRoads];
}

- (void)renderError:(NSError *)error
{
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    UIColor *mapOverlayColor = [UIColor colorWithRed:((float)22 / 255.0f) green:((float)126 / 255.0f) blue:((float)251 / 255.0f) alpha:0.8];
    renderer.strokeColor = mapOverlayColor;
    renderer.lineWidth = 13.0;
    return renderer;
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(JHFlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}


@end
