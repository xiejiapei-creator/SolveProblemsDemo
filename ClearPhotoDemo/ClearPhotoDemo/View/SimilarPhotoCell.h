//
//  SimilarPhotoCell.h
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/31.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoInfoItem.h"

NS_ASSUME_NONNULL_BEGIN

/// 图片+选中按钮
@interface SimilarPhotoCell : UICollectionViewCell

/// 显示Mode的数据
- (void)bindWithModel:(PhotoInfoItem *)model;

@end

NS_ASSUME_NONNULL_END
