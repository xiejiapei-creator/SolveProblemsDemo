//
//  ClearPhotoItem.m
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/31.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "ClearPhotoItem.h"

@implementation ClearPhotoItem

- (instancetype)initWithType:(ClearPhotoType)type dataDict:(NSDictionary *)dict
{
    self = [self init];
    if (self)
    {
        self.type = type;
        self.count = [dict[@"count"] integerValue];

        if (type == ClearPhotoTypeSimilar)
        {
            self.name = @"相似照片处理";
            self.detail = [NSString stringWithFormat:@"相似/连拍照片 %ld 张", [dict[@"count"] integerValue]];
        }
        else if (type == ClearPhotoTypeScreenshots)
        {
            self.name = @"截屏照片清理";
            self.detail = [NSString stringWithFormat:@"可清理照片 %ld 张", [dict[@"count"] integerValue]];
        }
        else if (type == ClearPhotoTypeThinPhoto)
        {
            self.name = @"照片瘦身";
            self.detail = [NSString stringWithFormat:@"可优化照片 %ld 张", [dict[@"count"] integerValue]];
        }
        
        self.saveString = [NSString stringWithFormat:@"%.2fMB", [dict[@"saveSpace"] unsignedIntegerValue]/1024.0/1024.0];
    }
    return self;
}

@end
