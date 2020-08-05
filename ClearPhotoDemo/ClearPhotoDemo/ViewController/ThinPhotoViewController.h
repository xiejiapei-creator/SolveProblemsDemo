//
//  ThinPhotoViewController.h
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/8/1.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClearPhotoItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThinPhotoViewController : UIViewController

/// 数据源
@property (nonatomic, strong) NSArray *thinPhotoArray;
/// Model
@property (nonatomic, strong) ClearPhotoItem *thinPhotoItem;

@end

NS_ASSUME_NONNULL_END
