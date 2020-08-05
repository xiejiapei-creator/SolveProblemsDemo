//
//  ThinPhotoViewController.m
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/8/1.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "ThinPhotoViewController.h"
#import "ClearPhotoManager.h"
#import "MBProgressHUD.h"
#import "PhotoInfoItem.h"

@interface ThinPhotoViewController ()

// 左边优化前图片视图
@property (nonatomic, weak) UIImageView *leftImageViewView;
// 右边优化后图片视图
@property (nonatomic, weak) UIImageView *rightImageViewView;
// 数据源
@property (nonatomic, strong) NSMutableArray *dataArray;
// 当前位置
@property (nonatomic, assign) NSInteger currentIndex;
// 图片资源数组
@property (nonatomic, strong) NSMutableArray *assetArrary;
// 提示框
@property (nonatomic, weak) MBProgressHUD *hud;

@end

@implementation ThinPhotoViewController

#pragma mark - Life Circle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"照片瘦身";
    self.view.backgroundColor = [UIColor whiteColor];

    // 创建视图
    [self createSubviews];
    [self configData];
}

// 创建视图
- (void)createSubviews
{
    CGFloat distance = 15;
    CGFloat singleViewWidth = (self.view.frame.size.width - 3 * distance) / 2;

    // 左边视图
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, singleViewWidth, 50)];
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.text = @"优化前";
    [self.view addSubview:leftLabel];
    
    UIImageView *leftImageViewView = [[UIImageView alloc] initWithFrame:CGRectMake(distance, 150, singleViewWidth, singleViewWidth * 2)];
    leftImageViewView.contentMode = UIViewContentModeScaleAspectFit;
    leftImageViewView.backgroundColor = [UIColor lightGrayColor];
    self.leftImageViewView = leftImageViewView;
    [self.view addSubview:self.leftImageViewView];

    // 右边对比视图
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(distance * 2 + singleViewWidth, 100, singleViewWidth, 50)];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.text = @"优化后";
    [self.view addSubview:rightLabel];
    
    UIImageView *rightImageViewView = [[UIImageView alloc] initWithFrame:CGRectMake(distance * 2 + singleViewWidth, 150, singleViewWidth, singleViewWidth * 2)];
    rightImageViewView.contentMode = UIViewContentModeScaleAspectFit;
    rightImageViewView.backgroundColor = [UIColor lightGrayColor];
    self.rightImageViewView = rightImageViewView;
    [self.view addSubview:self.rightImageViewView];
    
    // 提示文本
    UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, singleViewWidth * 2 + 150, self.view.frame.size.width, 100)];
    tipLab.text = [NSString stringWithFormat:@"%@ 可省 %@", self.thinPhotoItem.detail, self.thinPhotoItem.saveString];
    tipLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLab];
    
    // 底部优化按钮
    UIButton *optmizeButton = [[UIButton alloc] initWithFrame:CGRectMake(distance, self.view.frame.size.height - 100, self.view.frame.size.width - 2 * distance, 50)];
    [optmizeButton setTitle:@"立即优化" forState:UIControlStateNormal];
    optmizeButton.backgroundColor = [UIColor orangeColor];
    [optmizeButton addTarget:self action:@selector(clickOptmizeButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:optmizeButton];
}

#pragma mark - Data

// 配置数据
- (void)configData
{
    // 存放将传入的info进行格式化后的model
    self.dataArray = [NSMutableArray arrayWithCapacity:self.thinPhotoArray.count];
    for (NSDictionary *dict in self.thinPhotoArray)
    {
        // 初始化Model，传入info
        PhotoInfoItem *item = [[PhotoInfoItem alloc] initWithDict:dict];
        [self.dataArray addObject:item];
    }
    
    // 获取显示在左边的原图，这里显示数组中的第一张图
    PhotoInfoItem *item = self.dataArray.firstObject;
    [ClearPhotoManager getOriginImageWithAsset:item.asset completionHandler:^(UIImage * _Nonnull result, NSDictionary * _Nonnull info) {
        
        // 原图大小
        NSData *data = UIImageJPEGRepresentation(result, 1);
        NSLog(@"JPEG 原图大小 : %.2fMB", data.length/1024.0/1024.0);
        
        // 测试用，可删除。和JPEG 原图大小进行比较
        NSData *PNGData = UIImagePNGRepresentation(result);
        NSLog(@"PNG  原图大小 : %.2fMB", PNGData.length/1024.0/1024.0);
        
        // 左侧显示原图
        self.leftImageViewView.image = result;
    }];
    
    // 获取显示在右边的压缩图
    [ClearPhotoManager compressImageWithData:item.originImageData completionHandler:^(UIImage * _Nonnull compressImage, NSUInteger compresSize) {
        // 压缩后大小
        NSData *compressData = UIImageJPEGRepresentation(compressImage, 1);
        NSLog(@"JPEG 压缩后大小 : %.2fMB", compressData.length/1024.0/1024.0);
        
        // 右侧显示压缩图
        self.rightImageViewView.image = compressImage;
    }];
}

#pragma mark - Events

// 点击优化按钮
- (void)clickOptmizeButton {
    // 相册变更不处理
    [ClearPhotoManager shareManager].notificationStatus = PhotoNotificationStatusClose;
    // 当前位置
    self.currentIndex = 0;
    // 用来存储待删除资源
    self.assetArrary = [NSMutableArray array];
    
    // 提示框
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.label.text = @"压缩中，请稍后";
    hud.mode = MBProgressHUDModeDeterminate;
    hud.removeFromSuperViewOnHide = YES;
    [hud showAnimated:YES];
    self.hud = hud;
    [self.view addSubview:self.hud];
    
    // 从第一张图片进行压缩优化
    [self optmizeImageWithIndex:0];
}

#pragma mark - Private Mrthods

// 通过Index获取对应图片并对其进行优化
- (void)optmizeImageWithIndex:(NSInteger)index
{
    // 更新当前位置
    self.currentIndex = index;
    
    // 显示进度：正在压缩第几张图片 / 图片总数
    self.hud.progress = (CGFloat)index + 1 / self.dataArray.count;
    NSLog(@"正在压缩第%ld张图片，图片总数为：%ld", index+1, self.dataArray.count);
    
    // 压缩结束条件
    if (index >= self.dataArray.count)
    {
        // 压缩完成隐藏提示框
        NSLog(@"恭喜，压缩图片全部顺利完成");
        self.hud.hidden = YES;
        
        // 通知相册变更主动处理
        [ClearPhotoManager shareManager].notificationStatus = PhotoNotificationStatusNeed;
        
        // 从相册资源库中删除原图
        [ClearPhotoManager deleteAssets:self.assetArrary completionHandler:^(BOOL success, NSError * _Nonnull error) {
            
            if (success)
            {
                [ClearPhotoManager tipWithMessage:@"恭喜，压缩图片全部顺利完成，并且已经删除了原图"];
            }
            else
            {
                NSLog(@"未删除原图");
            }
        }];
        return;
    }

    // 取出当前model
    PhotoInfoItem *item = self.dataArray[index];
    [ClearPhotoManager compressImageWithData:item.originImageData completionHandler:^(UIImage * _Nonnull compressImage, NSUInteger imageDataLength) {
        
        // 存储压缩后的图片到"相册"
        UIImageWriteToSavedPhotosAlbum(compressImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
    }];
}

// 成功保存图片到相册中, 必须调用此方法, 否则会报参数越界错误
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error)
    {
        [ClearPhotoManager tipWithMessage:@"当前图片保存到相册失败"];
        NSLog(@"当前图片保存到相册失败");
    }
    else
    {
        // 将当前优化的item的asset加入到待删除资源数组中
        PhotoInfoItem *item = self.dataArray[self.currentIndex];
        [self.assetArrary addObject:item.asset];
    }
    
    // +1 后递归调用优化图片方法
    [self optmizeImageWithIndex:self.currentIndex + 1];
}

@end
