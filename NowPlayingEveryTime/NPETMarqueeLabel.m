//
//  NPETMarqueeLabel.m
//  NowPlayingEveryTime
//
//  Created by 박성민 on 2015. 8. 16..
//  Copyright (c) 2015년 RickyPark. All rights reserved.
//

#import "NPETMarqueeLabel.h"

@implementation NPETMarqueeLabel

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidBecomeActiveNotification
                                                      object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartLabel)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    
}

@end