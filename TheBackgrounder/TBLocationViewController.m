//
//  TBSecondViewController.m
//  TheBackgrounder
//
//  Copyright (c) 2013 Gustavo Ambrozio. All rights reserved.
//

#import "TBLocationViewController.h"

@interface TBLocationViewController ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@end

@implementation TBLocationViewController

- (IBAction)accuracyChanged:(id)sender
{
    const CLLocationAccuracy accuracyValues[] =
    {
        kCLLocationAccuracyBestForNavigation,
        kCLLocationAccuracyBest,
        kCLLocationAccuracyNearestTenMeters,
        kCLLocationAccuracyHundredMeters,
        kCLLocationAccuracyKilometer,
        kCLLocationAccuracyThreeKilometers
    };

    self.locationManager.desiredAccuracy = accuracyValues[self.segmentAccuracy.selectedSegmentIndex];
}

- (IBAction)enabledStateChanged:(id)sender
{
    if (self.switchEnabled.on) {
        [self.locationManager startUpdatingLocation];
    } else {
        [self.locationManager stopUpdatingLocation];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Location", @"Location");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.locations = [[NSMutableArray alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = newLocation.coordinate;
    [self.map addAnnotation:annotation];

    [self.locations addObject:annotation];

    // Remove values if array is too big
    while (self.locations.count > 100) {
        annotation = [self.locations objectAtIndex:0];
        [self.locations removeObjectAtIndex:0];
        [self.map removeAnnotation:annotation];
    }

    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
        double maxLatitude = -91;
        double minLatitude = 91;
        double maxLongitude = -181;
        double minLongitude = 181;

        for (MKPointAnnotation *annotation in self.locations) {
            CLLocationCoordinate2D coordinate = annotation.coordinate;

            if (coordinate.latitude > maxLatitude) {
                maxLatitude = coordinate.latitude;
            }

            if (coordinate.latitude < minLatitude) {
                minLatitude = coordinate.latitude;
            }

            if (coordinate.longitude > maxLongitude) {
                maxLongitude = coordinate.longitude;
            }

            if (coordinate.longitude < minLongitude) {
                minLongitude = coordinate.longitude;
            }
        }

        MKCoordinateRegion region;
        region.span.latitudeDelta = (maxLatitude + 90) - (minLatitude + 90);
        region.span.longitudeDelta = (maxLongitude + 180) - (minLongitude + 180);
        region.center.latitude = minLatitude + region.span.latitudeDelta / 2;
        region.center.longitude = minLongitude + region.span.longitudeDelta / 2;

        [self.map setRegion:region animated:YES];
    } else {
        NSLog(@"App is backgrounded. New location is %@", newLocation);
    }
}
@end
