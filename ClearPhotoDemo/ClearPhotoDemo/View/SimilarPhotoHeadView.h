//
//  SimilarPhotoHeadView.h
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/31.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 日期
@interface SimilarPhotoHeadView : UICollectionReusableView

/// 显示传入的字典中的数据
- (void)bindWithModel:(NSDictionary *)model;

@end

NS_ASSUME_NONNULL_END
