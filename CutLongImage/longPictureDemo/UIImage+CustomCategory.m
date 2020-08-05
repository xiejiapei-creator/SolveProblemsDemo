//
//  UIImage+CustomCategory.m
//  longPictureDemo
//
//  Created by 谢佳培 on 2020/7/13.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "UIImage+CustomCategory.h"

@implementation UIImage(CustomCategory)

// 获取图片的缩略图
- (UIImage *)getThumbnailWithTargetSize:(CGSize)targetSize {
    
    CGSize imageSize = self.size;
    
    if (CGSizeEqualToSize(targetSize, CGSizeZero)) {
        return self;
    }
    
    if (targetSize.width > imageSize.width && targetSize.height > imageSize.height) {
        return self;
    }
    
    CGFloat scale = MAX(targetSize.width / imageSize.width, targetSize.height / imageSize.height);
    CGSize scaleSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
    
    UIGraphicsBeginImageContextWithOptions(targetSize, false, 0);

    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    [bezierPath addClip];

    CGRect rect = CGRectMake((targetSize.width - scaleSize.width) / 2, (targetSize.height - scaleSize.height) / 2, scaleSize.width, scaleSize.height);
    [self drawInRect:rect];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
