//
//  TBFourthViewController.m
//  TheBackgrounder
//
//  Copyright (c) 2013 Gustavo Ambrozio. All rights reserved.
//

#import "TBNewsstandViewController.h"

@interface TBNewsstandViewController ()
@property (nonatomic, strong) NKIssue *currentIssue;
@property (nonatomic, strong) NSString *issueFilename;
@end

@implementation TBNewsstandViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Newsstand", @"Newsstand");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.webView.hidden = YES;
    self.progress.progress = 0.0f;
    self.progress.hidden = NO;

    NKLibrary *library = [NKLibrary sharedLibrary];
    for (NKIssue *issue in [library.issues copy]) {
        [library removeIssue:issue];
    }

    self.currentIssue = [library addIssueWithName:@"text" date:[NSDate date]];

    NSURL *downloadURL = [[NSURL alloc] initWithString:self.txtURL.text];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    NKAssetDownload *assetDownload = [self.currentIssue addAssetWithRequest:request];
    [assetDownload downloadWithDelegate:self];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - NSURLConnectionDownloadDelegate
- (void)connection:(NSURLConnection *)connection
      didWriteData:(long long)bytesWritten
 totalBytesWritten:(long long)totalBytesWritten
expectedTotalBytes:(long long)expectedTotalBytes
{
    float progress = (float)totalBytesWritten / (float)expectedTotalBytes;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        self.progress.progress = progress;
    } else {
        NSLog(@"App is backgrounded. Progress = %.1f", progress);
    }
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection
                        destinationURL:(NSURL *)destinationURL
{
    self.issueFilename = destinationURL.pathComponents.lastObject;
    NSURL *fileURL = [self.currentIssue.contentURL URLByAppendingPathComponent:self.issueFilename];

    [[NSFileManager defaultManager] moveItemAtURL:destinationURL
                                            toURL:fileURL
                                            error:nil];

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        self.webView.hidden = NO;
        self.progress.hidden = YES;
        NSURL *fileURL = [self.currentIssue.contentURL URLByAppendingPathComponent:self.issueFilename];
        [self.webView loadRequest:[NSURLRequest requestWithURL:fileURL]];
    } else {
        NSLog(@"App is backgrounded. Download finished");
    }
}
@end
