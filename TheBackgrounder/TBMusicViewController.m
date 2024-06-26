//
//  TBFirstViewController.m
//  TheBackgrounder
//
//  Copyright (c) 2013 Gustavo Ambrozio. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "TBMusicViewController.h"

@interface TBMusicViewController ()

@property (nonatomic, strong) AVQueuePlayer * player;
@property (nonatomic, strong) id timeObserver;

@end

@implementation TBMusicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Audio", @"Audio");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

- (IBAction)didTapPlayPause:(id)sender
{
    self.btnPlayPause.selected = !self.btnPlayPause.selected;
    if (self.btnPlayPause.selected)
    {
        [self.player play];
    }
    else
    {
        [self.player pause];
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    NSError *sessionError = nil;
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleInterruption:)
                                                 name: AVAudioSessionInterruptionNotification
                                               object: [AVAudioSession sharedInstance]];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];

    // Change the default output audio route
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);

    NSArray *queue = @[[AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:@"IronBacon" withExtension:@"mp3"]],
                       [AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:@"FeelinGood" withExtension:@"mp3"]],
                       [AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:@"WhatYouWant" withExtension:@"mp3"]]];

    self.player = [[AVQueuePlayer alloc] initWithItems:queue];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;

    [self.player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:nil];

    void (^observerBlock)(CMTime time) = ^(CMTime time) {
        NSString *timeString = [NSString stringWithFormat:@"%02.2f", (float)time.value / (float)time.timescale];
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            self.lblMusicTime.text = timeString;
        } else {
            NSLog(@"App is backgrounded. Time is: %@", timeString);
        }
    };

    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(10, 1000)
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:observerBlock];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentItem"])
    {
        AVPlayerItem *item = ((AVPlayer *)object).currentItem;
        self.lblMusicName.text = ((AVURLAsset*)item.asset).URL.pathComponents.lastObject;
        NSLog(@"New music name: %@", self.lblMusicName.text);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
