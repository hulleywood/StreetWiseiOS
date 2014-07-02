//
//  JHMainViewController.m
//  StreetWise
//
//  Created by James Hulley on 6/29/14.
//  Copyright (c) 2014 James Hulley. All rights reserved.
//

#import "JHMainViewController.h"
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "MBProgressHUD.h"

#define METERS_PER_MILE 1609.344

@interface JHMainViewController ()

@end

@implementation JHMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    
    self.mapView.delegate = self;
    _pathSlider.continuous = YES;
    [_pathSlider addTarget:self
               action:@selector(sliderWasMoved:)
     forControlEvents:UIControlEventValueChanged];
    
    [_originField addTarget:self action:@selector(locationSearchAutoComplete:) forControlEvents:UIControlEventEditingChanged];
    [_destinationField addTarget:self action:@selector(locationSearchAutoComplete:) forControlEvents:UIControlEventEditingChanged];
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
    
    if (pathIndex != self.currentPathIndex && self.serverSearchResults.paths.count == 4) {
        self.currentPathIndex = pathIndex;
        [self renderPathOnMap];
    }
}

- (void)processSearchResultsFromResponse:(NSDictionary *)responseJSON
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.serverSearchResults = [JHDirectionSearchResults searchResultsWithResponse:responseJSON];
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
    [_mapView addAnnotation:self.serverSearchResults.origin];
    [_mapView addAnnotation:self.serverSearchResults.destination];
}

- (void)renderPathOnMap
{
    [self clearMapOverlays];
    MKPolyline *path = self.serverSearchResults.paths[_currentPathIndex];
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
    MKCoordinateRegion defaultRegion;
    CLLocationCoordinate2D mapCenter;
    MKCoordinateSpan span;
    span.latitudeDelta = fabs(self.serverSearchResults.origin.coordinate.latitude - self.serverSearchResults.destination.coordinate.latitude) * 1.25;
    span.longitudeDelta = fabs(self.serverSearchResults.origin.coordinate.longitude - self.serverSearchResults.destination.coordinate.longitude) * 1.25;
    mapCenter.latitude = (self.serverSearchResults.origin.coordinate.latitude + self.serverSearchResults.destination.coordinate.latitude)/2.00;
    mapCenter.longitude = (self.serverSearchResults.origin.coordinate.longitude + self.serverSearchResults.destination.coordinate.longitude)/2.00;;
    defaultRegion.center = mapCenter;
    defaultRegion.span = span;
    
    [_mapView setRegion:defaultRegion animated:YES];
    
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

#pragma mark - AutoComplete

- (IBAction)locationSearchAutoComplete:(id)sender
{
    self.currentlySearchingFor = (UITextField *)sender;
    [self localSearch:self.currentlySearchingFor.text];
}

- (void)localSearch:(NSString *)searchTerms
{
    if ([searchTerms length] > 0) {
        self.tableView.hidden = NO;
    } else {
        self.tableView.hidden = YES;
    }
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchTerms;
    request.region = _mapView.region;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        self.localSearchResults = response.mapItems;
        [_tableView reloadData];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.tableView.hidden = YES;
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = selectedCell.textLabel.text;
    self.currentlySearchingFor.text = cellText;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.localSearchResults count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    // Init cell with desired style
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Get appropriate data and put into cell
    MKMapItem *item = [_localSearchResults objectAtIndex:indexPath.row];
    NSString *address = [item.placemark.addressDictionary objectForKey:@"Street"];
    
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = address;
    
    // Return cell
    return cell;
}

@end
