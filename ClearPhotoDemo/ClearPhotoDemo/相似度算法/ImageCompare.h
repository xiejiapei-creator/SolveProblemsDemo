//
//  ImageCompare.h
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/31.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageCompare : NSObject

/// 是否相似
+ (BOOL)isImage:(UIImage *)image1 likeImage:(UIImage *)image2;

/// 获取相似度
+ (float)isImageFloat:(UIImage *)image1 likeImage:(UIImage *)image2;

@end
