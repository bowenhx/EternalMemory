//
//  PhotoOrderViewController.m
//  EternalMemory
//
//  Created by zhaogl on 14-3-10.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "PhotoOrderViewController.h"
#import "PhotoOrderCell.h"
#import "UIView+SubviewHunting.h"
#import "MyToast.h"
#import "NTLimitationInputView.h"
#import "LimitePasteTextView.h"
#import "PhotoListFormedRequest.h"
#import "MessageModel.h"
#import "UIImageView+WebCache.h"
#import "RecordPromptView.h"
#import "RecordOperation.h"
#import "EMAudio.h"
#import "DiaryPictureClassificationModel.h"
#include "amrFileCodec.h"
#import "PhotoUploadRequest.h"
#import "EMAllLifeMemoDAO.h"
#import "DiaryPictureClassificationSQL.h"
#import "PhotoOrderUploadEngine.h"
#import "ErrorCodeHandle.h"


#define HEIGHT (iOS7?64:44)
#define Photo_Description   100
#define TopAudio            200
#define BottomAudio         300
#define BackTag             400

@interface PhotoOrderViewController ()

@end

@implementation PhotoOrderViewController

@synthesize editContentBtnPressedBlock = _editContentBtnPressedBlock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc{
    
    if (recordButton) {
        [recordButton release];
        recordButton = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EMRecordDidStopNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DismissCurrentViewToPhotoList" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FailUploadSortAndDescription" object:nil];
    if (_timer && _timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
    [_dataSourceAry release];
    [super dealloc];
}

-(void)addGuideView{
    
    guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 150, 290, 183)];
    guideImageView.image = [UIImage imageNamed:@"reorder_guide"];
    guideImageView.userInteractionEnabled = YES;
    [self.view addSubview:guideImageView];
    [guideImageView release];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeGuideView)];
    [guideImageView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    UILabel *guideTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 140,280 ,20 )];
    guideTextLabel.backgroundColor = [UIColor clearColor];
    guideTextLabel.text = @"按住图片，可上下移动排序";
    guideTextLabel.textColor = [UIColor whiteColor];
    guideTextLabel.textAlignment = NSTextAlignmentCenter;
    guideTextLabel.font = [UIFont systemFontOfSize:15.0f];
    [guideImageView addSubview:guideTextLabel];
    [guideTextLabel release];
    
}
-(void)removeGuideView{
    
    BOOL a = [[SavaData shareInstance] printBoolData:REORDER_PHOTO_FIRST];
    if (!a) {
        [[SavaData shareInstance] savaDataBool:YES KeyString:REORDER_PHOTO_FIRST];
        [guideImageView removeFromSuperview];
    }
}
-(void)addNoAudioView{
    
    _noAudioImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, HEIGHT, SCREEN_WIDTH, 39)];
    _noAudioImg.image = [UIImage imageNamed:@"reorder_addAudio"];
    _noAudioImg.userInteractionEnabled = YES;
    [self.view addSubview:_noAudioImg];
    [_noAudioImg release];
    
    UILabel *addLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 0, 100, 39)];
    addLabel.backgroundColor = [UIColor clearColor];
    addLabel.text = @"添加语音";
    addLabel.font = [UIFont systemFontOfSize:15.0f];
    addLabel.textAlignment = NSTextAlignmentCenter;
    [_noAudioImg addSubview:addLabel];
    [addLabel release];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addAudio)];
    [_noAudioImg addGestureRecognizer:tapGesture];
    [tapGesture release];
}
-(void)addHaveAudioView:(NSString *)time{
    
    _haveAudioImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, HEIGHT, SCREEN_WIDTH, 39)];
    _haveAudioImg.image = [UIImage imageNamed:@"reorder_finishAudio"];
    _haveAudioImg.userInteractionEnabled = YES;
    [self.view addSubview:_haveAudioImg];
    [_haveAudioImg release];
    
    UILabel *addLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 100, 39)];
    addLabel.backgroundColor = [UIColor clearColor];
    addLabel.text = [NSString stringWithFormat:@"已录音0%@",time];
    addLabel.font = [UIFont systemFontOfSize:15.0f];
    [_haveAudioImg addSubview:addLabel];
    [addLabel release];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAudio)];
    [_haveAudioImg addGestureRecognizer:tapGesture];
    [tapGesture release];
}
-(void)tapAudio{
    
    if (haveContentNow) {
        
        UITableViewCell *photoCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:haveContentIndex - 1 inSection:0]];
        for(id obj in photoCell.contentView.subviews){
            if ([obj isKindOfClass:[NTLimitationInputView class]]) {
                NTLimitationInputView *inputView = (NTLimitationInputView *)obj;
                [inputView.textView resignFirstResponder];
                break;
            }
        }
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除录音" otherButtonTitles:@"播放录音", nil];
    actionSheet.tag = TopAudio;
    [actionSheet showInView:self.view];
    [actionSheet release];
    
}
-(void)addOrderPrompt{
    
    UIImageView *promtView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 150, 280, 200)];
    [self.view addSubview:promtView];
    [promtView release];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.middleBtn.hidden = YES;
    [self.rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    haveContentNow = NO;
    orderHaveChanged = NO;
    audioHaveChanged = NO;

    _dataSourceAry = [[NSMutableArray alloc] initWithArray:_dataSource];
    self.audio = self.diaryModel.audio;
    if(!self.diaryModel.audio.duration){
        [self addNoAudioView];
    }else{
        NSString *time = [NSString stringWithFormat:@"%d:%02d''",(self.diaryModel.audio.duration / 60),(self.diaryModel.audio.duration % 60)];
        [self addHaveAudioView:time];
    }
   
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, HEIGHT + 59, SCREEN_WIDTH - 20, SCREEN_HEIGHT - 64 - 59) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollEnabled = YES;
    _tableView.contentSize = CGSizeMake(320, _tableView.frame.size.height);
    
//    [_tableView convertRect:<#(CGRect)#> toView:<#(UIView *)#>];
    
//    [_tableView registerNib:[UINib nibWithNibName:@"PhotoOrderCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_tableView];
    [_tableView release];
    
    [_tableView setEditing:YES];
    
    BOOL comeFirst = [[SavaData shareInstance] printBoolData:REORDER_PHOTO_FIRST];
    if (!comeFirst) {
        [self addGuideView];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopRecordAudio:) name:@"getRecordInfo" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordDidStopNotification:) name:@"EMRecordDidStopNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DismissCurrentView:) name:@"DismissCurrentViewToPhotoList" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FailUploadSortAndDescription:) name:@"FailUploadSortAndDescription" object:nil];


	// Do any additional setup after loading the view.
}
-(void)DismissCurrentView:(NSNotification *)notify{
    
    [self dismissViewControllerAnimated:NO completion:^{
        [_hud show:NO];
        [_hud removeFromSuperview];
        _hud = nil;
    }];
}
-(void)FailUploadSortAndDescription:(NSNotification *)notify{
    
    [_hud show:NO];
    [_hud removeFromSuperview];
    _hud = nil;
}
-(void)addTextDescription:(UIButton *)btn{
    
    orderHaveChanged = YES;
    
    if (haveContentNow && haveContentIndex != btn.tag) {
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:haveContentIndex - 1 inSection:0]];
        UIButton *btn1;
        NTLimitationInputView *inputView1 = nil;
        MessageModel *model = (MessageModel *)_dataSource[haveContentIndex - 1];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            for(id obj in [cell.subviews[0] subviews]){
                if ([obj isKindOfClass:[UIButton class]]) {
                    btn1 = (UIButton *)obj;
                    btn1.selected = NO;
                    haveContentNow = NO;
                    [btn1 setImage:[UIImage imageNamed:@"reorder_write"] forState:UIControlStateNormal];
                    break;
                }
            }
        }else{
            for(id obj in cell.subviews){
                if ([obj isKindOfClass:[UIButton class]]) {
                    btn1 = (UIButton *)obj;
                    btn1.selected = NO;
                    haveContentNow = NO;
                    [btn1 setImage:[UIImage imageNamed:@"reorder_write"] forState:UIControlStateNormal];
                    break;
                }
            }
        }
        for(id obj in cell.contentView.subviews){
            if ([obj isKindOfClass:[NTLimitationInputView class]]){
                inputView1 = (NTLimitationInputView *)obj;
                break;
            }
        }
        if (inputView1.textView.text.length > 100) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您输入的描述信息过长，不能超过100字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            return ;
        }
//        [inputView1.textView resignFirstResponder];
        inputView1.textView.userInteractionEnabled = NO;
        inputView1.textView.contentOffset = CGPointMake(0, 0);
        model.content = inputView1.textView.text;
        [_dataSourceAry replaceObjectAtIndex:haveContentIndex - 1 withObject:model];
//        [MyToast showWithText:@"请先保存上一张照片的描述" :150];
//        return;
    }
    if (btn.selected) {
        btn.selected = NO;
        haveContentNow = NO;
        [btn setImage:[UIImage imageNamed:@"reorder_write"] forState:UIControlStateNormal];
        if (_editContentBtnPressedBlock) {
            _editContentBtnPressedBlock(btn);
        }
    }else{
        btn.selected = YES;
        haveContentNow = YES;
        haveContentIndex = btn.tag;
        [btn setImage:[UIImage imageNamed:@"reorder_finishWrite"] forState:UIControlStateNormal];
        if (_editContentBtnPressedBlock) {
            _editContentBtnPressedBlock(btn);
        }
    }
}
-(void)addEditContentBtn:(UITableViewCell *)cell AndIndex:(NSInteger)index{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        for(id obj in [cell.subviews[0] subviews]){
            if ([obj isKindOfClass:[UIButton class]]) {
                [obj removeFromSuperview];
            }
        }
    }else{
        for(id obj in cell.subviews){
            if ([obj isKindOfClass:[UIButton class]]) {
                [obj removeFromSuperview];
            }
        }
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(260, 0, 38, 78);
    btn.tag = index + 1;
    [btn addTarget:self action:@selector(addTextDescription:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"reorder_write"] forState:UIControlStateNormal];
    btn.imageEdgeInsets = UIEdgeInsetsMake(30, 15, 30, 5);
    
    [cell addSubview:btn];

    
}
-(void)addCellBg:(UITableViewCell *)cell AndIndex:(NSInteger)index{
    
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reorder_cellBg"]];
    img.frame = CGRectMake(69, 0, 231, 73);
    [cell.contentView addSubview:img];
    [img release];
}

-(void)addPhotoImg:(UITableViewCell *)cell AndIndex:(NSInteger)index{
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 69, 73)];
    img.tag = index + 1;
    self.setPhotoImgBlock = ^(MessageModel *model){
        if (model.thumbnailImage) {
            img.image = model.thumbnailImage;
        }else{
            [img setImageWithURL:[NSURL URLWithString:model.attachURL]];
        }
    };
    [cell.contentView addSubview:img];
    [img release];
}

-(void)addTextView:(UITableViewCell *)cell AndIndex:(NSInteger)index{
    
    NTLimitationInputView *inputView = [[NTLimitationInputView alloc] initWithFrame:CGRectMake(77, 2, 180, 69)];
    self.setTextViewBlock = ^(MessageModel *model,BOOL hidden){
        inputView.maxLength = 100;
        inputView.textView.tag = index + 1;
        inputView.textView.userInteractionEnabled = NO;
        if (model.content.length != 0) {
            inputView.string = model.content;
        }
        inputView.hidden = hidden;
    };
    self.editContentBtnPressedBlock = ^(UIButton *btn){
        
        UITableViewCell *photoCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:btn.tag - 1 inSection:0]];
        for(id obj in photoCell.contentView.subviews){
            
            if ([obj isKindOfClass:[NTLimitationInputView class]]) {
                
                NTLimitationInputView *inputView1 = (NTLimitationInputView *)obj;
                MessageModel *model = _dataSourceAry[btn.tag - 1];

                if (btn.selected) {
                    
                    [photoCell.contentView bringSubviewToFront:inputView1];
                    inputView1.textView.userInteractionEnabled = YES;
                    [inputView1.textView becomeFirstResponder];
                    if ([inputView1.textView.text isEqualToString:@"请输入照片描述"]) {
                        inputView1.textView.text = @"";
                    }
                    _tableView.contentSize = CGSizeMake(300, _tableView.frame.size.height + 250);
                    [_tableView setContentOffset:CGPointMake(0, 78*(btn.tag - 1)) animated:YES];
                }else{
                    if (inputView1.textView.text.length > 100) {
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您输入的描述信息过长，不能超过100字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alert show];
                        [alert release];
                        return ;
                    }
                    [inputView1.textView resignFirstResponder];
                    inputView1.textView.userInteractionEnabled = NO;
                    inputView1.textView.contentOffset = CGPointMake(0, 0);
                    model.content = inputView1.textView.text;
                    _tableView.contentOffset = CGPointMake(0, 0);
                    _tableView.contentSize = CGSizeMake(300, _tableView.frame.size.height + 30);
                }
                [_dataSourceAry replaceObjectAtIndex:btn.tag - 1 withObject:model];
                break;
            }
        }
        
    };
    [cell.contentView addSubview:inputView];
    [inputView release];
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataSourceAry.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIndentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier] autorelease];
    }
    MessageModel  *model = _dataSourceAry[indexPath.row];
    /*if (model.thumbnailImage) {
        cell.photoImg.image = model.thumbnailImage;
    }else{
        [cell.photoImg setImageWithURL:[NSURL URLWithString:model.attachURL]];
    }
    cell.inputView.maxLength = 100;
    cell.inputView.textView.tag = indexPath.row + 1;
    cell.inputView.textView.userInteractionEnabled = NO;
    if (model.content.length != 0) {
        cell.inputView.string = model.content;
    }
    for(id obj in cell.subviews){
        if ([obj isKindOfClass:[UIButton class]]) {
            [obj removeFromSuperview];
        }
    }*/
    for(id obj in cell.contentView.subviews){
        [obj removeFromSuperview];
    }
    
    [self addCellBg:cell AndIndex:indexPath.row];
    [self addPhotoImg:cell AndIndex:indexPath.row];
    if (_setPhotoImgBlock) {
        _setPhotoImgBlock(model);
    }
    [self addTextView:cell AndIndex:indexPath.row];
    if (_setTextViewBlock) {
        _setTextViewBlock(model,NO);
    }
    
    if (model.thumbnailType == MessageModelThumbnailTypeUserUpload) {
        [self addEditContentBtn:cell AndIndex:indexPath.row];
        
    }else if (model.thumbnailType == MessageModelThumbnailTypeTemplate){
        if (_setTextViewBlock) {
            _setTextViewBlock(model,YES);
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 78;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    PhotoOrderCell *Cell = (PhotoOrderCell *)cell;
	UIView* reorderControl = [cell huntedSubviewWithClassName:@"UITableViewCellReorderControl"];
    reorderControl.backgroundColor = [UIColor clearColor];
	UIView* resizedGripView = [[UIView alloc] initWithFrame:CGRectMake(-205, 0, 300, 78)];
    resizedGripView.userInteractionEnabled = YES;
    resizedGripView.backgroundColor = [UIColor clearColor];
	[resizedGripView addSubview:reorderControl];
	[cell.contentView addSubview:resizedGripView];
    
	CGSize sizeDifference = CGSizeMake(resizedGripView.frame.size.width - reorderControl.frame.size.width, resizedGripView.frame.size.height - reorderControl.frame.size.height);
	CGSize transformRatio = CGSizeMake(resizedGripView.frame.size.width / reorderControl.frame.size.width, resizedGripView.frame.size.height / reorderControl.frame.size.height);
    
	CGAffineTransform transform = CGAffineTransformIdentity;
    
	//	Scale custom view so grip will fill entire cell
	transform = CGAffineTransformScale(transform, transformRatio.width, transformRatio.height);
    
	//	Move custom view so the grip's top left aligns with the cell's top left
	transform = CGAffineTransformTranslate(transform, -sizeDifference.width / 2.0, -sizeDifference.height / 2.0);
    
	[resizedGripView setTransform:transform];
    
	for(UIImageView* cellGrip in reorderControl.subviews)
	{
		if([cellGrip isKindOfClass:[UIImageView class]])
            cellGrip.backgroundColor = [UIColor clearColor];
			[cellGrip setImage:nil];
	}
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
    
    

}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}
-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (destinationIndexPath.row <= [_dataSourceAry count]) {
        orderHaveChanged = YES;
        MessageModel *tempModel=[[_dataSourceAry objectAtIndex:sourceIndexPath.row] retain];
        [_dataSourceAry removeObjectAtIndex:sourceIndexPath.row];
        [_dataSourceAry insertObject:tempModel atIndex:destinationIndexPath.row];
        [tempModel release];
        
        
        NSInteger begin = sourceIndexPath.row;
        NSInteger end = destinationIndexPath.row;
        if (begin < end) {
            for (int i = begin + 1; i <= end; i ++) {
                
                [self changeEditBtnTag:i AndNowTag:i];
                
            }
        }else if(begin > end){
            for (int i = begin - 1; i >= end; i --) {
                
                [self changeEditBtnTag:i AndNowTag:i + 2];
                
            }
        }
        [self changeEditBtnTag:begin AndNowTag:end + 1];
    }
}
-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row == _dataSourceAry.count) {
        return sourceIndexPath;
    }
    
    
//    [self changeEditBtnTag:begin AndNowTag:end + 1];
//    [self changeEditBtnTag:end AndNowTag:begin + 1];
    
	return proposedDestinationIndexPath;

}
-(void)changeEditBtnTag:(NSInteger)original AndNowTag:(NSInteger)now{
    
    UITableViewCell *cell = (UITableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:original inSection:0]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        for(id obj in [cell.subviews[0] subviews]){
            if ([obj isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)obj;
                btn.tag = now;
                if (btn.selected) {
                    haveContentNow = YES;
                    haveContentIndex = btn.tag;
                }
                break;
            }
        }
    }else{
        for(id obj in cell.subviews){
            if ([obj isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)obj;
                btn.tag = now;
                if (btn.selected) {
                    haveContentNow = YES;
                    haveContentIndex = btn.tag;
                }
                break;
            }
        }
    }
    
}
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textView.tag - 1 inSection:0]];
    for(id obj in cell.contentView.subviews){
        if ([obj isKindOfClass:[NTLimitationInputView class]]) {
            NTLimitationInputView *inputView = (NTLimitationInputView *)obj;
            inputView.textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            break;
        }
    }
}

- (void)sendPhotoDescriptionRequest:(NSInteger)index
{
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.mode = MBProgressHUDModeText;
    _HUD.labelText = @"正在保存";
    [_HUD show:YES];
    [self.view addSubview:_HUD];
    [_HUD release];
    
    MessageModel *model = _dataSourceAry[index - 1];
    NSURL *url = [[RequestParams sharedInstance] updatePhotoDescription];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:Photo_Description],@"photoDescription",nil];
    [request setPostValue:@"ios" forKey:@"platform"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:model.blogId forKey:@"blogid"];
    [request setPostValue:model.content forKey:@"content"];
    __block typeof(self) bSelf = self;
    [request setCompletionBlock:^{
        [bSelf saveDescriptionSuccess:request];
    }];
    [request setFailedBlock:^{
        [bSelf saveDescriptionFail:request];
    }];
    [request startAsynchronous];
    [request release];
}
-(void)saveDescriptionSuccess:(ASIFormDataRequest *)request{
    
    NSData *data = [request responseData];
    NSDictionary *dic = [data objectFromJSONData];
    NSInteger result = [dic[@"success"] integerValue];
    NSString  *msg = dic[@"message"];
    if (result == 0) {
        [MyToast showWithText:msg :150];
        _HUD.labelText = msg;
        sleep(1);
        [_HUD removeFromSuperview];
    }else{
        _HUD.labelText = @"保存成功";
        sleep(1);
        [_HUD removeFromSuperview];
    }
}
-(void)saveDescriptionFail:(ASIFormDataRequest *)request{
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_tableView resignFirstResponder];
}
-(void)addAudio{
    
    if (haveContentNow) {
        
        UITableViewCell *photoCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:haveContentIndex - 1 inSection:0]];
        for(id obj in photoCell.contentView.subviews){
            if ([obj isKindOfClass:[NTLimitationInputView class]]) {
                NTLimitationInputView *inputView = (NTLimitationInputView *)obj;
                [inputView.textView resignFirstResponder];
                break;
            }
        }
    }
    
    [self addToolBarForAudio];
    
    float height = iOS7?50:70;

    recorderBackgroud = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - height)];
    recorderBackgroud.backgroundColor = [UIColor blackColor];
    recorderBackgroud.alpha = 0.8;
    [self.view addSubview:recorderBackgroud];
    [recorderBackgroud release];
    

    recordPromptView = [[RecordPromptView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - height) WithSelectPhoto:YES];
    [recorderBackgroud addSubview:recordPromptView];
    [RecordOperation startRecord:120];
}
-(void)addToolBarForAudio{
    
    float height = iOS7?50:70;
    toolBarBackView = [[UIImageView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - height, SCREEN_WIDTH, 50)];
    toolBarBackView.image = [UIImage imageNamed:@"camera-bottom-bar"];
    toolBarBackView.userInteractionEnabled = YES;
    
    //返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 60, 50);
    [backButton setImage:[UIImage imageNamed:@"bj_fh"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(popVC) forControlEvents:UIControlEventTouchUpInside];
    [toolBarBackView addSubview:backButton];
    
    UIImageView *recorderBgImage = [[UIImageView alloc] initWithFrame:CGRectMake(85, 5, 150, 40)];
    recorderBgImage.backgroundColor = [UIColor whiteColor];
    recorderBgImage.layer.cornerRadius = 8;
    [toolBarBackView addSubview:recorderBgImage];
    [recorderBgImage release];
    
    //操作录音按钮
    recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recordButton.frame = CGRectMake(85, 5, 150, 40);
    [recordButton setTitle:@"停止录音" forState:UIControlStateNormal];
    recordButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 8, 125);
    [recordButton setImage:[UIImage imageNamed:@"reorder_recorderBtnNormal"] forState:UIControlStateNormal];
    recordButton.titleEdgeInsets = UIEdgeInsetsMake(0,-20,0, 0);
    recordButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(stopRecordBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [toolBarBackView addSubview:recordButton];
    [recordButton retain];
    
    //上传按钮
    UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    uploadButton.frame = CGRectMake(260, 0, 60, 50);
    [uploadButton setImage:[UIImage imageNamed:@"bj_d"] forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(confirmRecord) forControlEvents:UIControlEventTouchUpInside];
    uploadButton.imageEdgeInsets = UIEdgeInsetsMake(15, 16, 15, 17);
    [toolBarBackView addSubview:uploadButton];
    
    [self.view addSubview:toolBarBackView];
    [toolBarBackView release];
    
}
- (void)confirmRecord
{
    [RecordOperation stopRecord];
    
    if (recorderBackgroud) {
        [recorderBackgroud removeFromSuperview];
        recorderBackgroud = nil;
    }
    if (toolBarBackView) {
        [toolBarBackView removeFromSuperview];
        toolBarBackView = nil;
    }
    
    if (self.audio.duration >= 1) {
        audioHaveChanged = YES;
        if (_noAudioImg) {
            [_noAudioImg removeFromSuperview];
            _noAudioImg = nil;
        }
        [self addHaveAudioView:_audioTime];
    }
}

-(void)popVC{
    
    if (self.audio || recordPromptView) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您确定放弃本次录音？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        [alert release];
        return;
    }
    if (recorderBackgroud) {
        [recorderBackgroud removeFromSuperview];
        recorderBackgroud = nil;
    }
    if (toolBarBackView) {
        [toolBarBackView removeFromSuperview];
        toolBarBackView = nil;
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == BackTag) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                
                [self.navigationController popViewControllerAnimated:NO];
                break;
            default:
                break;
        }
    }else{
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                [RecordOperation stopRecord];
                if (recordPromptView) {
                    [recordPromptView removeFromSuperview];
                    recordPromptView = nil;
                }
                if (recorderBackgroud) {
                    [recorderBackgroud removeFromSuperview];
                    recorderBackgroud = nil;
                }
                if (toolBarBackView) {
                    [toolBarBackView removeFromSuperview];
                    toolBarBackView = nil;
                }
                
                break;
            default:
                break;
        }
    }
}
//录音操作
-(void)stopRecordBtnPressed:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"停止录音"])
    {
        [RecordOperation stopRecord];
        if (recordPromptView) {
            [recordPromptView removeFromSuperview];
            recordPromptView = nil;
        }
    }
    else if ([sender.titleLabel.text hasPrefix:@"已录音0"])
    {
        [self recordFinishOrActionSheet];
    }
}
- (void)recordFinishOrActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除录音" otherButtonTitles:@"试听录音", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            [self deleteAudio:self.audio AndTag:actionSheet.tag];
            break;
        case 1:
            [self listenningAudio:self.audio AndTag:actionSheet.tag];
        default:
            break;
    }
}
-(void)stopRecordAudio:(NSNotification *)sender
{
    self.audio = (EMAudio *)sender.object;
    self.audio.audioStatus = EMAudioSyncStatusNeedsToBeUpload;
    self.diaryModel.audio = self.audio;
    newRecord = YES;
    
    [DiaryPictureClassificationSQL updateDiaryAudioInfo:self.diaryModel ForGrouID:self.diaryModel.groupId];
    if (self.audio.duration < 1) {
        [MyToast showWithText:@"录音时长不能小于1s" :150];
        if (recorderBackgroud) {
            [recorderBackgroud removeFromSuperview];
            recorderBackgroud = nil;
        }
        if (toolBarBackView) {
            [toolBarBackView removeFromSuperview];
            toolBarBackView = nil;
        }
        return;
    }
    _audioTime = [NSString stringWithFormat:@"%d:%02d''",(self.audio.duration / 60),(self.audio.duration % 60)];
    [recordButton setTitle:[NSString stringWithFormat:@"已录音0%d:%02d''",(self.audio.duration / 60),(self.audio.duration % 60)] forState:UIControlStateNormal];
    [recordButton setImage:[UIImage imageNamed:@"record_play_tring_black.png"] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:recorderBackgroud];
    
    if (_timer && _timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
}
-(void)recordDidStopNotification:(NSNotification *)sender
{
    [RecordOperation stopRecord];
    
    if (recorderBackgroud) {
        [recorderBackgroud removeFromSuperview];
        recorderBackgroud = nil;
    }
    if (recordPromptView) {
        [recordPromptView removeFromSuperview];
        recordPromptView = nil;
    }
    if (_noAudioImg) {
        [_noAudioImg removeFromSuperview];
        _noAudioImg = nil;
    }
    [self addHaveAudioView:_audioTime];
    if (toolBarBackView) {
        [toolBarBackView removeFromSuperview];
        toolBarBackView = nil;
    }
    if (_timer && _timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
}
- (void)deleteAudio:(EMAudio *)audio  AndTag:(NSInteger)tag{
    
    if (recorderBackgroud) {
        [recorderBackgroud removeFromSuperview];
        recorderBackgroud = nil;
    }
    if (toolBarBackView) {
        [toolBarBackView removeFromSuperview];
        toolBarBackView = nil;
    }
    if (tag == TopAudio) {
        
        self.diaryModel.audio.audioStatus = EMAudioSyncStatusNeedsToBeDeleted;
        [self deleteServerPhotoAudio];
        self.diaryModel.audio = nil;
    }else{
        audioHaveChanged = NO;
        [self deleteLocalAudio];
    }
    
}
-(void)deleteServerPhotoAudio{
    
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [_HUD show:YES];
    [self.view addSubview:_HUD];
    [_HUD release];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[[RequestParams sharedInstance] deleteLifePhotoAudio]];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setRequestMethod:@"POST"];
    request.timeOutSeconds = 3;
    [request setCompletionBlock:^{
        NSData *data = [request responseData];
        NSDictionary *dic = [data objectFromJSONData];
        NSInteger success = [dic[@"success"] integerValue];
        NSString *message = dic[@"message"];
        [_HUD removeFromSuperview];
        _HUD = nil;
        if (success == 1) {
            
            [self deleteLocalAudio];
            [DiaryPictureClassificationSQL updatediaryForDeleteAudio:self.diaryModel.groupId];
            self.diaryModel.audio = nil;
            self.audio = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:Delete_Life_Audio object:nil];
        }else{
            
            [ErrorCodeHandle handleErrorCode:dic[@"errorcode"] AndMsg:message];
        }
        
    }];
    [request setFailedBlock:^{
        [_HUD removeFromSuperview];
        _HUD = nil;
        [MyToast showWithText:@"删除失败" :150];
    }];
    
    [request startAsynchronous];
    [request release];
}
-(void)deleteLocalAudio{
    
    if ([[NSFileManager defaultManager] removeItemAtPath:self.audio.wavPath error:nil]) {
        [MyToast showWithText:@"删除成功" :140];
        self.audio = nil;
        _audioTime = @"";
        if (_haveAudioImg) {
            [_haveAudioImg removeFromSuperview];
            _haveAudioImg = nil;
            [self addNoAudioView];
        }
    }
}
//停止试听录音
-(void)stopListenRecord
{
    [_player stop];
    [self resetListenView];
}
-(void)resetListenView
{
    if (_timer && _timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
    [_player release];
    _player = nil;
    listenTime = 1;
    if (recordPlayView) {
        [recordPlayView removeFromSuperview];
        recordPlayView = nil;
    }
}
- (void)listenningAudio:(EMAudio *)audio AndTag:(NSInteger)tag{
    
    recordPlayView = [[RecordPlayView alloc]initWithFrame:self.view.bounds];
    __block typeof(self) bself = self;
    [self.view addSubview:recordPlayView];
    [recordPlayView release];
    recordPlayView.stopListenRecord = ^(void){
        [bself stopListenRecord];
    };
    if (audio.wavPath.length > 0 ) {
        NSData *audioData = [NSData dataWithContentsOfFile:audio.wavPath];
        recordPlayView.showTimeLabel .text = [NSString stringWithFormat:@"0%d:%02d / 0%d:%02d",(listenTime / 60),(listenTime % 60),(self.audio.duration / 60),(self.audio.duration % 60)];
        if (self.audio.duration <= 1)
        {
            recordPlayView.showTimeLabel.text = @"00:00 / 00:01";
        }
        else
        {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        }
        
        [self playAudioWithData:audioData];
        return;
    }
    
}
-(void)updateProgress
{
    recordPlayView.showTimeLabel .text = [NSString stringWithFormat:@"0%d:%02d / 0%d:%02d",(listenTime / 60),(listenTime % 60),(self.audio.duration / 60),(self.audio.duration % 60)];
    listenTime ++;
}
- (void)playAudioWithData:(NSData *)audioData {
    
    self.player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
    self.player.delegate = self;
    [self.player prepareToPlay];
    [self.player play];
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.audio.duration <= 1)
    {
        recordPlayView.showTimeLabel.text = @"00:01 / 00:01";
    }
    [self resetListenView];
}

-(void)backBtnPressed{
    
    if (orderHaveChanged && audioHaveChanged) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定要放弃本次编辑？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        alert.tag = BackTag;
        [alert show];
        [alert release];
    }else if (orderHaveChanged){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定要放弃照片编辑？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        alert.tag = BackTag;
        [alert show];
        [alert release];
    }else if (audioHaveChanged){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定要放弃录音编辑？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        alert.tag = BackTag;
        [alert show];
        [alert release];
    }else {
        [self.navigationController popViewControllerAnimated:NO];
    }
}
-(void)rightBtnPressed{
    
    if (haveContentNow) {
        [MyToast showWithText:@"请先保存照片描述" :150];
        return;
    }
    
    if ([Utilities checkNetwork]) {
        
        
        NSMutableArray *requestAry = [[NSMutableArray alloc] initWithCapacity:0];
        ASIFormDataRequest *request1 = [self sortPhotoRequest];

        if (request1) {
            [requestAry addObject:request1];
        }
        ASIFormDataRequest *request = [self uploadAudioRequest];
        if (request) {
            [requestAry addObject:request];
            [PhotoOrderUploadEngine sharedEngine].wavPath = self.audio.wavPath;
        }
        [PhotoOrderUploadEngine sharedEngine].uploadRequests = requestAry;
        [PhotoOrderUploadEngine sharedEngine].modelDataAry = _dataSourceAry;
        [requestAry release];
        
        [[PhotoOrderUploadEngine sharedEngine] startUpload];
        
        
        /*requestQueue = [[ASINetworkQueue alloc] init];    // 初始化
        [requestQueue setMaxConcurrentOperationCount:2];
        requestQueue.requestDidStartSelector = @selector(sortUploadingStarted:);
        requestQueue.requestDidFinishSelector = @selector(sortFinshUpLoaded:);
        requestQueue.requestDidFailSelector = @selector(sortFailedUploaded:);
        requestQueue.queueDidFinishSelector = @selector(audioFinashUploading:);
        requestQueue.delegate = self;
        [self sortPhotoRequest];
        [self uploadAudioRequest];
        [requestQueue go];
        [requestQueue release];*/
    }else{
        
        [MyToast showWithText:@"请检查网络" :150];
        
    }
   
    
}
-(void)sortUploadingStarted:(ASIHTTPRequest *)request{
    
}
-(void)sortFinshUpLoaded:(ASIHTTPRequest *)request{
    
    NSData *data = [request responseData];
    NSDictionary *dic = [data objectFromJSONData];
    NSInteger success = [dic[@"success"] integerValue];
    NSString *message = dic[@"message"];
    NSInteger tag = [request.userInfo[@"tag"] integerValue];
    if (success == 1) {
        if (tag == SortRequest) {
            
        }else if (tag == UploadAudioRequest){
            
        }
    }else if(success == 0){
        [MyToast showWithText:message :150];
        if (tag == SortRequest) {
            
        }else if (tag == UploadAudioRequest){
            
        }
    }
}
-(void)sortFailedUploaded:(ASIHTTPRequest *)request{
    
    NSInteger tag = [request.userInfo[@"tag"] integerValue];
    if (tag == SortRequest) {
        [MyToast showWithText:@"保存照片排序失败" :150];
    }else if (tag == UploadAudioRequest){
        [MyToast showWithText:@"上传录音失败" :150];
    }
    
}
-(void)audioFinashUploading:(ASINetworkQueue *)queue{
    
}
-(ASIFormDataRequest *)sortPhotoRequest{
    
    NSMutableString *blogIds = [NSMutableString stringWithString:@""];
    NSMutableString *walls = [NSMutableString stringWithString:@""];
    for (int i = 0; i < _dataSourceAry.count; i ++) {
        MessageModel *model = _dataSourceAry[i];
        if (!model.blogId) {
            blogIds = (NSMutableString *)[blogIds stringByAppendingString:@", "];
        }else{
            blogIds = (NSMutableString *)[blogIds stringByAppendingString:[NSString stringWithFormat:@",%@",model.blogId]];
        }
        if (!model.photoWall) {
            walls = (NSMutableString *)[walls stringByAppendingString:@", "];
        }else{
            walls = (NSMutableString *)[walls stringByAppendingString:[NSString stringWithFormat:@",%@",model.photoWall]];
        }
    }
    NSMutableString *blogIdsStr = [NSMutableString stringWithString:blogIds];
    NSMutableString *wallsStr = [NSMutableString stringWithString:walls];
    
    [blogIdsStr replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];

    [wallsStr deleteCharactersInRange:NSMakeRange(0, 1)];
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    [_hud show:YES];
    [self.view addSubview:_hud];
    [_hud release];

    NSURL *url = [[RequestParams sharedInstance] sortForLifePhoto];
    _request = [ASIFormDataRequest requestWithURL:url];
    _request.shouldAttemptPersistentConnection = NO;
    [_request setPostValue:@"ios" forKey:@"platform"];
    [_request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [_request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [_request setPostValue:blogIdsStr forKey:@"blogids"];
    [_request setPostValue:wallsStr forKey:@"walls"];
    for (int i = 0; i < _dataSourceAry.count; i ++) {
        MessageModel *model = _dataSourceAry[i];
        [_request setPostValue:model.content forKey:[NSString stringWithFormat:@"content%@",model.photoWall]];
    }
    _request.delegate = self;
    _request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:SortRequest],@"tag",nil];
    [_request setRequestMethod:@"POST"];
    [_request setTimeOutSeconds:10.0];
    
    return _request;
}

-(ASIFormDataRequest *)uploadAudioRequest{
    
    if (self.audio && newRecord) {
        
        self.audio.amrPath = [Utilities fullPathForAudioFileOfType:@"amr"];
        
        if (EncodeWAVEFileToAMRFile([self.audio.wavPath cStringUsingEncoding:NSASCIIStringEncoding], [self.audio.amrPath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16)) {
            
            self.audio.audioData = [NSData dataWithContentsOfFile:self.audio.amrPath];
            _request = [ASIFormDataRequest requestWithURL:[[RequestParams sharedInstance] uploadLifePhotoAudio]];
            _request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:UploadAudioRequest],@"tag",nil];
            [_request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
            [_request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
            [_request setPostValue:@"ios" forKey:@"platform"];
            _request.timeOutSeconds = 300;
            [_request setPostValue:[NSString stringWithFormat:@"%d",self.audio.duration] forKey:@"duration"];
            _request.delegate = self;
//            NSString *flag = @"";
//            if (self.audio.audioStatus == EMAudioSyncStatusNeedsToBeUpload || !self.audio.audioStatus) flag = @"add";
//            if (self.audio.audioStatus == EMAudioSyncStatusNeedsToBeUpdated) flag = @"update";
            [_request setPostValue:@"add" forKey:@"flag"];
            [_request addData:self.audio.audioData withFileName:@"audio.amr" andContentType:@"audio/amr" forKey:@"upfile"];
//            [requestQueue addOperation:_request];
            return _request;
        }
    }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
