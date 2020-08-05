//
//  RootViewController.m
//
//  Created by 谢佳培 on 2020/7/13.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "RootViewController.h"
#import "CutLongImageViewController.h"
#import "ShowLongImageViewController.h"
#import "ViewController.h"

@interface RootViewController ()

@property (nonatomic, strong) NSArray *vcTitles;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"长图解决方案Demo";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.vcTitles = @[@"使用UITableView", @"使用WKWebView", @"自动释放器Demo"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.vcTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.vcTitles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            CutLongImageViewController *vc = [[CutLongImageViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1:
        {
            ShowLongImageViewController *vc = [[ShowLongImageViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2:
        {
            ViewController *vc = [[ViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}

@end
