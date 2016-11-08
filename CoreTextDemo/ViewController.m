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
#import "MMTableViewCell.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIScrollView *_contentScrollView;
    
    UITableView *_contentTableView;
    NSMutableArray *_diagnosticQuestions;
    NSMutableArray *_coreTextDatas;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:_contentScrollView];
    
    _diagnosticQuestions = [[MFCustomerDiagnosticLogic sharedLogic] diagnosticQuestions];
    MFDiagnosticQuestionDataItem *dataItem = _diagnosticQuestions[8];
    MFDiagnosticQuestionDataItem *dataItem2 = _diagnosticQuestions[3];
    MFDiagnosticQuestionDataItem *dataItem3 = _diagnosticQuestions[18];
    
    CGRect firstViewFrame = CGRectMake(10, 50, CGRectGetWidth(self.view.bounds)-20, 200);
    ParagraphStyleTextView *testView = [[ParagraphStyleTextView alloc] initWithFrame:firstViewFrame];
    testView.backgroundColor = [UIColor lightGrayColor];
    [_contentScrollView addSubview:testView];
    
    CGRect richTextViewFrame = CGRectMake(10,CGRectGetMaxY(firstViewFrame) + 20, CGRectGetWidth(self.view.bounds)-20, 200);
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
    
    UIView *lastView = richTextView3;
    CGFloat maxY = CGRectGetMaxY(lastView.frame);
    _contentScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 30 + maxY);
    
    
    CGRect tableViewFrame = CGRectMake(0, CGRectGetMaxY(richTextView3.frame) + 20, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    tableViewFrame = CGRectMake(0,20, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-20);
    [self initTableViewFrame:tableViewFrame];
    
    [self createCoreTextDatas];
    
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

-(void)initTableViewFrame:(CGRect)tableViewFrame
{
    _contentTableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.backgroundColor = [UIColor whiteColor];
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_contentTableView];
}

-(void)createCoreTextDatas
{
    _coreTextDatas = [NSMutableArray array];
    
    for (int i = 0; i < _diagnosticQuestions.count; i++) {
        MFDiagnosticQuestionDataItem *dataItem = _diagnosticQuestions[i];
        
        MFFrameParserConfig *config = [MFFrameParserConfig new];
        config.width = CGRectGetWidth(self.view.bounds) - 20;
        config.fontSize = 18.0f;
        config.lineSpace = 0.0f;
        config.textColor = [UIColor hx_colorWithHexString:@"373737"];
        
        MFDiagnosticCoreTextData *data = [MFDiagnosticDataParser parseContent:dataItem config:config];
        [_coreTextDatas addObject:data];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _coreTextDatas.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MFDiagnosticCoreTextData *data = (MFDiagnosticCoreTextData *)_coreTextDatas[indexPath.row];
    return data.height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MFDiagnosticQuestionCell";
    MMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[MMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        MFCoreTextView *cellView = [[MFCoreTextView alloc] initWithFrame:CGRectZero];
        cell.m_subContentView = cellView;
    }
    
    MFDiagnosticCoreTextData *data = (MFDiagnosticCoreTextData *)_coreTextDatas[indexPath.row];

    MFCoreTextView *cellView = (MFCoreTextView *)cell.m_subContentView;
    cellView.frame = CGRectMake(10, 0, CGRectGetWidth(cell.contentView.bounds) - 20, CGRectGetHeight(cell.contentView.bounds));
    cellView.data = data;
    
    [cellView setNeedsDisplay];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
