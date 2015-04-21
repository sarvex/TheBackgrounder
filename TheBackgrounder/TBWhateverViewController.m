//
//  TBThirdViewController.m
//  TheBackgrounder
//
//  Copyright (c) 2013 Gustavo Ambrozio. All rights reserved.
//

#import "TBWhateverViewController.h"

@interface TBWhateverViewController ()
@property (nonatomic, strong) NSDecimalNumber *previous;
@property (nonatomic, strong) NSDecimalNumber *current;
@property (nonatomic) NSUInteger position;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation TBWhateverViewController

- (IBAction)didTapPlayPause:(id)sender
{
    self.btnPlayPause.selected = !self.btnPlayPause.selected;
    if (self.btnPlayPause.selected) {
        self.previous = [NSDecimalNumber one];
        self.current = [NSDecimalNumber one];
        self.position = 1;

        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                            target:self
                                                          selector:@selector(calculateNextNumber)
                                                          userInfo:nil
                                                           repeats:YES];

        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@"Background handler called. Not running background tasks anymore.");
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }];
    } else {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
        if (self.backgroundTask != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }
    }
}

- (void)calculateNextNumber
{
    NSDecimalNumber *result = [self.current decimalNumberByAdding:self.previous];

    if ([result compare:[NSDecimalNumber decimalNumberWithMantissa:1 exponent:40 isNegative:NO]] == NSOrderedAscending) {
        self.previous = self.current;
        self.current = result;
        self.position++;
    } else {
        self.previous = [NSDecimalNumber one];
        self.current = [NSDecimalNumber one];
        self.position = 1;
    }

    NSString *currentResultLabel = [NSString stringWithFormat:@"Position %lu = %@", (unsigned long)self.position, self.current];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        self.txtResult.text = currentResultLabel;
    } else {
        NSLog(@"App is backgrounded. Next number = %@", currentResultLabel);
        NSLog(@"Background time remaining = %.1f seconds", [UIApplication sharedApplication].backgroundTimeRemaining);
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Whatever", @"Whatever");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.backgroundTask = UIBackgroundTaskInvalid;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
