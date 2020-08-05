//
//  ClearPhotoViewController.m
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/31.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "ClearPhotoViewController.h"
#import "ClearPhotoCell.h"
#import "ClearPhotoItem.h"
#import "ClearPhotoManager.h"
#import "MBProgressHUD.h"

#import "SimilarPhotoAndScreenShotsViewController.h"
#import "ThinPhotoViewController.h"

@interface ClearPhotoViewController ()<UITableViewDelegate, UITableViewDataSource, ClearPhotoManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;// 数据源
@property (nonatomic, strong) ClearPhotoManager *clearPhotoManager;// 清理照片的Manager
@property (nonatomic, weak) MBProgressHUD *hud;// 提示框

@end

@implementation ClearPhotoViewController

#pragma mark - Life Circle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"照片清理";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 加载照片数据源
    [self loadPhotoData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 相册变更主动处理
    if (self.clearPhotoManager.notificationStatus == PhotoNotificationStatusNeed)
    {
        // 加载照片数据源
        [self loadPhotoData];
        // 重置为相册变更默认处理
        self.clearPhotoManager.notificationStatus = PhotoNotificationStatusDefualt;
    }
}

#pragma mark - Data

// 加载照片数据源
- (void)loadPhotoData
{
    // 已经存在则直接返回
    if (self.hud)
    {
        return;
    }
    
    // 否则创建新的提示框
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.label.text = @"扫描照片中";
    // A round, pie-chart like, progress view.
    hud.mode = MBProgressHUDModeDeterminate;
    // 提示框隐藏后，将提示框从父视图中移除
    hud.removeFromSuperViewOnHide = YES;
    // 显示提示框
    [hud showAnimated:YES];
    [self.view addSubview:hud];
    
    // 加载照片数据源
    __weak typeof(self) weakSelf = self;
    [self.clearPhotoManager loadPhotoWithProcess:^(NSInteger current, NSInteger total) {
        // 实现进度条block，计算进度
        hud.progress = (CGFloat)current / total;
    } completionHandler:^(BOOL success, NSError * _Nonnull error) {
        // 隐藏提示框
        [hud hideAnimated:YES];
        weakSelf.hud = nil;
        
        // 将拿到的数据配置到清理相似照片Model，传入similarInfo
        ClearPhotoItem *similarItem = [[ClearPhotoItem alloc] initWithType:ClearPhotoTypeSimilar dataDict:weakSelf.clearPhotoManager.similarInfo];
        
        // 将拿到的数据配置到清理相似照片Model，传入similarInfo
        ClearPhotoItem *screenshotsItem = [[ClearPhotoItem alloc] initWithType:ClearPhotoTypeScreenshots dataDict:weakSelf.clearPhotoManager.screenshotsInfo];
        
        // 将拿到的数据配置到照片瘦身Model，传入thinPhotoInfo
        ClearPhotoItem *thinItem = [[ClearPhotoItem alloc] initWithType:ClearPhotoTypeThinPhoto dataDict:weakSelf.clearPhotoManager.thinPhotoInfo];
        
        // 数据源
        weakSelf.dataArr = @[similarItem, screenshotsItem, thinItem];
        
        // 拿到数据后，创建表头视图，显示总共可以节约的空间
        [weakSelf createHeadView];
    }];
}

// 创建表头视图，显示总共可以节约的空间
- (void)createHeadView
{
    UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    headLabel.text = [NSString stringWithFormat:@"优化后可节约空间 %.2fMB", self.clearPhotoManager.totalSaveSpace / 1024.0/1024.0];
    headLabel.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableHeaderView = headLabel;
    [self.tableView reloadData];
}

#pragma mark - ClearPhotoManagerDelegate

// 相册变动代理方法
- (void)clearPhotoLibraryDidChange
{
    // 加载照片数据源
    [self loadPhotoData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClearPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClearPhotoCell"];
    if (cell == nil)
    {
        cell = [[ClearPhotoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ClearPhotoCell"];
    }
    
    // cell显示model中的数据
    ClearPhotoItem *item = self.dataArr[indexPath.row];
    [cell bindWithMode:item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ClearPhotoItem *item = self.dataArr[indexPath.row];
    // 可处理图片的数量为0，则不能选中进入处理页面
    if (!item.count)
    {
        return;
    }
    
    switch (item.type)
    {
        case ClearPhotoTypeSimilar:
        {
            SimilarPhotoAndScreenShotsViewController *vc = [SimilarPhotoAndScreenShotsViewController new];
            vc.similarOrScreenshotsArr = self.clearPhotoManager.similarArray;
            vc.isScreenshots = NO;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case ClearPhotoTypeThinPhoto:
        {
            ThinPhotoViewController *vc = [ThinPhotoViewController new];
            vc.thinPhotoArray = self.clearPhotoManager.thinPhotoArray;
            vc.thinPhotoItem = item;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case ClearPhotoTypeScreenshots:
        {
            SimilarPhotoAndScreenShotsViewController *vc = [SimilarPhotoAndScreenShotsViewController new];
            vc.similarOrScreenshotsArr = self.clearPhotoManager.screenshotsArray;
            vc.isScreenshots = YES;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Getter

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 60;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (ClearPhotoManager *)clearPhotoManager
{
    if (!_clearPhotoManager)
    {
        _clearPhotoManager = [ClearPhotoManager shareManager];
        _clearPhotoManager.delegate = self;
    }
    return _clearPhotoManager;
}

@end
