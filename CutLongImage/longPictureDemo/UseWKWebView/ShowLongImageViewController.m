//
//  ShowLongImageViewController.m
//  longPictureDemo
//
//  Created by 谢佳培 on 2020/7/14.
//  Copyright © 2020 谢佳培. All rights reserved.
//

#import "ShowLongImageViewController.h"
#import <WebKit/WebKit.h>

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ShowLongImageViewController ()

@property(nonatomic, strong) WKWebView *webView;// 用于直接显示长图

@end

@implementation ShowLongImageViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    // 使用 WKWebView 加载 HTML 代码
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    NSString *imgHtml = [self htmlForJPGImage:[self getLongImage]];
    [self.webView loadHTMLString:imgHtml baseURL:nil];
    
    [self.view addSubview:self.webView];
}

#pragma mark - Private Methods

// 获取长图
- (UIImage *)getLongImage {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"longPicture" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}

// 将 image 包装为 HTML 代码
- (NSString *)htmlForJPGImage:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image,1.f);
    // 图片编码->通过字符串接收，每64个字符插入\r或\n
    NSString *imageBase64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return [NSString stringWithFormat:@"<html><body><div align=center><img src='data:image/jpg;base64,%@'/></div></body></html>",imageBase64];
}

@end
