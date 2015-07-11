//
//  TodayViewController.m
//  NowPlayingTodayExtension
//
//  Created by SUNGMIN / Ricky PARK on 2015. 4. 19..
//  Copyright (c) 2015년 RickyPark. All rights reserved.
//

#import "TodayViewController.h"
@import NotificationCenter;
@import MediaPlayer;

@interface TodayViewController () <NCWidgetProviding>
{
    MPMediaItem *nowPlayingItem;
}

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"%s", __FUNCTION__);
    // Do any additional setup after loading the view from its nib.
}

- (void)awakeFromNib
{
    NSLog(@"%s", __FUNCTION__);

    [super awakeFromNib];
    [self setPreferredContentSize:CGSizeMake(self.view.bounds.size.width, 99)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    NSLog(@"%s", __FUNCTION__);

    nowPlayingItem = [[self currentPlayerController] nowPlayingItem];
    if (nowPlayingItem) {
        CGSize imageSize = nowPlayingItem.artwork.bounds.size;
        [_coverImageView setImage:[[nowPlayingItem artwork] imageWithSize:CGSizeMake(imageSize.width * 0.1, imageSize.height * 0.1)]];
        NSLog(@"%@", _coverImageView.image);
        [_fbShareButton setUserInteractionEnabled:YES];
        [_twtShareButton setUserInteractionEnabled:YES];
    } else {
        [_coverImageView setImage:nil];
        [_fbShareButton setUserInteractionEnabled:NO];
        [_twtShareButton setUserInteractionEnabled:NO];
    }

    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    NSLog(@"%s", __FUNCTION__);

    defaultMarginInsets.bottom = 0;
//    defaultMarginInsets.left = 0;

    return defaultMarginInsets;
}

- (IBAction)shareToFBTapped:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"NPET://fb"];
    [self.extensionContext openURL:url completionHandler:nil];
}

- (IBAction)shareToTWTTapped:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"NPET://twt"];
    [self.extensionContext openURL:url completionHandler:nil];
}

- (IBAction)coverTapped:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"NPET://run"];
    [self.extensionContext openURL:url completionHandler:nil];
}

#pragma mark - Helper Methods

- (MPMusicPlayerController *)currentPlayerController
{
    MPMusicPlayerController *controller;

    NSString *reqSysVer = @"8.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        controller = [MPMusicPlayerController systemMusicPlayer];
    } else {
        controller = [MPMusicPlayerController iPodMusicPlayer];
    }

    return controller;
    //    return [MPMusicPlayerController systemMusicPlayer];
}
@end
