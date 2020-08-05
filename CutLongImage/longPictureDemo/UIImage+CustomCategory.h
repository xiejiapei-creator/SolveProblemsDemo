//
//  UIImage+CustomCategory.h
//  longPictureDemo
//
//  Created by 谢佳培 on 2020/7/13.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage(CustomCategory)

- (UIImage *)getThumbnailWithTargetSize:(CGSize)targetSize;

@end

NS_ASSUME_NONNULL_END
