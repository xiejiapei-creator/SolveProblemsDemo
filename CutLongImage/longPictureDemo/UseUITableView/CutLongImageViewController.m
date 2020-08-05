//
//  CutLongImageViewController.m
//  longPictureDemo
//
//  Created by 谢佳培 on 2020/7/13.
//  Copyright © 2020 谢佳培. All rights reserved.
//

#import "CutLongImageViewController.h"
#import "CutLongImageTableViewCell.h"
#import <Masonry.h>

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define RowHeight 50

@interface CutLongImageViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CutLongImageViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self cutLongImage];
    [self createSubViews];
    [self createSubViewsConstraints];
}

// 添加子视图
- (void)createSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // 建表
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.bounces = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;//不显示右侧滑块
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//去掉分割线
    self.tableView.sectionHeaderHeight = 0.1;//表头表尾不留白
    self.tableView.sectionFooterHeight = 0.1;
    self.tableView.backgroundColor = [UIColor whiteColor];
    // 不要自动调整
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:self.tableView];
}

// 添加约束
- (void)createSubViewsConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏状态栏
    [UIApplication sharedApplication].statusBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // 恢复状态栏
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)dealloc {
    NSLog(@"%@ - dealloc", NSStringFromClass([self class]));
}

#pragma mark - UITableViewDataSource

//节数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getNewImages].count;
}

// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return RowHeight;
}

// 去掉留白部分
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;//设置为0不起作用
}

//设置每行对应的cell（展示的内容）
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CutLongImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[CutLongImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *images = [self getNewImages];
    cell.cutImageView.image = images[indexPath.row];
    return cell;
}

#pragma mark - Private Methods

// 分割图片保存到沙盒
- (void)cutLongImage {
    // 计算小图个数
    UIImage *longImage = [self getLongImage];
    CGFloat longImageWidth = [self getLongImageSize].width;
    CGFloat longImageHeight = [self getLongImageSize].height;
    int count = longImageHeight / RowHeight + 1;
    
    // 直接存储在沙盒中
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [path stringByAppendingPathComponent:@"newImages.plist"];
    
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionary];
    // 长图裁剪成一张张小图并保存到沙盒
    for (int i = 0; i < count; i++) {
        
        // 裁剪区域：每张小图的X坐标始终为0，Y坐标从0、50、100...变化，防止丢失或留白使用长图本身宽度，按照行高来作为小图高度
        CGRect cropRect = CGRectMake(0, RowHeight * i, longImageWidth, RowHeight);
        // 获取小图片
        CGImageRef smallImageRef = CGImageCreateWithImageInRect([longImage CGImage], cropRect);
        // 将图片转为UIImage
        UIImage *newImage = [UIImage imageWithCGImage:smallImageRef];
        // 释放
        CGImageRelease(smallImageRef);
        
        
        if (newImage) {
            // 在本地资源的情况下，优先使用 PNG格式文件，如果资源来源于网络，最好采用JPEG 格式文件
            NSData *imageData = UIImagePNGRepresentation(newImage);
            
            // 通过字典的方式存储到沙盒，注意到value不能直接使用UIImage，需要转化为NSData，否则无法保存
            NSString *key = [NSString stringWithFormat:@"newImage%d",i+1];
            [plistDict setObject:imageData forKey:key];
        }
    }
    // 其中atomically表示是否需要先写入一个辅助文件，再把辅助文件拷贝到目标文件地址。
    // 这是更安全的写入文件方法，一般都写YES。
    [plistDict writeToFile:filePath atomically:YES];
}

// 从沙盒中取出图片数组
- (NSArray *)getNewImages {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [path stringByAppendingPathComponent:@"newImages.plist"];
    NSDictionary *plistDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    CGFloat longImageHeight = [self getLongImageSize].height;
    int count = longImageHeight / RowHeight + 1;
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithFormat:@"newImage%d",i+1];
        NSData *newImageData = [plistDict objectForKey:key];
        UIImage *newImage = [UIImage imageWithData:newImageData];
        if (newImage) {
            [images addObject:newImage];
        }
    }
    return images;
}

// 获取长图
- (UIImage *)getLongImage {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"longPicture" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}

// 获取长图的尺寸
- (CGSize)getLongImageSize {
    UIImage *image = [self getLongImage];
    return image.size;
}

@end

