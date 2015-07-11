//
//  ViewController.h
//  NowPlayingWidget
//
//  Created by SUNGMIN / Ricky PARK on 2015. 4. 5..
//  Copyright (c) 2015년 RickyPark. All rights reserved.
//

@import UIKit;

@interface ViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;
@property (strong, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *albumTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *fbShareButton;
@property (strong, nonatomic) IBOutlet UIButton *twtShareButton;
@property (strong, nonatomic) IBOutlet UIImageView *fbLogoImageView;
@property (strong, nonatomic) IBOutlet UIImageView *twtLogoImageView;
@property (strong, nonatomic) IBOutlet UITextView *lyricsTextView;

- (IBAction)tappedFBShare:(id)sender;
- (IBAction)tappedTWTShare:(id)sender;

@end

