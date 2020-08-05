//
//  ClearPhotoItem.h
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/31.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 图片类型
typedef NS_ENUM(NSInteger, ClearPhotoType) {
    ClearPhotoTypeUnknow      = 0, // 未知
    ClearPhotoTypeSimilar     = 1, // 相似图片
    ClearPhotoTypeScreenshots = 2, // 截屏图片
    ClearPhotoTypeThinPhoto   = 3, // 图片瘦身
};

@interface ClearPhotoItem : NSObject

/// 图片类型
@property (nonatomic, assign) ClearPhotoType type;
/// 名称
@property (nonatomic, copy) NSString *name;
/// 详情
@property (nonatomic, copy) NSString *detail;
/// 可节约空间字符串
@property (nonatomic, copy) NSString *saveString;
/// 可处理图片的数量
@property (nonatomic, assign) NSInteger count;
/// 图标
@property (nonatomic, copy) NSString *icon;

/// 初始化Model，传入类型和info
- (instancetype)initWithType:(ClearPhotoType)type dataDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
