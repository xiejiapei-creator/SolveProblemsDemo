//
//  PhotoInfoItem.m
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/31.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "PhotoInfoItem.h"

@implementation PhotoInfoItem

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.asset = dict[@"asset"];
        self.exactImage = dict[@"exactImage"];
        self.originImageData = dict[@"originImageData"];
        self.originImageDataLength = [dict[@"originImageDataLength"] unsignedIntegerValue];
    }
    return self;
}

@end
