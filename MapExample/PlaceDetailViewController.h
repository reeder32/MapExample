//
//  PlaceDetailViewController.h
//  MapExample
//
//  Created by Nick Reeder on 1/26/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property NSString *urlString;



@end
