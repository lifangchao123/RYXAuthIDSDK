//
//  RYXViewController.m
//  RYXAuthIDSDK
//
//  Created by lifangchao123 on 12/03/2019.
//  Copyright (c) 2019 lifangchao123. All rights reserved.
//

#import "RYXViewController.h"
#import "RYXAuthIDSDK/RYXLabel.h"

@interface RYXViewController ()

@end

@implementation RYXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    CGFloat labelX = ([UIScreen mainScreen].bounds.size.width - 200) * 0.5;
    CGFloat labelY = ([UIScreen mainScreen].bounds.size.height - 100) * 0.5;
    RYXLabel *label = [[RYXLabel alloc] initWithFrame:CGRectMake(labelX, labelY, 200, 100)];
    label.text = @"这是一个测试demo";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
