//
//  JHMainViewController.m
//  StreetWise
//
//  Created by James Hulley on 6/29/14.
//  Copyright (c) 2014 James Hulley. All rights reserved.
//

#import "JHMainViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "MBProgressHUD.h"

#define METERS_PER_MILE 1609.344

@interface JHMainViewController ()

@end

@implementation JHMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
//    self.originField.delegate = self;
//    self.destinationField.delegate = self;
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
    NSString *url = @"http://streetwise.herokuapp.com/directions/:id";
    //    MKCoordinateRegion mapRegion = [_mapView region];
    //    CLLocationCoordinate2D centerLocation = mapRegion.center;
    
    NSString *origin = self.originField.text;
    NSString *destination = self.destinationField.text;
   
    if ([origin length] != 0 && [destination length] != 0) {
        [self.originField resignFirstResponder];
        [self.destinationField resignFirstResponder];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading paths...";
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
        NSDictionary *parameters = @{ @"origin": origin,
                                  @"destination": destination };
        [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *e = nil;
            NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:0
                              error:&e ];
            [self processSearchResultsFromResponse:json];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self renderError:error];
        }];
    } else {
        NSString *e = @"At least one of your endpoints is blank";
        [self renderErrorText:e];
    }
}

- (void)processSearchResultsFromResponse:(NSDictionary *)responseJSON
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.searchResults = [JHDirectionSearchResults searchResultsWithResponse:responseJSON];
    [self renderSearchResults];
    NSLog(@"Origin: %@", self.searchResults.origin.subtitle);
    NSLog(@"Destination: %@", self.searchResults.destination.subtitle);
}

#pragma mark - Render Methods

- (void)renderSearchResults
{
    [self clearMapOverlays];
    [self renderEndPoints];
    [self renderPathOnMap:self.searchResults.paths[0]];
    [self resizeMapViewForResults];
    [self displayPathSlider];
}

- (void)clearMapOverlays
{
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self.mapView removeOverlays:self.mapView.overlays];
}

- (void)renderEndPoints
{
    [_mapView addAnnotation:self.searchResults.origin];
    [_mapView addAnnotation:self.searchResults.destination];
}

- (void)renderPathOnMap:(MKPolyline *)path
{
    [_mapView addOverlay:path level:MKOverlayLevelAboveRoads];
}

- (void)renderError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSString *userInfo = [error.userInfo objectForKey:@"NSLocalizedDescription"];
    NSString *errorText;
    
    if ([userInfo rangeOfString:@"422"].location != NSNotFound) {
        errorText = @"Make sure both of your endpoints are within San Francisco and try again";
    } else if ([userInfo rangeOfString:@"500"].location != NSNotFound) {
        errorText = @"We're performing maintenance on our servers, please try again soon";
    } else {
        errorText = @"An unknown error occured, please try again";
    }
    
    [self renderErrorText:errorText];
    
}

- (void)resizeMapViewForResults
{
    
}

- (void)renderErrorText:(NSString *)error
{
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                       message:error
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
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

- (void)displayPathSlider
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
