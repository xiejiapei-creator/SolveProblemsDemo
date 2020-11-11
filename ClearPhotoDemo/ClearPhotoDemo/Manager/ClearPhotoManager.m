//
//  ClearPhotoManager.m
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/31.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "ClearPhotoManager.h"
#import "ImageCompare.h"

@interface ClearPhotoManager ()<PHPhotoLibraryChangeObserver>

// 获取相簿中的所有PHAsset对象
@property (nonatomic, strong) PHFetchResult *assetArray;
// 获取相簿中的上一张图片资源
@property (nonatomic, strong) PHAsset *lastAsset;
// 上一张图片的缩略图
@property (nonatomic, strong) UIImage *lastExactImage;
// 上一张图片的原图数据
@property (nonatomic, strong) NSData *lastOriginImageData;
// 上一张图片资源和当前图片资源是否是相似图片
@property (nonatomic, assign) BOOL isLastSame;

@property (nonatomic, strong) NSMutableData *theData;


// 相似图片数组
@property (nonatomic, strong, readwrite) NSMutableArray *similarArray;
// 相似图片的信息
@property (nonatomic, strong, readwrite) NSDictionary *similarInfo;
// 删掉相似图片可以节省的空间大小
@property (nonatomic, assign) NSUInteger similarSaveSpace;

// 屏幕截图数组
@property (nonatomic, strong, readwrite) NSMutableArray *screenshotsArray;
// 屏幕截图的信息
@property (nonatomic, strong, readwrite) NSDictionary *screenshotsInfo;
// 删掉屏幕截图后可以节省的空间大小
@property (nonatomic, assign) NSUInteger screenshotsSaveSpace;


// 瘦身图片数组
@property (nonatomic, strong, readwrite) NSMutableArray *thinPhotoArray;
// 瘦身图片信息
@property (nonatomic, strong, readwrite) NSDictionary *thinPhotoInfo;
// 瘦身可以节省的空间大小
@property (nonatomic, assign) NSUInteger thinPhotoSaveSpace;


// 总共可以节省的空间大小
@property (nonatomic, assign, readwrite) double totalSaveSpace;


// 获取图片的过程：当前正在获取第几张图片，总共有多少张
@property (nonatomic, copy) void (^processHandler)(NSInteger current, NSInteger total);
// 完成的回调
@property (nonatomic, copy) void (^completionHandler)(BOOL success, NSError *error);


// PHImageManager的requestImageForAsset所需要的options
@property (nonatomic, strong) PHImageRequestOptions *imageRequestOptions;
// PHImageManager的requestImageDataForAsset所需要的options
@property (nonatomic, strong) PHImageRequestOptions *imageSizeRequestOptions;

@end

@implementation ClearPhotoManager

#pragma mark - 单例
+ (ClearPhotoManager *)shareManager
{
    static ClearPhotoManager *clearPhotoManager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        clearPhotoManager = [[ClearPhotoManager alloc] init];
    });
    return clearPhotoManager;
}

#pragma mark - 相册变换通知

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // 相册变换通知
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
    return self;
}

- (void)dealloc
{
    // 移除相册变换通知
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

// 相册变换时候会调用
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // 筛选出没必要的变动
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetArray];
    if (collectionChanges == nil || self.notificationStatus != PhotoNotificationStatusDefualt)
    {
        return;
    }
    
    // 回到主线程调用相册变动代理方法
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(clearPhotoLibraryDidChange)])
        {
            [self.delegate clearPhotoLibraryDidChange];
        }
    });
}

#pragma mark - 加载照片：获取图片

// 判断相册授权状态
- (void)loadPhotoWithProcess:(void (^)(NSInteger, NSInteger))process completionHandler:(void (^)(BOOL, NSError * _Nonnull))completion
{
    // 清除旧数据
    [self resetTagData];
    
    // 将传入的处理过程的block实现赋值给它
    self.processHandler = process;
    // 将传入的完成过程的block实现赋值给它
    self.completionHandler = completion;
    
    // 获取当前App的相册授权状态
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    // 判断授权状态
    if (authorizationStatus == PHAuthorizationStatusAuthorized)
    {
        // 如果已经授权, 获取图片
        [self getClassificationAsset];
    }
    // 如果没决定, 弹出指示框, 让用户选择
    else if (authorizationStatus == PHAuthorizationStatusNotDetermined)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            // 如果用户选择授权, 则获取图片
            if (status == PHAuthorizationStatusAuthorized)
            {
                // 获取相簿中的PHAsset对象
                [self getClassificationAsset];
            }
        }];
    }
    else
    {
        // 开启权限提示
        [self noticeAlert];
    }
}

// 如果已经授权, 获取相簿中的所有PHAsset对象
- (void)getAllAsset
{
    // 获取所有资源的集合，并按资源的创建时间排序，这样就可以通过和上一张图片判断日期来分组了
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *result = [PHAsset fetchAssetsWithOptions:options];
    self.assetArray = result;
    
    // 最初从第一张图片，数组中位置0的图片开始获取
    [self requestImageWithIndex:0];
}

// 如果已经授权, 获取相簿中的所有PHAsset对象
- (void)getClassificationAsset
{
    // 获取所有资源的集合，并按资源的创建时间排序，这样就可以通过和上一张图片判断日期来分组了
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    
    // 获取所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *streamAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *arrAllAlbums = @[smartAlbums, streamAlbums, userAlbums, syncedAlbums, sharedAlbums];
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (PHFetchResult<PHAssetCollection *> *album in arrAllAlbums) {
        [album enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
            // 获取相册内asset result
            PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (!result.count) return;
            
            [resultArray addObject:result];
        }];
    }
    
    self.assetArray = resultArray[1];
    
    // 最初从第一张图片，数组中位置0的图片开始获取
    [self requestImageWithIndex:0];
}

// 获取图片: index表示正在获取第几张图片，即图片索引位置
- (void)requestImageWithIndex:(NSInteger)index
{
    // 获取图片的过程：当前正在获取第几张图片，总共有多少张
    // 调用Block，传入index和total，计算进度
    if (self.processHandler)
    {
        self.processHandler(index, self.assetArray.count);
    }
    
    // 这个方法会一直+1后递归调用，直到结束条件，即已经获取到最后一张了
    if (index >= self.assetArray.count)
    {
        // 加载完成
        [self loadCompletion];
        // 完成的回调，没有错误，成功了
        self.completionHandler(YES, nil);
        return;
    }
    
    // 筛选本地图片，过滤视频、iCloud图片
    PHAsset *asset = self.assetArray[index];// 根据索引拿到对应位置图片资源
    if (asset.mediaType != PHAssetMediaTypeImage || asset.sourceType != PHAssetSourceTypeUserLibrary)// 不是图片类型或者不是相册
    {
        // 略过，直接获取下一个资源
        [self requestImageWithIndex:index + 1];
        return;
    }
    
    PHImageManager *imageManager = [PHImageManager defaultManager];
    __weak typeof(self) weakSelf = self;

    // 获取压缩大小后的图片，即缩略图
    [imageManager requestImageForAsset:asset targetSize:CGSizeMake(125, 125) contentMode:PHImageContentModeDefault options:self.imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        // 获取原图（原图大小）
        [imageManager requestImageDataAndOrientationForAsset:self.assetArray[index] options:self.imageSizeRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
            
            // 处理图片，分别传入缩略图和原图
            [weakSelf dealImageWithIndex:index exactImage:result originImageData:imageData];
        }];
    }];

}

#pragma mark - 加载照片：处理图片

// 处理图片，获取到需要清理的相似图片和截屏图片，以及可以瘦身的图片
- (void)dealImageWithIndex:(NSInteger)index exactImage:(UIImage *)exactImage originImageData:(NSData *)originImageData
{
    NSLog(@"原图大小为：%.2fM，而缩率图尺寸为：%@",originImageData.length/1024.0/1024.0, NSStringFromCGSize(exactImage.size));
    
    // 将相册中最后一个图片资源和目前的图片资源的日期进行比较，看是否是同一天
    // 资源的集合中按资源的创建时间排序
    PHAsset *asset = self.assetArray[index];
    BOOL isSameDay = [self isSameDay:self.lastAsset.creationDate date2:asset.creationDate];
    
    // 1：该图片是相似图片吗
    if (self.lastAsset && isSameDay)// 上一张图片存在并且是同一天
    {
        // 图片相似度算法
        BOOL isLike = [ImageCompare isImage:self.lastExactImage likeImage:exactImage];
        if (isLike)
        {
            // 更新相似图片数据，传入当前图片资源、原图、缩略图
            [self updateSimilarArrWithAsset:asset exactImage:exactImage originImageData:originImageData];
            // 必须放在下面，影响创建字典
            self.isLastSame = YES;
        }
        else
        {
            // 即使在同一天，但不满足相似度算法，也不是同一张图片
            self.isLastSame = NO;
        }
    }
    else // 上一张图片不存在或者不是同一天则非同张相片
    {
        self.isLastSame = NO;
    }
    
    // 2：该图片是截屏图片吗
    if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoScreenshot)
    {
        // 最后一张图
        NSDictionary *lastDictionary = self.screenshotsArray.lastObject;
        
        // lastDictionary存储的是同一天的截屏图片
        // 如果不是同一天，则将旧的lastDictionary清除，再创建新的lastDictionary，self.screenshotsArray则有多个元素，开启下一行日期显示
        if (lastDictionary && !isSameDay)// index = 3，此时不是同一天，进入
        {
            lastDictionary = nil;
        }
        
        // 更新截屏图片数据
        [self updateScreenShotsWithAsset:asset exactImage:exactImage originImageData:originImageData lastDictionary:lastDictionary];
    }
    
    // 3：该图片是否可以瘦身
    [self dealThinPhotoWithAsset:asset exactImage:exactImage originImageData:originImageData];
    
    // 处理完后变为上一个
    self.lastAsset = asset;
    self.lastExactImage = exactImage;// 缩略图
    self.lastOriginImageData = originImageData;// 原图
    
    // 获取下一张图片
    [self requestImageWithIndex:index + 1];
}

// 更新相似图片数据源
- (void)updateSimilarArrWithAsset:(PHAsset *)asset exactImage:(UIImage *)exactImage originImageData:(NSData *)originImageData
{
    // 相似图片数组中最后一张图片
    NSDictionary *lastDictionary = self.similarArray.lastObject;
    
    // lastDictionary存储的是同一天的相似图片
    // 如果不是同一天或者不相似则isLastSame为NO
    // 此时将旧的lastDictionary清除，再创建新的lastDictionary，self.screenshotsArray则有多个元素，开启下一行日期显示
    if (!self.isLastSame)
    {
        lastDictionary = nil;
    }
    
    // lastDictionary为空则用上一次图片的数据进行创建，存在则直接添加
    // 因为是比较相似，上一次的图片也要在新的日期行显示出来
    if (!lastDictionary)
    {
        // 上一次图片的数据
        NSDictionary *itemDictionary = @{@"asset" : self.lastAsset, @"exactImage" : self.lastExactImage, @"originImageData" : self.lastOriginImageData, @"originImageDataLength" : @(self.lastOriginImageData.length)};
        // 以当前图片资源的创建日期作为key
        NSString *keyString = [self stringWithDate:asset.creationDate];// 2020年07月31日
        // 创建字典，value是只有一个字典元素的可变数组
        // value必须是可变数组，因为itemArray是可变数组，将当前图片信息加入到itemArray后，直接keyString : itemArray来更新lastDictionary
        lastDictionary = @{keyString : @[itemDictionary].mutableCopy};
        
        // 添加到相似数组中
        [self.similarArray addObject:lastDictionary];
    }
    
    // lastDictionary的value是个可变的数组，数组里的元素是字典，最后一个元素是上次新添加进去的字典
    // 将上一次的字典元素放入了itemArray可变数组中
    NSMutableArray *itemArray = lastDictionary.allValues.lastObject;
    
    // 当前图片的信息
    NSDictionary *itemDictionary = @{@"asset" : asset, @"exactImage" : exactImage, @"originImageData" : originImageData, @"originImageDataLength" : @(originImageData.length)};
    // 将当前图片信息加入到itemArray
    [itemArray addObject:itemDictionary];
    
    // lastDictionary的key还是上次的，但是value却更新了，value是个可变数组，数组里的元素是字典，这次多加了一个字典到数组中
    lastDictionary = @{lastDictionary.allKeys.lastObject : itemArray};
    
    // 将相似数组的最后一个元素替换为新的lastDictionary
    [self.similarArray replaceObjectAtIndex:self.similarArray.count - 1 withObject:lastDictionary];
    
    // imageData为当前图片的原图大小，清除相似图片后可节省的内存空间加上其大小
    self.similarSaveSpace = self.similarSaveSpace + originImageData.length;
}

// 更新截屏图片数据
- (void)updateScreenShotsWithAsset:(PHAsset *)asset exactImage:(UIImage *)exactImage originImageData:(NSData *)originImageData lastDictionary:(NSDictionary *)lastDictionary
{
    NSDictionary *itemDictionary = @{ @"asset" : asset, @"exactImage" : exactImage, @"originImageData" : originImageData, @"originImageDataLength" : @(originImageData.length) };
    
    // 不存在则创建
    if (!lastDictionary)
    {
        NSString *keyString = [self stringWithDate:asset.creationDate]; 
        lastDictionary = @{keyString : @[itemDictionary].mutableCopy};// value是只有一个字典元素的可变数组
        [self.screenshotsArray addObject:lastDictionary];// 将该字典加入到截屏图片数据源中
    }
    // 存在则添加
    else
    {
        // lastDictionary的value是个可变的数组，数组里的元素是字典，最后一个元素是上次新添加进去的字典
        // 将上一次的字典元素放入了itemArray可变数组中
        NSMutableArray *itemArray = lastDictionary.allValues.lastObject;
        // 将当前图片信息加入到itemArray
        [itemArray addObject:itemDictionary];
        
        // lastDictionary的key还是上次的，但是value却更新了，value是个可变数组，数组里的元素是字典，这次多加了一个字典到数组中
        lastDictionary = @{lastDictionary.allKeys.lastObject : itemArray};
        
        // 替换lastDictionary
        [self.screenshotsArray replaceObjectAtIndex:self.screenshotsArray.count - 1 withObject:lastDictionary];
    }
    
    // 可节省空间
    self.screenshotsSaveSpace = self.screenshotsSaveSpace + originImageData.length;// 0 + 169135 + ...
}

// 图片瘦身
- (void)dealThinPhotoWithAsset:(PHAsset *)asset exactImage:(UIImage *)exactImage originImageData:(NSData *)originImageData
{
    // 原图大小已经满足大小，无需瘦身
    if (originImageData.length < 1024.0 * 1024.0 * 1.5)
    {
        return;
    }
    
    // 否则将当前需瘦身图片加入到瘦身数组
    NSDictionary *itemDictionary = @{ @"asset" : asset, @"exactImage" : exactImage, @"originImageData" : originImageData, @"originImageDataLength" : @(originImageData.length)};
    [self.thinPhotoArray addObject:itemDictionary];
    
    // 瘦身空间 = 原图大小 - 1024.0 * 1024.0
    self.thinPhotoSaveSpace = self.thinPhotoSaveSpace + (originImageData.length - 1024.0 * 1024.0);
}

#pragma mark - 加载照片：图片加载完成和重置数据

// 加载完成
- (void)loadCompletion
{
    // similarInfo存储了相似图片数量及可以节省的内存空间大小
    self.similarInfo = [self getInfoWithDataArray:self.similarArray saveSpace:self.similarSaveSpace];
    
    // screenshotsInfo存储了屏幕截图数量及可以节省的内存空间大小
    self.screenshotsInfo = [self getInfoWithDataArray:self.screenshotsArray saveSpace:self.screenshotsSaveSpace];
    
    // thinPhotoInfo存储了瘦身图片数量及可以节省的内存空间大小
    self.thinPhotoInfo = @{@"count" : @(self.thinPhotoArray.count), @"saveSpace" : @(self.thinPhotoSaveSpace)};
    
    // 总的可以节省内存的大小
    self.totalSaveSpace = self.similarSaveSpace + self.self.thinPhotoSaveSpace + self.screenshotsSaveSpace;
    
    NSLog(@"删掉相似照片可省 ：%.2fMB", self.similarSaveSpace / 1024.0 / 1024.0);
    NSLog(@"删掉屏幕截图可省 ：%.2fMB", self.screenshotsSaveSpace / 1024.0 / 1024.0);
    NSLog(@"压缩照片可省 ：%.2fMB", self.thinPhotoSaveSpace / 1024.0 / 1024.0);
    
    NSLog(@"图片加载全部完成");
}

// 获取图片数量及可以节省的内存空间大小
- (NSDictionary *)getInfoWithDataArray:(NSArray *)dataArray saveSpace:(NSUInteger)saveSpace
{
    NSUInteger similarCount = 0;
    for (NSDictionary *dictionary in dataArray)// 每个字典代表了一个日期下的相似数组
    {
        // 将最后的字典作为数组的一个元素进行初始化
        NSArray *array = dictionary.allValues;
        similarCount = similarCount + array.count;
    }
    return @{@"count":@(similarCount), @"saveSpace" : @(saveSpace)};
}

// 加载照片之前先清除旧数据
- (void)resetTagData
{
    // 重置相似图片
    self.similarArray = nil;
    self.similarInfo = nil;
    self.similarSaveSpace = 0;
    
    // 重置屏幕截图
    self.screenshotsArray = nil;
    self.screenshotsInfo = nil;
    self.screenshotsSaveSpace = 0;
    
    // 重置瘦身图片
    self.thinPhotoArray = nil;
    self.thinPhotoInfo = nil;
    self.thinPhotoSaveSpace = 0;
    
    // 总共节省的空间
    self.totalSaveSpace = 0;
}

#pragma mark - 加载照片：日期

// 是否为同一天
- (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2
{
    // 有一个日期为空则直接返回
    if (!date1 || !date2)
    {
        return NO;
    }
    
    // 从日历上分别获取date1、date2的年月日
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *dateComponents1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents *dateComponents2 = [calendar components:unitFlags fromDate:date2];
    
    // 比较年月日，均相同则返回YES，否则不是同一天
    return (dateComponents1.day == dateComponents2.day) && (dateComponents1.month == dateComponents2.month) && (dateComponents1.year == dateComponents2.year);
}

// NSDate转NSString
- (NSString *)stringWithDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    return [dateFormatter stringFromDate:date];
}

#pragma mark - 获取原图和删除照片

// 获取原图
+ (void)getOriginImageWithAsset:(PHAsset *)asset completionHandler:(void (^)(UIImage * _Nonnull, NSDictionary * _Nonnull))completion
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // deliveryMode 则用于控制请求的图片质量
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    // resizeMode 属性控制图像的剪裁
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    // 原图
    PHImageManager *imageManager = [PHImageManager defaultManager];
    [imageManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:completion];
}

// 删除照片
+ (void)deleteAssets:(NSArray<PHAsset *> *)assets completionHandler:(void (^)(BOOL, NSError * _Nonnull))completion
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 删除当前图片资源
        [PHAssetChangeRequest deleteAssets:assets];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        // 调用删除后的回调代码块
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success, error);
            });
        }
    }];
}

#pragma mark - 图片压缩

// 压缩照片
+ (void)compressImageWithData:(NSData *)imageData completionHandler:(void (^)(UIImage * _Nonnull, NSUInteger))completion
{
    UIImage *image = [UIImage imageWithData:imageData];
    NSUInteger imageDataLength = imageData.length;
    [self compressImage:image imageDataLength:imageDataLength completionHandler:completion];
}

// 在子线程压缩图片后在主线程显示压缩后的图片
+ (void)compressImage:(UIImage *)image imageDataLength:(NSUInteger)imageDataLength completionHandler:(void (^)(UIImage *compressImage, NSUInteger imageDataLength))completion
{
    // 在子线程压缩
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 压缩照片
        NSDictionary *imageDictionary = [self compressImage:image imageDataLength:imageDataLength];
        
        // 在主线程显示压缩后的图片
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion(imageDictionary[@"image"], [imageDictionary[@"imageDataLength"] unsignedIntegerValue]);
            }
        });
    });
}

// 压缩图片算法，经过图片质量压缩后还没满足要求达到的压缩大小，则再对图片宽高尺寸进行压缩
+ (NSDictionary *)compressImage:(UIImage *)image imageDataLength:(NSUInteger)imageDataLength
{
    NSLog(@"图片压缩前 imageDataLength: %.2fMB, imageSize:%@", imageDataLength/1024.0/1024.0, NSStringFromCGSize(image.size));
    
    // 压缩率
    CGFloat rate = 1024 * 1024.0 / imageDataLength;
    // 数据压缩
    NSData *data = UIImageJPEGRepresentation(image, rate);
    // 压缩后的图片
    UIImage *compressImage = [UIImage imageWithData:data];
    
    NSLog(@"图片压缩后 imageDataLength: %.2fMB, imageSize:%@", data.length / 1024.0 / 1024.0, NSStringFromCGSize(compressImage.size));
    
    if (data.length > 1024 * 1024 * 1.5)// 经过图片质量压缩后还没满足要求达到的压缩大小，则再对图片宽高尺寸进行压缩
    {
        // 按照压缩比率缩小宽高
        CGSize size = CGSizeMake(image.size.width * rate, image.size.height * rate);
        UIImage *compressImageSecond = [self imageWithImage:compressImage scaledToSize:size];
        NSData *dataSecond =  UIImageJPEGRepresentation(compressImageSecond, 1);
        
        NSLog(@"按照压缩比率缩小宽高后 imageDataLength: %.2fMB, imageSize:%@", dataSecond.length / 1024.0 / 1024.0, NSStringFromCGSize(compressImageSecond.size));
        
        if (dataSecond.length > 1024 * 1024 * 1.5)// 还没有达到要求则递归调用自己
        {
            return [self compressImage:compressImageSecond imageDataLength:dataSecond.length];
        }
        else
        {
            // 压缩后的图片
            return @{@"image":compressImageSecond, @"imageDataLength":@(dataSecond.length)};
        }
    }
    else
    {
        // 压缩后的图片
        return @{@"image":compressImage, @"imageDataLength":@(data.length)};
    }
}

// 按照压缩比率缩小宽高
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    return newImage;
}

#pragma mark - 提示

// 开启权限提示
- (void)noticeAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"此功能需要相册授权" message:@"请您在设置系统中打开授权开关" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *left = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *right = [UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 打开设置APP
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }];
    [alert addAction:left];
    [alert addAction:right];
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [vc presentViewController:alert animated:YES completion:nil];
}

// 确定提示框
+ (void)tipWithMessage:(NSString *)str
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [vc presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 懒加载

- (NSMutableArray *)similarArray
{
    if (!_similarArray)
    {
        _similarArray = [NSMutableArray array];
    }
    return _similarArray;
}

- (NSMutableArray *)thinPhotoArray
{
    if (!_thinPhotoArray)
    {
        _thinPhotoArray = [NSMutableArray array];
    }
    return _thinPhotoArray;
}

- (NSMutableArray *)screenshotsArray
{
    if (!_screenshotsArray)
    {
        _screenshotsArray = [NSMutableArray array];
    }
    return _screenshotsArray;
}

- (PHImageRequestOptions *)imageRequestOptions
{
    if (!_imageRequestOptions) {
        _imageRequestOptions = [[PHImageRequestOptions alloc] init];
        // resizeMode 属性控制图像的剪裁
        _imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeNone;// no resize
        // deliveryMode 则用于控制请求的图片质量
        _imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    }
    return _imageRequestOptions;
}

- (PHImageRequestOptions *)imageSizeRequestOptions
{
    if (!_imageSizeRequestOptions) {
        _imageSizeRequestOptions = [[PHImageRequestOptions alloc] init];
        // resizeMode 属性控制图像的剪裁
        _imageSizeRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;// exactly targetSize
        // deliveryMode 则用于控制请求的图片质量
        _imageSizeRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    }
    return _imageSizeRequestOptions;
}




@end



