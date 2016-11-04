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
    UIScrollView *_contentScrollView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_contentScrollView];
    
    NSMutableArray *datas = [[MFCustomerDiagnosticLogic sharedLogic] diagnosticQuestions];
    MFDiagnosticQuestionDataItem *dataItem = datas[0];
    MFDiagnosticQuestionDataItem *dataItem2 = datas[1];
    MFDiagnosticQuestionDataItem *dataItem3 = datas[2];
    
    CGRect richTextViewFrame = CGRectMake(10,50, CGRectGetWidth(self.view.bounds)-20, 200);
    MFCoreTextView *richTextView1 = [self coreTextView:richTextViewFrame dataItem:dataItem];
    richTextView1.backgroundColor = [UIColor whiteColor];
    [_contentScrollView addSubview:richTextView1];
    
    CGRect richTextViewFrame2 = CGRectMake(10,CGRectGetMaxY(richTextView1.frame) + 10, CGRectGetWidth(self.view.bounds)-20, 200);
    MFCoreTextView *richTextView2 = [self coreTextView:richTextViewFrame2 dataItem:dataItem2];
    richTextView2.backgroundColor = [UIColor whiteColor];
    [_contentScrollView addSubview:richTextView2];
    
    CGRect richTextViewFrame3 = CGRectMake(10,CGRectGetMaxY(richTextView2.frame) + 10, CGRectGetWidth(self.view.bounds)-20, 200);
    MFCoreTextView *richTextView3 = [self coreTextView:richTextViewFrame3 dataItem:dataItem3];
    richTextView3.backgroundColor = [UIColor grayColor];
    [_contentScrollView addSubview:richTextView3];
    
    _contentScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 30 + CGRectGetMaxY(richTextView3.frame));

    [richTextView1 setNeedsDisplay];
    [richTextView2 setNeedsDisplay];
    [richTextView3 setNeedsDisplay];
    
}

-(MFCoreTextView *)coreTextView:(CGRect)frame
                       dataItem:(MFDiagnosticQuestionDataItem *)dataItem
{
    MFCoreTextView *richTextView = [[MFCoreTextView alloc] initWithFrame:frame];
    richTextView.backgroundColor = [UIColor yellowColor];

    MFFrameParserConfig *config = [MFFrameParserConfig new];
    config.width = CGRectGetWidth(frame);
    config.fontSize = 18.0f;
    config.lineSpace = 2.0f;
    
    MFDiagnosticCoreTextData *data = [MFDiagnosticDataParser parseContent:dataItem config:config];
    richTextView.data = data;
    frame.size.height = data.height;
    richTextView.frame = frame;
    
    return richTextView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
