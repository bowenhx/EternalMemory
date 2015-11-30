//
//  PhotoOrderViewController.h
//  EternalMemory
//
//  Created by zhaogl on 14-3-10.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "CustomNavBarController.h"
#import "RecordPlayView.h"
#import "MessageModel.h"
#import "MBProgressHUD.h"

@class DiaryPictureClassificationModel;

typedef void(^EditContentBtnPressedBlock)(UIButton *btn);
typedef void(^SetPhotoImgBlock)(MessageModel *model);
typedef void(^SetTextViewBlock)(MessageModel *model,BOOL hiden);

@class RecordPromptView;
@class EMAudio;
@interface PhotoOrderViewController : CustomNavBarController<
    UITableViewDataSource,
    UITableViewDelegate,
    NavBarDelegate,
    UITextViewDelegate,
    ASIHTTPRequestDelegate,
    UIActionSheetDelegate,
    AVAudioRecorderDelegate,
    AVAudioPlayerDelegate,
    UIAlertViewDelegate>{
        
        UITableView      *_tableView;
        BOOL             _editing;
        NSMutableArray   *_ImgDataAry;
        NSMutableArray   *contentAry;
        UIButton         *_editContentBtn;
        BOOL             haveContentNow;
        NSInteger        haveContentIndex;
        NSString         *_content;
        UIImageView      *guideImageView;
        MBProgressHUD    *_HUD;
        UIImageView      *_haveAudioImg;
        UIImageView      *_noAudioImg;
        RecordPromptView *recordPromptView;
        UIButton         *recordButton;
        UIImageView      *recorderImg;
        UIView           *recorderBackgroud;
        RecordPlayView   *recordPlayView;
        UIImageView      *toolBarBackView;
        NSTimer          *_timer;
        NSInteger        listenTime;//录音播放的时长
        NSString         *_audioTime;
        ASIFormDataRequest *_request;
        ASINetworkQueue  *requestQueue;
        
        BOOL             newRecord;
        NSMutableArray   *_dataSourceAry;
        BOOL             orderHaveChanged;
        BOOL             audioHaveChanged;
        MBProgressHUD    *_hud;
    
}

//dataSource中存的EMMemorizeMessageModel 图片存在 thumbnailImage 中
@property (nonatomic, retain)NSArray  *dataSource;
@property (nonatomic, retain)DiaryPictureClassificationModel *diaryModel;
@property (nonatomic, copy) EditContentBtnPressedBlock editContentBtnPressedBlock;
@property (nonatomic, copy) SetPhotoImgBlock setPhotoImgBlock;
@property (nonatomic, copy) SetTextViewBlock setTextViewBlock;

@property (nonatomic, retain ) EMAudio *audio;
@property (nonatomic, retain)  AVAudioPlayer *player ;



@end
