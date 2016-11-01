//
//  ViewController.m
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/1.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import "ViewController.h"
#import "MFCoreTextView.h"

@interface ViewController ()
{
    MFCoreTextView *_richTextView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _richTextView = [[MFCoreTextView alloc] initWithFrame:CGRectMake(50, 50, 200, 200)];
    _richTextView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_richTextView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
