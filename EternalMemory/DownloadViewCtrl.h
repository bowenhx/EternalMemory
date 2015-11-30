//
//  DownloadViewCtrl.h
//  EternalMemory
//
//  Created by Guibing on 06/08/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import "BaseTableController.h"
#import "UploadingVideoViewCtrl.h"
#import "BackgroundMusicViewCtrl.h"
#import "ResumeVedioSendOperation.h"
typedef enum _videoAndMusic
{
    videoType,
    musicType,
}videoAndType;

@interface DownloadViewCtrl : BaseTableController<UIAlertViewDelegate,ResumeVedioSendOperationDelegate>
{
    videoAndType dataType;
    
}
//@property (nonatomic ,assign)UploadingVideoViewCtrl *upVideoFile;
//@property (nonatomic ,assign)BackgroundMusicViewCtrl *upMusicFile;
@property (nonatomic , retain)UIView *viewNav;
@property (nonatomic , retain)NSMutableArray *arrDatas;

//动态显示上传进度
-(void)uploadProgress:(CGFloat)progress UploadIndex:(int)index UploadFileName:(NSString *)identifier;
//文件上传成功
-(void)uploadSuccess:(int)index;
//文件上传失败
-(void)uploadFaield:(int)index FailedIdentifier:(NSString *)identifier;
//内存空间不足提醒
-(void)spaceIsNotEnough;
//意外情况发生直接删除数据（暂时处理方法）
-(void)deleteDataWhenUnexceptedSituation:(NSDictionary *)dic;


//@property (nonatomic,copy) void (^didDeleteActionSheetBlock)();
@end
