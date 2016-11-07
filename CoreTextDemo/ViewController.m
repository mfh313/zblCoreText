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
#import "ParagraphStyleTextView.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIScrollView *_contentScrollView;
    
    UITableView *_contentTableView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_contentScrollView];
    
    NSMutableArray *datas = [[MFCustomerDiagnosticLogic sharedLogic] diagnosticQuestions];
    MFDiagnosticQuestionDataItem *dataItem = datas[2];
    MFDiagnosticQuestionDataItem *dataItem2 = datas[7];
    MFDiagnosticQuestionDataItem *dataItem3 = datas[8];
    
    
    CGRect firstViewFrame = CGRectMake(10, 50, CGRectGetWidth(self.view.bounds)-20, 300);
    ParagraphStyleTextView *testView = [[ParagraphStyleTextView alloc] initWithFrame:firstViewFrame];
    testView.backgroundColor = [UIColor lightGrayColor];
//    [_contentScrollView addSubview:testView];
    
    CGRect richTextViewFrame = CGRectMake(10,CGRectGetMaxY(testView.frame) + 20, CGRectGetWidth(self.view.bounds)-20, 200);
    
    richTextViewFrame = firstViewFrame;
    
    MFCoreTextView *richTextView1 = [self coreTextView:richTextViewFrame dataItem:dataItem];
    richTextView1.backgroundColor = [UIColor whiteColor];
    [_contentScrollView addSubview:richTextView1];
    [richTextView1 setNeedsDisplay];
    
    CGRect richTextViewFrame2 = CGRectMake(10,CGRectGetMaxY(richTextView1.frame) + 10, CGRectGetWidth(self.view.bounds)-20, 200);
    MFCoreTextView *richTextView2 = [self coreTextView:richTextViewFrame2 dataItem:dataItem2];
    richTextView2.backgroundColor = [UIColor whiteColor];
    [_contentScrollView addSubview:richTextView2];
    
    CGRect richTextViewFrame3 = CGRectMake(10,CGRectGetMaxY(richTextView2.frame) + 10, CGRectGetWidth(self.view.bounds)-20, 200);
    MFCoreTextView *richTextView3 = [self coreTextView:richTextViewFrame3 dataItem:dataItem3];
    richTextView3.backgroundColor = [UIColor whiteColor];
    [_contentScrollView addSubview:richTextView3];
    
    [richTextView2 setNeedsDisplay];
    [richTextView3 setNeedsDisplay];
    
    CGRect tableViewFrame = CGRectMake(0, CGRectGetMaxY(richTextView3.frame) + 20, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    _contentTableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    _contentTableView.backgroundColor = [UIColor redColor];
//    [_contentScrollView addSubview:_contentTableView];
    
    
    UIView *lastView = richTextView3;
    CGFloat maxY = CGRectGetMaxY(lastView.frame);
    _contentScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 30 + maxY);
}

-(MFCoreTextView *)coreTextView:(CGRect)frame
                       dataItem:(MFDiagnosticQuestionDataItem *)dataItem
{
    MFCoreTextView *richTextView = [[MFCoreTextView alloc] initWithFrame:frame];
    richTextView.backgroundColor = [UIColor yellowColor];

    MFFrameParserConfig *config = [MFFrameParserConfig new];
    config.width = CGRectGetWidth(frame);
    config.fontSize = 18.0f;
    config.lineSpace = 0.0f;
    
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
