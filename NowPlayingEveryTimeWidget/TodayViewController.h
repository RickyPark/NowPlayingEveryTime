//
//  TodayViewController.h
//  NowPlayingTodayExtension
//
//  Created by SUNGMIN / Ricky PARK on 2015. 4. 19..
//  Copyright (c) 2015년 RickyPark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;
@property (strong, nonatomic) IBOutlet UIButton *fbShareButton;
@property (strong, nonatomic) IBOutlet UIButton *twtShareButton;

- (IBAction)shareToFBTapped:(id)sender;
- (IBAction)shareToTWTTapped:(id)sender;
- (IBAction)coverTapped:(id)sender;

@end
