//
//  CutLongImageTableViewCell.m
//  longPictureDemo
//
//  Created by 谢佳培 on 2020/7/14.
//  Copyright © 2020 谢佳培. All rights reserved.
//
#import "CutLongImageTableViewCell.h"
#import <Masonry/Masonry.h>

@interface CutLongImageTableViewCell ()

@property (nonatomic, strong, readwrite) UIImageView *cutImageView;

@end

@implementation CutLongImageTableViewCell

#pragma mark - Life cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createSubViews];
        [self createSubViewsConstraints];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)dealloc {
    NSLog(@"%@ - dealloc", NSStringFromClass([self class]));
}

#pragma mark - Private Methods

// 添加子视图
- (void)createSubViews {
    [self.contentView addSubview:self.cutImageView];
}

// 添加约束
- (void)createSubViewsConstraints {
    [self.cutImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

#pragma mark - Getters and Setters

- (UIImageView *)cutImageView {
    if (!_cutImageView) {
        _cutImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        // 设置imageView的绘制模式
        _cutImageView.contentMode = UIViewContentModeScaleToFill;
        _cutImageView.backgroundColor = [UIColor blueColor];
    }
    return _cutImageView;
}

@end

