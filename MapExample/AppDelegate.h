//
//  AppDelegate.h
//  MapExample
//
//  Created by Nick Reeder on 1/19/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) LocationManager *locationManager;


@end

