//
//  DemoView.m
//  DevBoy
//
//  Created by Ahmad Abdul-Gawad Mahmoud on 10/26/16.
//  Copyright © 2016 Ahmad Abdul-Gawad Mahmoud. All rights reserved.
//

#import "DemoView.h"
#import <UIView+Facade.h>
#import "Helper.h"
#import "DevBoy-Swift.h"

@interface DemoView () {
    
    BOOL _tracking;
    NSMutableArray *dummyData;
    NSTimer *timer;
    int counter;
}

@end

@implementation DemoView

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:13/255.0 green:14/255.0 blue:20/255.0 alpha:1.0];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.devBoy = [DevBoy new];
    self.devBoy.delegate = self;

    self.mapView = [MKMapView new];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.layer.cornerRadius = 7.0;
    self.mapView.clipsToBounds = YES;
    [self.view addSubview:self.mapView];
    
    self.maskView = [UIView new];
    self.maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    [self.mapView addSubview:self.maskView];
    
    self.avatarImageView = [UIImageView new];
    
    if ([[Helper getInstance] userPhoto] != nil) {
        
        self.avatarImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[Helper getInstance] userPhoto]]];
        
    } else {
        
        self.avatarImageView.image = [UIImage imageNamed:@"avatar"];
    }
    
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 30.0;
    self.avatarImageView.layer.borderWidth = 1.0;
    self.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.maskView addSubview:self.avatarImageView];
    
    self.dateLabel = [UILabel new];
    self.dateLabel.text = @"July 17th, 2015";
    self.dateLabel.font = [UIFont fontWithName:@"Raleway-Bold" size:19];
    self.dateLabel.textColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1.0];
    [self.maskView addSubview:self.dateLabel];
    
    self.cycleImageView = [UIImageView new];
    self.cycleImageView.image = [UIImage imageNamed:@"cycle"];
    [self.maskView addSubview:self.cycleImageView];
    
    self.trackingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.trackingButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self.trackingButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [self.trackingButton setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    [self.trackingButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [self.maskView addSubview:self.trackingButton];
    
    self.containerView = [UIView new];
    [self.view addSubview:self.containerView];
    
    self.timeView = [[MetricView alloc] initWithImage:[UIImage imageNamed:@"time"] title:@"Elapsed Time" color:[UIColor whiteColor]];
    [self.containerView addSubview:self.timeView];
    
    self.topSpeedView = [[MetricView alloc] initWithImage:[UIImage imageNamed:@"topSpeed"] title:@"Top Speed" color:[UIColor whiteColor]];
    [self.containerView addSubview:self.topSpeedView];
    
    self.averageSpeedView = [[MetricView alloc] initWithImage:[UIImage imageNamed:@"avgSpeed"] title:@"Avg. Speed" color:[UIColor whiteColor]];
    [self.containerView addSubview:self.averageSpeedView];
    
    self.distanceView = [[MetricView alloc] initWithImage:[UIImage imageNamed:@"distance"] title:@"Distance" color:[UIColor whiteColor]];
    [self.containerView addSubview:self.distanceView];
    
    self.averageAltitudeView = [[MetricView alloc] initWithImage:[UIImage imageNamed:@"avgAlt"] title:@"Avg. Altitude" color:[UIColor whiteColor]];
    [self.containerView addSubview:self.averageAltitudeView];
    
    self.maxAltitudeView = [[MetricView alloc] initWithImage:[UIImage imageNamed:@"maxAlt"] title:@"Max Altitude" color:[UIColor whiteColor]];
    [self.containerView addSubview:self.maxAltitudeView];
    
    // dummy
    
    /*if ([Utils getLocationsFromFirebase].count > 0) {
        
        dummyData = (NSMutableArray*)[Utils getLocationsFromFirebase];
        
        [NSTimer scheduledTimerWithTimeInterval:0.125 target:self selector:@selector(drawOnMap) userInfo:nil repeats:true];

    } else {
        
        dummyData = [NSMutableArray new];
    }*/
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewLocationsAdded:) name: @"newLocationAdded" object:nil];
    
    [Utils observeNewLocations];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.mapView anchorTopCenterFillingWidthWithLeftAndRightPadding:10 topPadding:20 height:380];
    [self.maskView anchorTopCenterFillingWidthWithLeftAndRightPadding:0 topPadding:0 height:75];
    [self.avatarImageView anchorCenterLeftWithLeftPadding:10 width:60 height:60];
    [self.dateLabel alignToTheRightOf:self.avatarImageView matchingTopAndFillingWidthWithLeftAndRightPadding:10 height:20];
    [self.cycleImageView alignUnder:self.dateLabel matchingLeftWithTopPadding:3 width:40 height:40];
    [self.trackingButton anchorCenterRightWithRightPadding:10 width:60 height:60];
    
    [self.containerView alignUnder:self.mapView centeredFillingWidthAndHeightWithLeftAndRightPadding:10 topAndBottomPadding:10];
    [self.containerView groupGrid:@[self.topSpeedView, self.averageSpeedView, self.distanceView, self.timeView, self.averageAltitudeView, self.maxAltitudeView] fillingWidthWithColumnCount:3 spacing:10];
}


#pragma mark - Follower

- (void)start {
    _tracking = YES;
    
    [self.trackingButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    [self.trackingButton removeTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [self.trackingButton addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    
    [self.devBoy beginRouteTracking];
}

- (void)stop {
    _tracking = NO;
    
    [self.trackingButton setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    [self.trackingButton removeTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [self.trackingButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    
    [self.devBoy endRouteTracking];
    
    [_mapView addOverlay:self.devBoy.routePolyline];
    [_mapView setRegion:self.devBoy.routeRegion animated:YES];
}

- (void)devBoyDidUpdate:(DevBoy *)devBoy {
    self.topSpeedView.valueLabel.text = [NSString stringWithFormat:@"%.1f mph", [devBoy topSpeedWithUnit:SpeedUnitMilesPerHour]];
    self.averageSpeedView.valueLabel.text = [NSString stringWithFormat:@"%.1f mph", [devBoy averageSpeedWithUnit:SpeedUnitMilesPerHour]];
    self.timeView.valueLabel.text = [devBoy routeDurationString];
    self.distanceView.valueLabel.text = [NSString stringWithFormat:@"%.2f mi", [devBoy totalDistanceWithUnit:DistanceUnitMiles]];
    self.averageAltitudeView.valueLabel.text = [NSString stringWithFormat:@"%.0f ft", [devBoy averageAltitudeWithUnit:DistanceUnitFeet]];
    self.maxAltitudeView.valueLabel.text = [NSString stringWithFormat:@"%.0f ft", [devBoy maximumAltitudeWithUnit:DistanceUnitFeet]];
}


#pragma mark - Map view delegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.fillColor = [UIColor colorWithRed:250/255.0 green:90/255.0 blue:45/255.0 alpha:1.0];
    renderer.strokeColor = [UIColor colorWithRed:250/255.0 green:90/255.0 blue:45/255.0 alpha:1.0];
    renderer.lineWidth = 5;
    return renderer;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    NSLog(@"longitude :: %f latitude :: %f", userLocation.coordinate.longitude, userLocation.coordinate.latitude);
    
    if (_tracking) {
//        [mapView setRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(.0005, .0005)) animated:YES];
//        [dummyData addObject:[NSString stringWithFormat:@"%f", userLocation.coordinate.longitude]];
//        [dummyData addObject:[NSString stringWithFormat:@"%f", userLocation.coordinate.latitude]];
        NSString *latitude = [NSString stringWithFormat:@"%f", userLocation.coordinate.latitude];
        NSString *longitude = [NSString stringWithFormat:@"%f", userLocation.coordinate.longitude];
        
        [Utils storeLocationsWithLatitudeWithLatitude:latitude andLongitude:longitude];
    }
}

#pragma mark - HANDLE FIREBASE DATA.

- (void) handleNewLocationsAdded:(NSNotification*) notification {
    
    NSDictionary *location = notification.object;
    
    [self centerMapOnThisLocation:location];

    [self storeAndUpdateUIWithThisLocation:location];
    
//    [self drawPolyLine];
}

- (void) centerMapOnThisLocation: (NSDictionary*) location {

    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([[location valueForKey:@"latitude"] floatValue], [[location valueForKey:@"longitude"] floatValue]);
    [_mapView setRegion:MKCoordinateRegionMake(coor, MKCoordinateSpanMake(.0005, .0005)) animated:YES];
}

- (void) storeAndUpdateUIWithThisLocation: (NSDictionary*) location {
    
    [_devBoy handleLocationUpdate:[[CLLocation alloc] initWithLatitude:[[location valueForKey:@"latitude"] floatValue] longitude:[[location valueForKey:@"longitude"] floatValue]]];
    
    // store longitude first then latitude values.
    
    [_devBoy.routeLocations addObject:[[CLLocation alloc] initWithLatitude:[[location valueForKey:@"longitude"] floatValue] longitude:[[location valueForKey:@"latitude"] floatValue]]];
    
}

- (void) drawPolyLine {
    
    [_devBoy createPolylineForRoute];
    [_devBoy createRegionForRoute];
    [_mapView addOverlay:self.devBoy.routePolyline];
    [_mapView setRegion:self.devBoy.routeRegion animated:YES];
}

#pragma mark - SAVE DATA

- (void) saveDataFromArray:(NSMutableArray*) dummyData2 {
    
    //Get the documents directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"myfile.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) {
        
        path = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"myfile.plist"] ];
    }
    
    NSMutableDictionary *data;
    
    if ([fileManager fileExistsAtPath: path]) {
        
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    }
    else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    
    //To insert the data into the plist
    [data setObject:dummyData2 forKey:@"dummyData"];
    [data writeToFile:path atomically:YES];
}

-(NSMutableArray*) retrieveData {
    
    //Get the documents directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"myfile.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) {
        
        path = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"myfile.plist"] ];
    }
    
    //To reterive the data from the plist
    NSMutableDictionary *savedValue = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    NSMutableArray *dummyData2 = [savedValue objectForKey:@"dummyData"];
    
    return dummyData2;
}

-(void) drawOnMap {
    
//    if (counter % 2 == 0) {
// 
//        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([[dummyData objectAtIndex:counter+1] floatValue], [[dummyData objectAtIndex:counter] floatValue]);
//        [_mapView setRegion:MKCoordinateRegionMake(coor, MKCoordinateSpanMake(.0005, .0005)) animated:YES];
//    }
//    else {
//        
//        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([[dummyData objectAtIndex:counter+1] floatValue], [[dummyData objectAtIndex:counter] floatValue]);
//        [_mapView setRegion:MKCoordinateRegionMake(coor, MKCoordinateSpanMake(.0005, .0005)) animated:YES];
//
//        counter++;
//    }
    
    if (counter >= dummyData.count) {
        
        
        [_devBoy createPolylineForRoute];
        [_devBoy createRegionForRoute];
        [_mapView addOverlay:self.devBoy.routePolyline];
        [_mapView setRegion:self.devBoy.routeRegion animated:YES];
        [timer invalidate];
    }
    else {
        
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([[dummyData objectAtIndex:counter+1] floatValue], [[dummyData objectAtIndex:counter] floatValue]);
        [_mapView setRegion:MKCoordinateRegionMake(coor, MKCoordinateSpanMake(.0005, .0005)) animated:YES];
        
        
        [_devBoy handleLocationUpdate:[[CLLocation alloc] initWithLatitude:[[dummyData objectAtIndex:counter+1] floatValue] longitude:[[dummyData objectAtIndex:counter] floatValue]]];
        
        [_devBoy.routeLocations addObject:[[CLLocation alloc] initWithLatitude:[[dummyData objectAtIndex:counter+1] floatValue] longitude:[[dummyData objectAtIndex:counter] floatValue]]];
        
        counter += 2;
    }
    

}

@end
