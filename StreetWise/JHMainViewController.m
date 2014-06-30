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
        [self renderPathsOnMap];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self renderError:error];
    }];
}

- (void)initiateSearchResultsFromResponse:(NSDictionary *)responseJSON
{
    self.searchResults = [JHDirectionSearchResults searchResultsWithResponse:responseJSON];
    NSLog(@"Origin: %@", self.searchResults.origin);
    NSLog(@"Destination: %@", self.searchResults.destination);
    NSLog(@"Origin coords: %@", self.searchResults.originCoords);
    NSLog(@"Destination coords: %@", self.searchResults.destinationCoords);
    NSLog(@"Path 0: %@", self.searchResults.paths[0]);
    NSLog(@"Path 1: %@", self.searchResults.paths[1]);
    NSLog(@"Path 2: %@", self.searchResults.paths[2]);
    NSLog(@"Path 3: %@", self.searchResults.paths[3]);
}

#pragma mark - Render Methods

- (void)renderPathsOnMap
{
    
}

- (void)renderError:(NSError *)error
{
    
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
