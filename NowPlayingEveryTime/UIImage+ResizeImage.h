//
//  UIImage+ResizeImage.h
//  NowPlayingWidget
//
//  Created by SUNGMIN / Ricky PARK on 2015. 4. 19..
//  Copyright (c) 2015년 RickyPark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ResizeImage)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
