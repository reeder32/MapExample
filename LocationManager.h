//
//  LocationManager.h
//  MapExample
//
//  Created by Nick Reeder on 1/19/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property CLLocationManager *locationManager;

@property CLLocation *currentLocation;

@property CLLocation *startingLocation;

@end
