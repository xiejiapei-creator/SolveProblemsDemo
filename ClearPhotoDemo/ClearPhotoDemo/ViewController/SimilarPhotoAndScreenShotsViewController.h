//
//  SimilarPhotoAndScreenShotsViewController.h
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/8/1.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SimilarPhotoAndScreenShotsViewController : UIViewController

/// 相似图片或者屏幕截图数据源，传入similarArr或者screenshotsArr
@property (nonatomic, strong) NSArray *similarOrScreenshotsArr;

/// 是否是屏幕截图，默认为NO
@property (nonatomic, assign) BOOL isScreenshots;

@end

NS_ASSUME_NONNULL_END
