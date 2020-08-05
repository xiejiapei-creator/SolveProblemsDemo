//
//  ViewController.m
//  合并两个有序链表
//
//  Created by 谢佳培 on 2020/7/29.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "ViewController.h"
#import "LargeImageView.h"

@interface ViewController ()

@property (strong, nonatomic) UIButton *button0;
@property (strong, nonatomic) UIButton *button4;
@property (strong, nonatomic) UIButton *button16;
@property (strong, nonatomic) UIButton *button36;
@property (strong, nonatomic) UIButton *button64;
@property (strong, nonatomic) UIButton *button100;

@property (strong, nonatomic) LargeImageView *largeImageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createSubviews];
    
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *path = [[NSBundle mainBundle] pathForResource:[@"map.jpg" stringByDeletingPathExtension] ofType:[@"map.jpg" pathExtension]];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
            imageView.frame = self.view.frame;
            
            [self.view addSubview:imageView];
        });
    });
     */
}

#pragma mark - 创建视图

- (void)createSubviews
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"重新选择" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonAction:)];
    
    self.button0 = [self createButton:100 title:@"默认" andAction:@selector(buttonAction:) andtileCount:0];
    self.button4 = [self createButton:220 title:@"tileCount = 4" andAction:@selector(buttonAction:) andtileCount:4];
    self.button16 = [self createButton:340 title:@"tileCount = 16" andAction:@selector(buttonAction:) andtileCount:16];
    self.button36 = [self createButton:460 title:@"tileCount = 36" andAction:@selector(buttonAction:) andtileCount:36];
    self.button64 = [self createButton:580 title:@"tileCount = 64" andAction:@selector(buttonAction:) andtileCount:64];
    self.button100 = [self createButton:700 title:@"tileCount = 100" andAction:@selector(buttonAction:) andtileCount:100];
    [self.view addSubview:self.button0];
    [self.view addSubview:self.button4];
    [self.view addSubview:self.button16];
    [self.view addSubview:self.button36];
    [self.view addSubview:self.button64];
    [self.view addSubview:self.button100];
}

- (UIButton *)createButton:(CGFloat)y title:(NSString*)title andAction:(SEL)action andtileCount:(NSInteger)tileCount
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(150, y, 150, 100)];
    button.tag = tileCount;// 根据tag可以获取到tileCount的值
    button.backgroundColor = [UIColor blackColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Events

// 按钮点击的事件
- (void)buttonAction:(UIButton *)button
{
    // 移除按钮
    [self.button0 removeFromSuperview];
    [self.button4 removeFromSuperview];
    [self.button16 removeFromSuperview];
    [self.button36 removeFromSuperview];
    [self.button64 removeFromSuperview];
    [self.button100 removeFromSuperview];
    
    // 根据tag可以获取到tileCount的值
    NSInteger tileCount = button.tag;
    // 创建地图图片
    self.largeImageView = [[LargeImageView alloc] initWithImageName:@"map.jpg" andTileCount:tileCount];// frame = (0 309.85; 414 276.3) layer = <CATiledLayer>
    // 移动到中心位置
    self.largeImageView.center = self.view.center;// frame = (0 309.85; 414 276.3) layer = <CATiledLayer>
    // 显示地图图片
    [self.view addSubview:self.largeImageView];
    
    // 缩放手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureAction:)];
    [self.view addGestureRecognizer:pinch];
    
    // 平移手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    [self.view addGestureRecognizer:pan];
}

// 重新选择tileCount
-(void)clearButtonAction:(UIButton *)button
{
    [self.largeImageView removeFromSuperview];
    self.largeImageView = nil;
    
    [self.view addSubview:self.button0];
    [self.view addSubview:self.button4];
    [self.view addSubview:self.button16];
    [self.view addSubview:self.button36];
    [self.view addSubview:self.button64];
    [self.view addSubview:self.button100];
}

// 平移手势
static CGPoint originCenter;
-(void)panGestureAction:(UIPanGestureRecognizer*)gesture
{
    // 拖拽的距离(距离是一个累加)
    CGPoint trans = [gesture translationInView:self.view];
    NSLog(@"拖拽的距离(距离是一个累加): %@",NSStringFromCGPoint(trans));
    
    // 设置图片移动，center会平移过程中会一直变化
    CGPoint center = self.largeImageView.center;
    center.x += trans.x;
    center.y += trans.y;
    self.largeImageView.center = center;
    NSLog(@"图片移动后：%@",NSStringFromCGRect(self.largeImageView.frame));
    
    // 清除累加的距离，否则拖动的距离会在上次拖动数值基础上增加，造成视图移动飞快
    [gesture setTranslation:CGPointZero inView:self.view];
    
    // largeImageView的frame发生了改变，会调用setFrame方法进行重绘
    if (gesture.state == UIGestureRecognizerStateBegan)// 平移开始时
    {
        // 保存最初出发点
        originCenter = self.largeImageView.center;
    }
    else if(gesture.state == UIGestureRecognizerStateEnded)// 平移结束时
    {
        // 移动差距 = 最终结束点 - 最初出发点
        CGPoint move = CGPointMake(center.x - originCenter.x, center.y - originCenter.y);
        // 重新移动到最初出发点
        self.largeImageView.center = originCenter;
        // 变化最初出发点的frame，改变x,y为最终位置
        CGRect frame = self.largeImageView.frame;
        frame.origin.x += move.x;
        frame.origin.y += move.y;
        // largeImageView的frame发生了改变，会调用setFrame方法进行重绘
        self.largeImageView.frame = frame;
    }
}

// 缩放手势
-(void)pinchGestureAction:(UIPinchGestureRecognizer*)gesture
{
    self.largeImageView.transform = CGAffineTransformScale(self.largeImageView.transform, gesture.scale, gesture.scale);
    // frame在缩放时候一直在变化
    NSLog(@"缩放手势: %@",NSStringFromCGRect(self.largeImageView.frame));
    
    // 清除累加的距离，否则会在上次缩放数值基础上增加，造成视图缩放飞快
    gesture.scale = 1;
    
    if(gesture.state == UIGestureRecognizerStateEnded)// 缩放结束时
    {
        // 最终frame的值
        CGRect newFrame = self.largeImageView.frame;
        // 重置：当我们改变过一个view.transform属性或者view.layer.transform的时候需要恢复默认状态的话
        self.largeImageView.transform = CGAffineTransformIdentity;
        // 更新为最终frame的值，注意只有这里是我们手动调用了frame的Setter方法才会触发重新绘制
        self.largeImageView.frame = newFrame;
    }
}


@end
