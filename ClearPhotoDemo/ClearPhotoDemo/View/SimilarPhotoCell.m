//
//  SimilarPhotoCell.m
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/31.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "SimilarPhotoCell.h"

@interface SimilarPhotoCell ()

/// 图标
@property (nonatomic, weak) UIImageView *iconView;
/// 选择按钮
@property (nonatomic, weak) UIButton *selectButton;
/// Model
@property (nonatomic, strong) PhotoInfoItem *item;

@end

@implementation SimilarPhotoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupUIWithFrame:frame];
    }
    return self;
}

- (void)setupUIWithFrame:(CGRect)frame
{
    // 显示图片
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:self.bounds];
    iconView.contentMode = UIViewContentModeScaleAspectFill;
    iconView.clipsToBounds = YES;
    self.iconView = iconView;
    [self addSubview:self.iconView];
    
    // 选中按钮
    CGFloat selectWH = frame.size.width * 0.3;
    CGFloat selectX = frame.size.width - selectWH;
    UIButton *selectButton = [[UIButton alloc] initWithFrame:CGRectMake(selectX, 0, selectWH, selectWH)];
    [selectButton setImage:[UIImage imageNamed:@"choose_unseleced"] forState:UIControlStateNormal];
    [selectButton setImage:[UIImage imageNamed:@"choose_selected"] forState:UIControlStateSelected];
    [selectButton addTarget:self action:@selector(clickSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.selectButton = selectButton;
    [self addSubview:self.selectButton];
}

// 点击切换选中状态
- (void)clickSelectBtn:(UIButton *)button
{
    button.selected = !button.selected;
    self.item.isSelected = button.selected;// 更新本地数据源的选中状态
}

// 显示Mode的数据
- (void)bindWithModel:(PhotoInfoItem *)model
{
    self.item = model;
    
    self.iconView.image = model.exactImage;
    self.selectButton.selected = model.isSelected;
}

@end
