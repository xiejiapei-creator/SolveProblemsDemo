//
//  SimilarPhotoAndScreenShotsViewController.m
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/8/1.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "SimilarPhotoAndScreenShotsViewController.h"
#import "PhotoInfoItem.h"
#import "ClearPhotoManager.h"
#import "SimilarPhotoCell.h"
#import "SimilarPhotoHeadView.h"

@interface SimilarPhotoAndScreenShotsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SimilarPhotoAndScreenShotsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.isScreenshots)
    {
        self.title = @"删除截屏图片";
    }
    else
    {
        self.title = @"清理相似照片";
    }
    
    // 创建底部删除按钮
    [self createBottomView];
    // 用拿到的数据配置Model
    [self configData];
}

// 创建底部删除按钮
- (void)createBottomView
{
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 50)];
    [deleteButton setTitle:self.isScreenshots ? @"删除屏幕截图" : @"删除相似照片" forState:UIControlStateNormal];
    deleteButton.backgroundColor = [UIColor redColor];
    [deleteButton addTarget:self action:@selector(clickDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteButton];
}

// 用拿到的数据配置Model
- (void)configData
{
    [self.dataArray removeAllObjects];
    
    for (NSDictionary *dictionary in self.similarOrScreenshotsArr)
    {
        NSString *keyString = dictionary.allKeys.lastObject;
        NSArray *valueArray = dictionary.allValues.lastObject;
        // 存放配置完成后的Model
        NSMutableArray *mutableValueArray = [NSMutableArray arrayWithCapacity:valueArray.count];
        
        // 用拿到的数据配置Model
        for (int i = 0; i < valueArray.count; i++)
        {
            NSDictionary *infoDiction = valueArray[i];
            PhotoInfoItem *item = [[PhotoInfoItem alloc] initWithDict:infoDiction];
            [mutableValueArray addObject:item];
        }
        
        // 更新数据源为配置后的Model
        NSDictionary *temDictionary = @{keyString : mutableValueArray};
        [self.dataArray addObject:temDictionary];
    }
    
    [self.collectionView reloadData];
}

#pragma mark - Event

// 点击删除按钮
- (void)clickDeleteButton
{
    // 选中的图片数组
    NSMutableArray *assetArray = [NSMutableArray array];
    // 临时的数据源，最后用来赋值给self.dataArray
    NSMutableArray *tempDataArray = [NSMutableArray array];
    
    for (NSDictionary *dictionary in self.dataArray)// 每个日期的dictionary
    {
        // 未选中的图片数组
        NSMutableArray *mutableArray = [NSMutableArray array];
        
        // 配置后的Model
        NSArray *modelArray = dictionary.allValues.lastObject;
        for (PhotoInfoItem *item in modelArray)
        {
            if (item.isSelected)// 删除选中
            {
                [assetArray addObject:item.asset];
            }
            else// 保留未选中
            {
                [mutableArray addObject:item];
            }
        }
        
        // 清理相似照片：mutableArray的数量至少在2张照片以上
        // 清理屏幕截图：mutableArray有照片即可
        if ( (self.isScreenshots && mutableArray.count > 0) || (!self.isScreenshots && mutableArray.count > 1) )
        {
            // 更新删除选中后保留下来的未选中的数据源
            NSDictionary *tempDictionary = @{dictionary.allKeys.lastObject : mutableArray};
            [tempDataArray addObject:tempDictionary];
        }
    }
    
    // 要删除的选中资源数量大于0
    if (assetArray.count)
    {
        // 相册变更不处理
        [ClearPhotoManager shareManager].notificationStatus = PhotoNotificationStatusClose;
        // 删除选中资源
        [ClearPhotoManager deleteAssets:assetArray completionHandler:^(BOOL success, NSError * _Nonnull error) {
            // 实现删除成功的block
            if (success)
            {
                // 更新删除选中后保留下来的未选中的数据源
                self.dataArray = tempDataArray;
                [self.collectionView reloadData];
                
                // 相册变更主动处理
                [ClearPhotoManager tipWithMessage:@"删除成功"];
                [ClearPhotoManager shareManager].notificationStatus = PhotoNotificationStatusNeed;
            }
        }];
    }
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDictionary *dictionary = self.dataArray[section];
    NSArray *modelArray = dictionary.allValues.lastObject;
    return modelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimilarPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SimilarPhotoCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor yellowColor];
    
    // 显示Mode的数据
    NSDictionary *dictionary = self.dataArray[indexPath.section];
    NSArray *modelArray = dictionary.allValues.lastObject;
    [cell bindWithModel:modelArray[indexPath.row]];
    
    return cell;
}

// 显示节头时间视图
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader)
    {
        SimilarPhotoHeadView *headerView =  [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SimilarPhotoHeadView" forIndexPath:indexPath];
        
        // 显示传入的字典中的数据
        NSDictionary *dictionary = self.dataArray[indexPath.section];
        [headerView bindWithModel:dictionary];
        return headerView;
    }
    
    return nil;
}

// 设置段头view大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 40);
}


#pragma mark - Getter

- (NSMutableArray *)dataArray
{
    if (!_dataArray)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        // 布局
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        CGFloat itemCount = 4;
        CGFloat distance = 8;
        CGFloat itemWH = (self.view.frame.size.width - distance * (itemCount + 1)) / itemCount - 1;
        layout.itemSize = CGSizeMake(itemWH, itemWH);
        layout.sectionInset = UIEdgeInsetsMake(distance, distance, distance, distance);
        layout.minimumLineSpacing = distance;
        layout.minimumInteritemSpacing = distance;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size .height - 100)
                                             collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[SimilarPhotoCell class]
            forCellWithReuseIdentifier:@"SimilarPhotoCell"];
        [_collectionView registerClass:[SimilarPhotoHeadView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"SimilarPhotoHeadView"];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

@end
