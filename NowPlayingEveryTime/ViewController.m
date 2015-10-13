//
//  ViewController.m
//  NowPlayingWidget
//
//  Created by SUNGMIN / Ricky PARK on 2015. 4. 5..
//  Copyright (c) 2015년 RickyPark. All rights reserved.
//

#import "ViewController.h"
@import Social;
@import Accounts;
@import MediaPlayer;

#import "UIImage+ResizeImage.h"

const static NSString *InitialNoticeKey = @"InitialNoticeKey";

#define BackgroundImageViewTag 100
#define BlurredImageTag 101

@interface ViewController () <UIAlertViewDelegate>

@property (nonatomic, assign) BOOL isNoSNSAlertDisplayed;

@property (nonatomic, strong) NSString *songTitle;
@property (nonatomic, strong) NSString *artistTitle;
@property (nonatomic, strong) NSString *albumTitle;
@property (nonatomic, strong) NSString *lyricsString;
@property (nonatomic, strong) NSString *partiallyCopiedLyricsString;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:[InitialNoticeKey copy]] == NO) {
        UIAlertView *fbNoticeAlert = [[UIAlertView alloc] initWithTitle:@"Facebook?"
                                                                message:@"Tap FB button, and paste!"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
        [fbNoticeAlert setTag:100];
        [fbNoticeAlert show];
    }

    // view
    [self setMarqueeLabelProperties];

    [self hideArtistAndAlbumIfNeeded];

    [self setLabelsRounded];

    // notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nowPlayingItemChanged)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object:nil];

    [[MPMusicPlayerController systemMusicPlayer] beginGeneratingPlaybackNotifications];
    
    UITapGestureRecognizer *lyricsTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(coverImageViewTapped:)];
    [lyricsTapGestureRecognizer setDelegate:self];
    [_coverImageView setUserInteractionEnabled:YES];
    [_coverImageView setGestureRecognizers:@[lyricsTapGestureRecognizer]];
    
    [_swipeToSettingsGestureRecognizer addTarget:self
                                          action:@selector(swipeToSettings:)];

    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *facebookItem = [[UIMenuItem alloc] initWithTitle:@"Facebook" action:@selector(didFacebookSelected:)];
    UIMenuItem *twitterItem = [[UIMenuItem alloc] initWithTitle:@"Twitter" action:@selector(didTwitterSelected:)];
    [menuController setMenuItems:@[facebookItem, twitterItem]];

    _partiallyCopiedLyricsString = [NSString string];
}

- (void)didFacebookSelected:(id)sender
{
    NSLog(@"%s", __FUNCTION__);

    if (NSEqualRanges(_lyricsTextView.selectedRange, NSMakeRange(0, 0)) == NO) {
        _partiallyCopiedLyricsString = [_lyricsTextView.text substringWithRange:_lyricsTextView.selectedRange];
    }

    [self showShareViewToThisSNS:SLServiceTypeFacebook];
}

- (void)didTwitterSelected:(id)sender
{
    NSLog(@"%s", __FUNCTION__);

    if (NSEqualRanges(_lyricsTextView.selectedRange, NSMakeRange(0, 0)) == NO) {
        _partiallyCopiedLyricsString = [_lyricsTextView.text substringWithRange:_lyricsTextView.selectedRange];
    }

    [self showShareViewToThisSNS:SLServiceTypeTwitter];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSLog(@"%s : %@, with sender : %@", __FUNCTION__, NSStringFromSelector(action), sender);

    if ([NSStringFromSelector(action) isEqualToString:@"didFacebookSelected:"] ||
        [NSStringFromSelector(action) isEqualToString:@"didTwitterSelected:"] ||
        [NSStringFromSelector(action) isEqualToString:@"didCopySelected:"]) {
        return YES;
    }

    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] postNotificationName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                                        object:nil];

    [self setViewAlignments];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    NSLog(@"%s", __FUNCTION__);

    // Dispose of any resources that can be recreated.
}


#pragma mark - View Methods

float getScreenHeight()
{
    return [[UIScreen mainScreen] bounds].size.height;
}

- (void)setLabelsRounded
{
    [_coverImageView.layer setMasksToBounds:YES];
}

- (void)setMarqueeLabelProperties
{
    [_songTitleLabel setScrollDuration:5.0f];
    [_songTitleLabel setTrailingBuffer:7.0f];
    [_songTitleLabel setMarqueeType:MLContinuous];
    
    [_artistTitleLabel setScrollDuration:5.0f];
    [_artistTitleLabel setTrailingBuffer:7.0f];
    [_artistTitleLabel setMarqueeType:MLContinuous];
    
    [_albumTitleLabel setScrollDuration:5.0f];
    [_albumTitleLabel setTrailingBuffer:7.0f];
    [_albumTitleLabel setMarqueeType:MLContinuous];
}

- (void)hideArtistAndAlbumIfNeeded
{
    if (getScreenHeight() <= 480) {
        NSLog(@"3.5-inch screen, so set hidden artist & album label");

        [_artistTitleLabel setHidden:YES];
        [_albumTitleLabel setHidden:YES];
    } else if (getScreenHeight() <= 568) {
        [_artistTitleLabel setHidden:YES];
        [_albumTitleLabel setHidden:NO];
    } else {
        [_artistTitleLabel setHidden:NO];
        [_albumTitleLabel setHidden:NO];
    }
}

- (void)setViewWithNowPlayingItem:(MPMediaItem *)aCurrentItem
{
    [_lyricsTextView setAlpha:0.0f];
    
    if (aCurrentItem) {
        [self hideArtistAndAlbumIfNeeded];

        [_coverImageView setImage:[aCurrentItem.artwork imageWithSize:_coverImageView.frame.size]];
        [_songTitleLabel setText:_songTitle];
        
        if (getScreenHeight() <= 568) {
            NSString *mergedText = [NSString stringWithFormat:@"%@ _ %@", _artistTitle, _albumTitle];
            [_albumTitleLabel setText:mergedText];
        } else {
            [_albumTitleLabel setText:_albumTitle];
            [_artistTitleLabel setText:_artistTitle];
        }

        [[self.view viewWithTag:BlurredImageTag] removeFromSuperview];
        [[self.view viewWithTag:BackgroundImageViewTag] removeFromSuperview];

        UIImage *backgroundCoverEnlargedImage = [UIImage imageWithImage:_coverImageView.image
                                                           scaledToSize:CGSizeMake(self.view.frame.size.height, self.view.frame.size.height)];
        UIImageView *backgroundCoverImageView = [[UIImageView alloc] initWithImage:backgroundCoverEnlargedImage];
        [backgroundCoverImageView setTag:BackgroundImageViewTag];
        [self.view insertSubview:backgroundCoverImageView atIndex:0];
        [backgroundCoverImageView setCenter:self.view.center];

        UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = backgroundCoverImageView.frame;
        [effectView setTag:BlurredImageTag];
        [self.view insertSubview:effectView aboveSubview:backgroundCoverImageView];

        if (_fbShareButton.alpha < 1.0f || _twtShareButton.alpha < 1.0f) {
            [_fbShareButton setAlpha:1.0];
            [_fbShareButton setUserInteractionEnabled:YES];
            [_twtShareButton setAlpha:1.0];
            [_twtShareButton setUserInteractionEnabled:YES];
        }
        
        [_lyricsTextView setText:_lyricsString];
    } else {
        [_songTitleLabel setText:@"Fill With Your Music"];
        [_coverImageView setImage:[UIImage imageNamed:@"music-note"]];
        [_artistTitleLabel setHidden:YES];
        [_albumTitleLabel setHidden:YES];
        [_fbShareButton setAlpha:0.5];
        [_fbShareButton setUserInteractionEnabled:NO];
        [_twtShareButton setAlpha:0.5];
        [_twtShareButton setUserInteractionEnabled:NO];

        [[self.view viewWithTag:BackgroundImageViewTag] removeFromSuperview];
        [[self.view viewWithTag:BlurredImageTag] removeFromSuperview];
        
        [_lyricsTextView setText:@""];
    }
}

- (void)showShareButtonsIfAvailable
{
    [_fbShareButton setHidden:![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]];
    [_twtShareButton setHidden:![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]];
}

- (void)setViewAlignments
{
    [_fbLogoImageView setCenter:_fbShareButton.center];
    [_twtLogoImageView setCenter:_twtShareButton.center];
}

#pragma mark - MPMusicPlayerController Notifications

- (void)nowPlayingItemChanged
{
    NSLog(@"%s", __FUNCTION__);
    
    MPMediaItem *currentItem = [[MPMusicPlayerController systemMusicPlayer] nowPlayingItem];
    
    [self getsongInfoWithSong:currentItem];

    [self setViewWithNowPlayingItem:currentItem];
}

- (void)getsongInfoWithSong:(MPMediaItem *)aCurrentItem
{
    _songTitle = aCurrentItem.title ?: @"";
    _artistTitle = aCurrentItem.artist ?: @"";
    _albumTitle = aCurrentItem.albumTitle ?: @"";
    _lyricsString = aCurrentItem.lyrics ?: @"";
}

#pragma mark - Action Methods

- (IBAction)tappedFBShare:(id)sender
{
    NSLog(@"%s", __FUNCTION__);

    [self showShareViewToThisSNS:SLServiceTypeFacebook];
}

- (IBAction)tappedTWTShare:(id)sender
{
    [self showShareViewToThisSNS:SLServiceTypeTwitter];
}

- (void)showShareViewToThisSNS:(NSString *)aSnsType
{
    if ([SLComposeViewController isAvailableForServiceType:aSnsType]) {

        NSString *initialText = [NSString string];
        NSString *dividerString = [NSString stringWithFormat:@" %@ ", [[NSUserDefaults standardUserDefaults] objectForKey:@"NPETDivider"] ?: @"_"];
        if (_partiallyCopiedLyricsString.length > 0) {
            initialText = [initialText stringByAppendingString:[NSString stringWithFormat:@"%@\n\n", _partiallyCopiedLyricsString]];
        }
        initialText = [initialText stringByAppendingString:@"#nowplaying "];

        MPMediaItem *nowPlayingItem = [[MPMusicPlayerController systemMusicPlayer] nowPlayingItem];
        initialText = [[initialText stringByAppendingString:nowPlayingItem.title] stringByAppendingString:dividerString];
        initialText = [[initialText stringByAppendingString:nowPlayingItem.albumTitle] stringByAppendingString:dividerString];
        
        NSString *artistNameWithoutSpace = [nowPlayingItem.artist stringByReplacingOccurrencesOfString:@" " withString:@""];
        initialText = [initialText stringByAppendingString:[@"#" stringByAppendingString:artistNameWithoutSpace]];
        
        if ([aSnsType isEqualToString:SLServiceTypeFacebook]) {
            [[UIPasteboard generalPasteboard] setValue:initialText forPasteboardType:@"public.text"];
        }

        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:aSnsType];
        [mySLComposerSheet setInitialText:initialText];
        [mySLComposerSheet addImage:_coverImageView.image];
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {

            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post to %@ Canceled", aSnsType);
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post to %@ Sucessful", aSnsType);
                    break;

                default:
                    break;
            }
        }];
        
        [self presentViewController:mySLComposerSheet
                           animated:YES
                        completion:^{
                                _partiallyCopiedLyricsString = @"";
                            }];
    } else {
        if (!_isNoSNSAlertDisplayed) {
            _isNoSNSAlertDisplayed = YES;
            NSString *titleString = [NSString stringWithFormat:@"%@ is not available now. Register your account first.", [[[aSnsType componentsSeparatedByString:@"."] lastObject] capitalizedString]];
            
            UIAlertView *noSNSAlert = [[UIAlertView alloc] initWithTitle:titleString
                                                                 message:nil
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
            [noSNSAlert setTag:300];
            [noSNSAlert show];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (!_lyricsTextView.isHidden) {
        //do something
        [UIView animateWithDuration:0.35 animations:^{
            [_lyricsTextView setAlpha:0.0f];
        }];
    }
}

#pragma mark - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        UIAlertView *twtNoticeAlert = [[UIAlertView alloc] initWithTitle:@"Twitter?"
                                                                message:@"Tap Twitter button, and just share!"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
        [twtNoticeAlert setTag:200];
        [twtNoticeAlert show];
    } else if (alertView.tag == 200) {
        [[NSUserDefaults standardUserDefaults] setObject:@(YES)
                                                  forKey:[InitialNoticeKey copy]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (alertView.tag == 300) {
        _isNoSNSAlertDisplayed = NO;
    }
}

#pragma mark - Gesture Recognizers

- (void)swipeToSettings:(NSNotification *)aNoti
{
    [self performSegueWithIdentifier:@"NPETPushToSettingsSequeIdentifier"
                              sender:self];
}

- (void)coverImageViewTapped:(id)sender
{
    NSLog(@"%s : %@", __FUNCTION__, _lyricsString.length ? @"has lyrics" : @"no lyrics");

    if (_lyricsTextView.text.length) {
        [UIView animateWithDuration:0.35 animations:^{
            [_lyricsTextView setAlpha:1.0f];
        }];
    }
}

@end
