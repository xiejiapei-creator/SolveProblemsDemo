//
//  ClearPhotoManager.h
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/31.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PhotoNotificationStatus)
{
    PhotoNotificationStatusDefualt  = 0, // 相册变更默认处理
    PhotoNotificationStatusClose    = 1, // 相册变更不处理
    PhotoNotificationStatusNeed     = 2, // 相册变更主动处理
};

@protocol ClearPhotoManagerDelegate <NSObject>

@optional
/// 相册变动代理方法
- (void)clearPhotoLibraryDidChange;

@end

@interface ClearPhotoManager : NSObject

/// 单例
+ (ClearPhotoManager *)shareManager;

/// 代理
@property (nonatomic, weak) id<ClearPhotoManagerDelegate> delegate;

/// 变更状态
@property (nonatomic, assign) PhotoNotificationStatus notificationStatus;

/// 相似照片数组：存储了多个字典，每个字典代表了同一个日期下的相似照片
@property (nonatomic, strong, readonly) NSMutableArray *similarArray;
/// 相似照片信息：存储了相似图片数量及可以节省的内存空间大小
@property (nonatomic, strong, readonly) NSDictionary *similarInfo;

/// 截图照片数组：存储了多个字典，每个字典代表了同一个日期下的截图照片
@property (nonatomic, strong, readonly) NSMutableArray *screenshotsArray;
/// 截图照片信息：存储了屏幕截图数量及可以节省的内存空间大小
@property (nonatomic, strong, readonly) NSDictionary *screenshotsInfo;

/// 可瘦身的照片数组：存储了多个字典，每个字典代表了一个可瘦身的照片
@property (nonatomic, strong, readonly) NSMutableArray *thinPhotoArray;
/// 瘦身照片信息：存储了瘦身图片数量及可以节省的内存空间大小
@property (nonatomic, strong, readonly) NSDictionary *thinPhotoInfo;

/// 节约空间
@property (nonatomic, assign, readonly) double totalSaveSpace;

/// 加载照片
- (void)loadPhotoWithProcess:(void (^)(NSInteger current, NSInteger total))process completionHandler:(void (^)(BOOL success, NSError *error))completion;

/// 删除照片
+ (void)deleteAssets:(NSArray<PHAsset *> *)assets completionHandler:(void (^)(BOOL success, NSError *error))completion;

/// 获取原图
+ (void)getOriginImageWithAsset:(PHAsset *)asset completionHandler:(void (^)(UIImage *result, NSDictionary *info))completion;

/// 压缩照片
+ (void)compressImageWithData:(NSData *)imageData completionHandler:(void (^)(UIImage *compressImage, NSUInteger imageDataLength))completion;

/// 确定提示框
+ (void)tipWithMessage:(NSString *)str;
 
@end

NS_ASSUME_NONNULL_END
