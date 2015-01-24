//
//  ViewController.m
//  MapExample
//
//  Created by Nick Reeder on 1/19/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "ViewController.h"

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
                
                NSDictionary *geometry = [places objectForKey:@"geometry"];
                
                NSDictionary *location = [geometry objectForKey:@"location"];
                
                NSNumber *lat = [location objectForKey:@"lat"];
                
                NSNumber *lng = [location objectForKey:@"lng"];
                
                CLLocationCoordinate2D latlng = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
                
                MapViewAnnotation *annotation = [[MapViewAnnotation alloc]initWithTitle:name andCoordinate:latlng];
                
                [placesFound addObject:annotation];
                
            }
            
            
            
            [self performSelectorOnMainThread:@selector(displayNewAnnotations:) withObject:placesFound waitUntilDone:NO];
        }
        
        
        
    }] resume];
    
    
    
    
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
