//
//  ClearPhotoCell.m
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/31.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "ClearPhotoCell.h"

@implementation ClearPhotoCell

- (void)bindWithMode:(ClearPhotoItem *)item
{
    self.textLabel.text = item.name;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@ 可省 %@", item.detail, item.saveString];
}

@end
