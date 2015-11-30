//
//  UploadingDebugging.m
//  EternalMemory
//
//  Created by xiaoxiao on 1/21/14.
//  Copyright (c) 2014 sun. All rights reserved.
//
#import "EternalMemoryAppDelegate.h"
#import "ResumeVedioSendOperation.h"
#import "UploadingDebugging.h"
#import "DownloadViewCtrl.h"
#import "FileModel.h"
#import "Utilities.h"
#import "SavaData.h"
#import "MyToast.h"

#define FileModel  [FileModel sharedInstance]
#define ResumeUploading [ResumeVedioSendOperation shareInstance]
@implementation UploadingDebugging


//将上传的数据存储到plist表中
+(void)savaUplaodFiles:(NSMutableArray *)fileArr
{
    NSMutableArray *arr =[NSMutableArray array];
    for (NSDictionary *dic in fileArr)
    {
        if (dic[@"mediaItem"] == nil)
        {
            [arr addObject:dic];
        }
    }
    [SavaData writeArrToFile:arr FileName:User_Uploading_File];
}

//下载成功或删除文件成功后对上传的数据组的操作
+(void)uploadSuccessOrDeleteFileNotification:(int)index
{
//    [ResumeUploading stopUploading];
    if ([FileModel.uploadingArr[index][@"type"] isEqualToString:@"vedio"])
    {
        FileModel.videoNumber --;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"upLoadVedioNumber" object:nil];
    }
    else
    {
        FileModel.musicNumber--;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"upLoadMusicNumber" object:nil];
    }
}
//一个文件上传完成或失败后继续上传其他文件的操作
+(void)goOnUploadingAfterSuccessOrFailed
{
    NSInteger count = FileModel.uploadingArr.count;
    if (count != 0)
    {
        BOOL goOnUplaoding = NO;
        for (int i = 0; i < count; i ++)
        {
            NSDictionary *dic = FileModel.uploadingArr[i];
            if ([dic[@"state"] intValue] == 0 || [dic[@"state"] intValue] == 4)
            {
                [self resumeUploading:i];
                goOnUplaoding = YES;
                break;
            }
        }
        ResumeUploading.isUploading = goOnUplaoding;
    }
}
//恢复上传操作
+(void)resumeUploading:(int)index
{
    if ([Utilities checkNetwork])
    {
        [ResumeUploading startOrResumeUploadingWithFileIndex:index];
    }
    else
    {
        [MyToast showWithText:@"网络异常，请检查网络" :200];
    }
}

//判断上传列表是否有正在上传的数据及正在上传的内容的位置
+(void)setUploadIndex
{
    NSInteger count = FileModel.uploadingArr.count;
    if (count != 0)
    {
        for (int i = 0; i < count; i++)
        {
            if ([FileModel.uploadingArr[i][@"name"] isEqualToString:ResumeUploading.name])
            {
                ResumeUploading.fileIndex = i;
                break;
            }
        }
    }
    else
    {
        [ResumeUploading stopUploading];
    }
}

//上传中暂停、恢复按钮操作
+(void)stopAndReStartUploadAtIndex:(int)index
{
    [ResumeUploading suspendUploadingWithFileIndex:index];
    NSInteger count = FileModel.uploadingArr.count;
    if (count != 0)
    {
        BOOL isWaiting = NO;
        NSInteger nextIndex = -1;
        for (int i = 0; i < count; i++)
        {
            NSDictionary *dic = FileModel.uploadingArr[i];
            if ([dic[@"state"] intValue] == 0)
            {
                isWaiting = YES;
                nextIndex = i;
                break;
            }
        }
        if (isWaiting == YES)
        {
            [self resumeUploading:nextIndex];
        }
        else if (isWaiting == NO)
        {
            for (int i = 0; i < count; i ++)
            {
                NSDictionary *dic = FileModel.uploadingArr[i];
                if ([dic[@"state"] intValue] == 4)
                {
                    [self resumeUploading:i];
                    break;
                }
            }
        }
        else
        {
            ResumeUploading.isUploading = NO;
        }
    }
    else
    {
        ResumeUploading.isUploading = NO;
    }

}
//设置等待上传数据的点击暂停、恢复按钮后的状态
+(void)setWaitingDataStateAtIndex:(int)index
{
    NSMutableDictionary *replaceDict = [NSMutableDictionary dictionaryWithDictionary:FileModel.uploadingArr[index]];
    if ([replaceDict[@"state"] intValue] == 2||[replaceDict[@"state"] intValue] == 4)
    {
        [replaceDict setObject:[NSNumber numberWithInt:0] forKey:@"state"];
        [replaceDict setObject:@"等待上传..." forKey:@"stateDescription"];
        [FileModel.uploadingArr replaceObjectAtIndex:index withObject:replaceDict];
        [MyToast showWithText:@"有文件正在上传中，请等待..." :200];
    }
    else if ([replaceDict[@"state"] intValue] == 0)
    {
        [replaceDict setObject:[NSNumber numberWithInt:2] forKey:@"state"];
        [replaceDict setObject:@"暂停中..." forKey:@"stateDescription"];
        [FileModel.uploadingArr replaceObjectAtIndex:index withObject:replaceDict];
    }
}

//获取正在上传的数据的位置
+(int)uploadingIndex:(NSString *)name
{
    int index = -1;
    NSInteger count = FileModel.uploadingArr.count;
    for (int i = 0; i < count; i++)
    {
        if ( [FileModel.uploadingArr[i][@"identifier"] length] != 0 &&[FileModel.uploadingArr[i][@"identifier"] isEqualToString:name])
        {
            index = i;
            break;
        }
    }
    return index;
}

//设置数据上传失败的状态
+(void)setFailedState:(int)index FailedIdentifier:(NSString *)identifier
{
    [ResumeUploading stopUploading];
    NSMutableDictionary *replaceDict = [NSMutableDictionary dictionaryWithDictionary:FileModel.uploadingArr[index]];
    if (identifier != nil)
    {
        [replaceDict setObject:identifier forKey:@"identifier"];
    }
    [replaceDict setObject:[NSNumber numberWithInt:4] forKey:@"state"];
    [replaceDict setObject:@"上传失败，请重新上传" forKey:@"stateDescription"];
    [FileModel.uploadingArr removeObjectAtIndex:index];
    [FileModel.uploadingArr addObject:replaceDict];
    [SavaData writeArrToFile:FileModel.uploadingArr FileName:User_Uploading_File];
}

//程序进入后台后不同情况（上传成功、失败、内存不足等）下的操作  1表示成功  2表示内存不足 3其他情况
+(void)setBackgroundOperation:(int)state Index:(int)index
{
    EternalMemoryAppDelegate *appDelete = (EternalMemoryAppDelegate *)[UIApplication sharedApplication].delegate;
    for (UIView *view in appDelete.window.subviews)
    {
        UIResponder *responder = [view nextResponder];
        if ([responder isKindOfClass:[UINavigationController class]])
        {
            if ([[[(UINavigationController *)responder viewControllers] lastObject] isKindOfClass:[DownloadViewCtrl class]])
            {
                DownloadViewCtrl *downloadViewCtrl = (DownloadViewCtrl *) [[(UINavigationController *)responder viewControllers] lastObject];
                if (state == 1)
                {
                    [downloadViewCtrl uploadSuccess:index];
                }
                else if (state == 2)
                {
                    [downloadViewCtrl spaceIsNotEnough];
                }
                else if (state == 3)
                {
                    [downloadViewCtrl deleteDataWhenUnexceptedSituation:[NSDictionary dictionaryWithObjectsAndKeys:@"达到音乐数量限制",@"3077", nil]];
                }
            }
            else
            {
                if (state == 1)
                {
                    
                    [self uploadSuccessOrDeleteFileNotification:index];
                    [FileModel.uploadingArr removeObjectAtIndex:index];
                    [self savaUplaodFiles:FileModel.uploadingArr];

                    NSInteger count = FileModel.uploadingArr.count;
                    if (count != 0)
                    {
                        [UploadingDebugging goOnUploadingAfterSuccessOrFailed];
                    }
                    else
                    {
                        ResumeUploading.isUploading = NO;
                    }
                }
                else if (state == 2)
                {
                    [self goOnUploadingAfterSuccessOrFailed];
                    [MyToast showWithText:@"内存空间不够" :200];
                }
                else if (state == 3)
                {
                    [self goOnUploadingAfterSuccessOrFailed];
                    [MyToast showWithText:@"达到音乐数量限制" :200];
                }
            }
        }
    }
}

//判断是否正在上传
+(BOOL)isUploading
{
    BOOL isUploading = NO;
    for (NSDictionary *dic in FileModel.uploadingArr)
    {
        if ([dic[@"state"] intValue] == 1)
        {
            isUploading = YES;
            break;
        }
    }
    return isUploading;
}
//退出时设置上传数据
+(void)setupUploadingInfo
{
    [[ResumeVedioSendOperation shareInstance] setSuspendWhenNetworkNoReachible];
//    [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];
    //退出登录时重置公用的数据
    [Utilities resetCommonData];
}

//处理上传完成意外存留的数据
+(void)dealWithUploadedData
{
    
    NSString *downFileName = [NSString stringWithFormat:@"%@",[SavaData parseDicFromFile:[NSString stringWithFormat:@"%@.plist",USERID]][@"userName"]];
    NSString *musicPath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"ETMemory"] stringByAppendingPathComponent:@"Music"];
    NSString *musicDirectory = [musicPath stringByAppendingPathComponent:downFileName];
    NSArray *musicitems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:musicDirectory error:nil];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSString *filename in musicitems)
    {
        NSInteger count = FileModel.uploadingArr.count;
        for (int i = 0 ; i < count; i++)
        {
            NSDictionary *dic = FileModel.uploadingArr[i];
            if ([dic[@"name"] isEqualToString:filename])
            {
                [indexSet addIndex:i];
                FileModel.musicNumber --;
            }
        }
    }
    [FileModel.uploadingArr removeObjectsAtIndexes:indexSet];
    [indexSet removeAllIndexes];
    
    
    NSString *vedioPath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"ETMemory"] stringByAppendingPathComponent:@"Videos"];
    NSString *vedioDirectory = [vedioPath stringByAppendingPathComponent:downFileName];
    NSArray *vedioItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:vedioDirectory error:nil];
    for (NSString *filename in vedioItems)
    {
        NSInteger count = FileModel.uploadingArr.count;
        for (int i = 0 ; i < count; i++)
        {
            NSDictionary *dic = FileModel.uploadingArr[i];
            if ([dic[@"name"] isEqualToString:filename])
            {
                [indexSet addIndex:i];
                FileModel.videoNumber --;
            }
        }
    }
    [FileModel.uploadingArr removeObjectsAtIndexes:indexSet];

}

//处理意外数据问题
+(void)dealWithErrorMusicData:(NSMutableArray *)uploadMusicArr
{
    //处理意外错误数据
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths  objectAtIndex:0];
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray *musicArr = [NSMutableArray array];
    for (NSString *filename in items)
    {
        if (![filename hasSuffix:@".plist"] && ![filename hasSuffix:@".db"] &&![filename hasSuffix:@"emp"])
        {
            
            [musicArr addObject:filename];
        }
    }
    
    for (NSString * fileName in musicArr)
    {
        BOOL exist = NO;
        for (NSString *uploadName in uploadMusicArr)
        {
            if ([uploadName isEqualToString:fileName])
            {
                exist = YES;
                break;
            }
        }
        if (exist == NO)
        {
            [[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

//应用启动或从后台返回时上传数据的处理
+(void)updateDataWhenBeginOrComeBack
{
    FileModel.musicNumber = 0;
    FileModel.videoNumber = 0;
    
    NSMutableArray *uploadMusicArr = [NSMutableArray array];
    for (NSMutableDictionary * dic in [SavaData parseArrFromFile:User_Uploading_File])
    {
        [dic setObject:[NSNumber numberWithInt:2] forKey:@"state"];
        [dic setObject:@"暂停中..." forKey:@"stateDescription"];
        if ([dic[@"type"] isEqualToString:@"vedio"])
        {
            [FileModel.uploadingArr addObject:dic];
            FileModel.videoNumber ++;
        }
        else if (([dic[@"type"] isEqualToString:@"music"] && [dic[@"completeConvet"] boolValue] == YES))
        {
            [uploadMusicArr addObject:dic[@"name"]];
            [FileModel.uploadingArr addObject:dic];
            FileModel.musicNumber ++;
        }
    }
    [UploadingDebugging dealWithUploadedData];
    [SavaData writeArrToFile:FileModel.uploadingArr FileName:User_Uploading_File];
    [UploadingDebugging dealWithErrorMusicData:uploadMusicArr];
}

@end
