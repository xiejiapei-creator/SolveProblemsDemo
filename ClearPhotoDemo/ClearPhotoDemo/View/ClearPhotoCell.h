//
//  ClearPhotoCell.h
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/31.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClearPhotoItem.h"

NS_ASSUME_NONNULL_BEGIN

/// 选择清理相似、瘦身、裁剪图片
@interface ClearPhotoCell : UITableViewCell

/// 显示Mode的数据
- (void)bindWithMode:(ClearPhotoItem *)item;

@end

NS_ASSUME_NONNULL_END
