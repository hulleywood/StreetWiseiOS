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
    _pathSlider.continuous = YES;
    [_pathSlider addTarget:self
               action:@selector(sliderWasMoved:)
     forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    MKCoordinateRegion defaultRegion;
    CLLocationCoordinate2D zoomLocation;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    zoomLocation.latitude = 37.7833;
    zoomLocation.longitude = -122.4167;
    defaultRegion.center = zoomLocation;
    defaultRegion.span = span;
    
    [_mapView setRegion:defaultRegion animated:YES];
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [aMapView setRegion:region animated:YES];
}

- (IBAction)getSearchResults:(id)sender {
    NSString *url = @"http://streetwise.herokuapp.com/directions/:id";
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

- (IBAction)sliderWasMoved:(id)sender {
    [_pathSlider setValue:((int)((_pathSlider.value + .25))) animated:NO];
    int pathIndex = (int) _pathSlider.value;
    
    if (pathIndex != self.currentPathIndex && self.searchResults.paths.count == 4) {
        self.currentPathIndex = pathIndex;
        [self renderPathOnMap];
    }
}

- (void)processSearchResultsFromResponse:(NSDictionary *)responseJSON
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.searchResults = [JHDirectionSearchResults searchResultsWithResponse:responseJSON];
    [self renderSearchResults];
}

#pragma mark - Render Methods

- (void)renderSearchResults
{
    self.currentPathIndex = 0;
    [_pathSlider setValue:self.currentPathIndex animated:NO];
    
    [self clearMapAnnotations];
    [self renderEndPoints];
    [self renderPathOnMap];
    [self resizeMapViewForResults];
}

- (void)clearMapOverlays
{
    [self.mapView removeOverlays:self.mapView.overlays];
}

- (void)clearMapAnnotations
{
    [self.mapView removeAnnotations:[self.mapView annotations]];
}

- (void)renderEndPoints
{
    [_mapView addAnnotation:self.searchResults.origin];
    [_mapView addAnnotation:self.searchResults.destination];
}

- (void)renderPathOnMap
{
    [self clearMapOverlays];
    MKPolyline *path = self.searchResults.paths[_currentPathIndex];
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
    renderer.lineWidth = 5.0;
    return renderer;
}

- (IBAction)displayAppInfo:(id)sender
{
    NSString *infoText = @"StreetWise provides walking directions that take your environment into account using SFGOV Crime Data. To use: enter an origin and destination, click the search button, and when results are returned use the slider at the bottom to choose between safer routes or shorter ones.";
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"About"
                                                       message:infoText
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
}
@end
