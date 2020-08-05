//
//  SimilarPhotoHeadView.m
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/31.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "SimilarPhotoHeadView.h"

@interface SimilarPhotoHeadView()

@property (nonatomic, weak) UILabel *timeLabel;

@end

@implementation SimilarPhotoHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, frame.size.width * 0.5, frame.size.height)];
        self.timeLabel = timeLabel;
        [self addSubview:self.timeLabel];
        
    }
    return self;
}

- (void)bindWithModel:(NSDictionary *)model
{
    self.timeLabel.text = model.allKeys.lastObject;
}

@end
