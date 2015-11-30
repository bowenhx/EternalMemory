//
//  DownloadModel.h
//  EternalMemory
//
//  Created by Guibing on 06/09/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//



#import "SavaData.h"
#import "FileModel.h"

typedef enum videoAndMusic
{
    fileVideo,
    fileMusic,
    homeType,
}fileDataType;

@interface DownloadModel : NSObject <ASIHTTPRequestDelegate>
{
    fileDataType isVideo;
}
@property (nonatomic,copy) void (^didDownloadCellProgressBlock)(long long pro);
//@property (nonatomic, retain) NSMutableArray *downloadList;//下载列表

//@property (nonatomic , copy) NSString *fileSize;            //下载文件大小


+ (DownloadModel*)shareInstance;

- (void)dicUploadingListAction:(NSInteger)index;
- (void)dicDownloadListAction:(NSDictionary *)dic downloadType:(NSString *)type isBeginDown:(BOOL)isDownload;

@end
