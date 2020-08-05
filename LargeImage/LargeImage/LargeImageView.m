//
//  LargeImageView.m
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/29.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "LargeImageView.h"

@interface LargeImageView ()

@property (strong, nonatomic) NSString *imageName;// 要被切片的大内存图
@property (assign, nonatomic) NSInteger tileCount;// 会影响切片数量
@property (strong, nonatomic) UIImage *originImage;// 原始图
@property (assign, nonatomic) CGRect imageRect;// 图片大小
@property (assign, nonatomic) CGFloat imageScale;// 图片缩放比例
@property (assign, nonatomic) NSInteger test;

@end

@implementation LargeImageView

#pragma mark - 创建地图视图

- (id)initWithImageName:(NSString*)imageName andTileCount:(NSInteger)tileCount
{
    self = [super init];
    if(self)
    {
        self.imageName = imageName;
        self.tileCount = tileCount;
        [self createView];
    }
    return self;
}

- (void)createView
{
// 第一部分：缩小
    // 屏幕尺寸
    CGRect bounds = [[UIScreen mainScreen] bounds];// (CGRect) bounds = (origin = (x = 0, y = 0), size = (width = 414, height = 896))
    CGSize screenSize = bounds.size;// (CGSize) screenSize = (width = 414, height = 896)

    // 获取地图原图及其尺寸大小
    NSString *path = [[NSBundle mainBundle] pathForResource:[_imageName stringByDeletingPathExtension] ofType:[_imageName pathExtension]];
    self.originImage = [UIImage imageWithContentsOfFile:path];
    CGSize originImageSize = self.originImage.size;// (CGSize) originImageSize = (width = 7360, height = 4912)
    
    // 如果原图宽度>高度，宽度改为屏幕宽度，同时按照比例缩小高度
    CGSize viewSize = CGSizeZero;
    if (originImageSize.width > originImageSize.height)// YES
    {
        viewSize.width = screenSize.width;// width = 414
        viewSize.height = screenSize.width/originImageSize.width * originImageSize.height;// （414/7360）* 4912 = 276.3
    }
    // 设置地图视图frame为原图按照比例缩小后的尺寸
    self.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    
    
// 第二部分：切片
    // 缩放比例
    // imageRect 等于 原图尺寸大小
    self.imageRect = CGRectMake(0.0f, 0.0f, CGImageGetWidth(self.originImage.CGImage), CGImageGetHeight(self.originImage.CGImage));// _imageRect = (origin = (x = 0, y = 0), size = (width = 7360, height = 4912))
    // imageScale 是按照等比例缩小后的地图和原图的宽度作比得到的缩小系数，相当于比例尺吧
    self.imageScale = self.frame.size.width/self.imageRect.size.width;// 414/7360 = 0.056
    
    // 创建图层，并设置属性信息
    CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
    
    // ceil向上取整 lev = 6
    int lev = ceil(log2(1/self.imageScale)) + 1;
    
    // 从最小视图需要放大多少次，才能达到我们需要的清晰度效果，注意是多少次，一次就是2倍
    // 指的是该图层缓存的放大LOD数目，默认为0，即不会额外缓存放大层次，每进一级会对前一级两倍分辨率进行缓存
    tiledLayer.levelsOfDetailBias = lev;
    
    // 产生模糊的根源是图层的细节层次
    // 缩小视图是，最大可以达到的缩小级数：指的是该图层缓存的放大LOD数目，默认为0，即不会额外缓存放大层次，每进一级会对前一级两倍分辨率进行缓存
    tiledLayer.levelsOfDetail = 1;

    // 代入切片的计算公式，来计算tileSize
    if(self.tileCount > 0)// 16 > 0
    {
        NSInteger tileSizeScale = sqrt(self.tileCount)/2;// sqrt平方根计算 tileSizeScale = 2
        // 用于创建层内容的每个平铺的最大大小，默认为256*256
        // 如果tileSize设置太小就会把每块瓷砖图片展示的很小
        CGSize tileSize = self.bounds.size;// tileSize = (width = 414, height = 276.3)
        tileSize.width /= tileSizeScale;
        tileSize.height /= tileSizeScale;
        tiledLayer.tileSize = tileSize;// tileSize = CGSize (207 138.15)
    }
    NSLog(@"切片宽度:%f，切片高度:%f",(float)tiledLayer.tileSize.width,(float)tiledLayer.tileSize.height);
}

// 会调用到，返回CATiledLayer的class
+ (Class)layerClass
{
    return [CATiledLayer class];
}


#pragma mark - 绘图

// 会反复调用到，直到切片数目绘制完成
-(void)drawRect:(CGRect)rect
{
    // _originImage: {7360, 4912} 原图尺寸
    // (CGFloat) _imageScale = 0.0562 缩放比例尺
    
    // (CGRect) rect = (origin = (x = 207, y = 115), size = (width = 34.5, height = 23))
    // rect代表在手机屏幕上裁剪区域，其x、y会一直变化，但是size不变，有多少个切片数量就变化多少次
    
    // 计算出每张小图的裁切区域映射到原图中的位置和尺寸大小
    CGFloat imageCutX = rect.origin.x / self.imageScale;
    CGFloat imageCutY = rect.origin.y / self.imageScale;
    CGFloat imageCutWidth = rect.size.width / self.imageScale;
    CGFloat imageCutHeight = rect.size.height / self.imageScale;
    
    // (CGRect) imageCutRect = (origin = (x = 3680, y = 2044.4), size = (width = 613.3, height = 408.8))
    // 第一行：x = 3066 x = 3680 x = 4293... y = 2453 不变
    // 第二行：x = 3066 x = 4293... y = 2862 不变
    // 第三行：x = 4293... y = 2044.4不变
    // ...何时结束，取决于有多少个切片
    CGRect imageCutRect = CGRectMake(imageCutX, imageCutY, imageCutWidth, imageCutHeight);
    
    // 截取原图中指定裁剪区域，重绘
    @autoreleasepool
    {
        CGImageRef imageRef = CGImageCreateWithImageInRect(self.originImage.CGImage, imageCutRect);
        UIImage *tileImage = [UIImage imageWithCGImage:imageRef];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIGraphicsPushContext(context);
        [tileImage drawInRect:rect];
        UIGraphicsPopContext();
    }
    
    // 作为测试，看看总共绘制了多少个切片
    static NSInteger drawCount = 1;
    drawCount++;
    // NSLog(@"正在切第%ld片，其rect为：(x:%f, y:%f, width:%f, height:%f )",drawCount,(float)imageCutX,(float)imageCutY,(float)imageCutWidth, (float)imageCutHeight);
}
 

#pragma mark - Setter/Getter


// 会调用到，每次缩放、平移都会重绘，作用是只会绘制屏幕区域内的图片
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    // 更新frame后的缩放系数，即比例尺
    self.imageScale = self.frame.size.width/self.imageRect.size.width;// 414/7360 = 0.0562
    if(self.tileCount > 0)// 16
    {
        CATiledLayer *tileLayer = (CATiledLayer *)self.layer;
        NSInteger tileSizeScale = sqrt(self.tileCount)/2;// 2
        
        // tiledSize的设置主要是影响CATiledLayer的切片数量
        CGSize tileSize = self.bounds.size;// (CGSize) tileSize = (width = 414, height = 276)
        tileSize.width /= tileSizeScale;
        tileSize.height/= tileSizeScale;
        tileLayer.tileSize = tileSize;// (CGSize) tileSize = (width = 207, height = 138)
    }
    
    // 调用drawRect进行重新绘制
    [self setNeedsDisplay];
}


@end
