//
//  LargeImageView.h
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/29.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LargeImageView : UIView

// 创建地图图片
-(UIView *)initWithImageName:(NSString*)imageName andTileCount:(NSInteger)tileCount;

@end

NS_ASSUME_NONNULL_END
