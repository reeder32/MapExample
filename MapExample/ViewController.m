//
//  ViewController.m
//  MapExample
//
//  Created by Nick Reeder on 1/19/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "ViewController.h"
#import "PlaceDetailViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLocationRange:) name:@"updatedLocation" object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOnScreen)];
    
    tap.numberOfTapsRequired = 1;
    
    [self.view addGestureRecognizer:tap];
    
    
    
    
}

-(void) showExampleAnnotation{
    
//    CLLocationCoordinate2D portland = CLLocationCoordinate2DMake(45.5241, -122.676201);
//    
//    MapViewAnnotation *annotation = [[MapViewAnnotation alloc]initWithTitle:@"Test" andCoordinate:portland];
//    
//    [self.mapView addAnnotation:annotation];
}

-(void)getPlacesFromGoogle{
    
    NSString *urlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=300&sensor=false&keyword=%@&key=AIzaSyDfFhd0Uh5fvOw1daGh9zbVPbAVirn2qDU",self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude,self.searchBar.text];
    
    NSURL  *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        
        NSMutableDictionary *allData = [NSJSONSerialization
                                        JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        
        NSArray *results = [allData objectForKey:@"results"];
        
        NSMutableArray *placesFound = [NSMutableArray array];
        
        if (results.count >= 1){
            
            for (id object in results) {
                
                NSDictionary *places = object;
                
                NSString *name = [places objectForKey:@"name"];
                
                NSString *googlePlacesID = [places objectForKey:@"place_id"];
                
                NSDictionary *geometry = [places objectForKey:@"geometry"];
                
                NSDictionary *location = [geometry objectForKey:@"location"];
                
                NSNumber *lat = [location objectForKey:@"lat"];
                
                NSNumber *lng = [location objectForKey:@"lng"];
                
                CLLocationCoordinate2D latlng = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
                
                MapViewAnnotation *annotation = [[MapViewAnnotation alloc]initWithTitle:name andCoordinate:latlng andGooglePlacesID:googlePlacesID];
                
               
                
                [placesFound addObject:annotation];
                
            }
            
            
            
            [self performSelectorOnMainThread:@selector(displayNewAnnotations:) withObject:placesFound waitUntilDone:NO];
        }
        
        
        
    }] resume];
    
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"MyLocation";
   
    
    if ([annotation isKindOfClass:[MapViewAnnotation class]]) {
        
        MKAnnotationView *aView = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        
        
        if (aView == nil) {
            aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            
            
            aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
            aView.canShowCallout = YES;
            aView.annotation = annotation;
        } else {
            aView.annotation = annotation;
        }
        
        return aView;
        
    } else {
        return nil;
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    MapViewAnnotation *annotation = view.annotation;
    
   
    
    [self getPlaceDetailWithID:annotation.googlePlacesID];
    
}

-(void)getPlaceDetailWithID:(NSString *)placeID {
    
    NSString *urlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=AIzaSyDfFhd0Uh5fvOw1daGh9zbVPbAVirn2qDU", placeID];
    NSURL  *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        
        NSMutableDictionary *allData = [NSJSONSerialization
                                        JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                        error:&jsonError];
        
        NSDictionary *result = [allData objectForKey:@"result"];
        
        [self performSelectorOnMainThread:@selector(showPlaceDetail:) withObject:result waitUntilDone:NO];
        
        
        
    }] resume];
    
}

-(void)showPlaceDetail:(NSDictionary *)result {
    
    [self performSegueWithIdentifier:@"showPlaceDetail" sender:result];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showPlaceDetail"]) {
        NSDictionary *result = (NSDictionary *)sender;
        
        NSString *websiteLink = [result objectForKey:@"website"];
        
        NSString *name = [result objectForKey:@"name"];
        
        PlaceDetailViewController *pdc = segue.destinationViewController;
        
        pdc.urlString = websiteLink;
        
        pdc.title = name;
    }
}

-(void)displayNewAnnotations:(NSMutableArray *)places {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView addAnnotations:places];
    
}


-(void)didTapOnScreen{
    
    [self.searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
    
    [self getPlacesFromGoogle];
}

-(void)updateRegion:(CLLocationCoordinate2D) location{
    
    self.mapView.showsUserLocation = YES;
    
    CLLocationCoordinate2D initialLocationFocus = location;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(.01, .01);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(initialLocationFocus, span);
    
    [self.mapView setRegion:region animated:YES];
    
   
    
}

-(void)updateLocationRange:(NSNotification *)notif {
    
    CLLocation *newLocation = notif.object;
    
    [self updateRegion:newLocation.coordinate];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
