//
//  PhotoInfoItem.h
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/31.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoInfoItem : NSObject

/// 图片资源
@property (nonatomic, strong) PHAsset *asset;
/// 图片
@property (nonatomic, strong) UIImage *exactImage;
/// 图片数据
@property (nonatomic, strong) NSData *originImageData;
/// 图片数据大小
@property (nonatomic, assign) NSUInteger originImageDataLength;
/// 是否选中
@property (nonatomic, assign) BOOL isSelected;

/// 初始化Model，传入info
- (instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
