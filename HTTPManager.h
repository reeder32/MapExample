//
//  HTTPManager.h
//  MapExample
//
//  Created by Nick Reeder on 1/22/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface HTTPManager : NSObject


+(id)sharedManager;

-(void)requestPlacesForLocation:(CLLocationCoordinate2D)userLocation radius:(float) radius andSearchTerm:(NSString *)searchTerm;


@end
