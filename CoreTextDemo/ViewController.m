//
//  ViewController.m
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/1.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import "ViewController.h"
#import "MFCoreTextView.h"
#import "MFCustomerDiagnosticLogic.h"
#import "MFFrameParserConfig.h"
#import "MFDiagnosticDataParser.h"

@interface ViewController ()
{
    MFCoreTextView *_richTextView;
    MFCoreTextView *_richTextView2;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _richTextView = [[MFCoreTextView alloc] initWithFrame:CGRectMake(10, 50, CGRectGetWidth(self.view.bounds)-20, 200)];
    _richTextView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_richTextView];
    
    NSMutableArray *datas = [[MFCustomerDiagnosticLogic sharedLogic] diagnosticQuestions];
    MFDiagnosticQuestionDataItem *dataItem = datas[1];
    
    MFFrameParserConfig *config = [[MFFrameParserConfig alloc] init];
    config.width = CGRectGetWidth(_richTextView.bounds);
    config.fontSize = 16.0f;
    config.lineSpace = 2.0f;
    
    MFDiagnosticCoreTextData *data = [MFDiagnosticDataParser parseContent:dataItem config:config];
    _richTextView.data = data;
    _richTextView.frame = CGRectMake(_richTextView.frame.origin.x, _richTextView.frame.origin.y, _richTextView.frame.size.width, data.height);
    [_richTextView setNeedsDisplay];
    
    
    //_richTextView2
    MFDiagnosticQuestionDataItem *dataItem2 = datas[1];
    _richTextView2 = [[MFCoreTextView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_richTextView.frame) + 10, CGRectGetWidth(self.view.bounds)-20, 200)];
    _richTextView2.backgroundColor = [UIColor yellowColor];
//    [self.view addSubview:_richTextView2];
    
    config.width = CGRectGetWidth(_richTextView2.bounds);
    
//    MFDiagnosticCoreTextData *data2 = [MFDiagnosticDataParser parseContent:dataItem2 config:config];
//    _richTextView2.data = data2;
//    _richTextView2.frame = CGRectMake(_richTextView2.frame.origin.x, _richTextView2.frame.origin.y, _richTextView2.frame.size.width, data2.height);
//    [_richTextView2 setNeedsDisplay];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
