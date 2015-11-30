//
//  ProgressDownloadView.h
//  EternalMemory
//
//  Created by xiaoxiao on 1/13/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDProgressView.h"


typedef void(^CancelDownload)(int index);

@interface ProgressDownloadView : UIView

//取消下载
@property(nonatomic,copy)CancelDownload    cancelDownload;
//进度显示
@property(nonatomic,retain)DDProgressView *progressView;

//进度百分比
@property(nonatomic,retain)UILabel *percentageLabel;


//背景图片
@property(nonatomic,retain)UIImageView *bgImageView;


//控制按钮
@property(nonatomic,retain)UIButton *controlButton;


@end
