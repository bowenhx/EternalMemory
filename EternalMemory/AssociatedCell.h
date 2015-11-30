//
//  AssociatedCell.h
//  EternalMemory
//
//  Created by xiaoxiao on 1/13/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressDownloadView.h"

typedef void(^DownLoadButtonEvent)(int index);

@interface AssociatedCell : UITableViewCell

//下载显示view
@property(nonatomic,copy)  DownLoadButtonEvent     downloadEvent;
//前面显示的顺序按钮背景图片
@property(nonatomic,retain)UIImageView            *backImageView;
//显示顺序的label
@property(nonatomic,retain)UILabel                *numberLabel;
//进度条UI
@property(nonatomic,retain)ProgressDownloadView   *progressView;
//关系
@property(nonatomic,retain)UILabel                *relationLabel;
//下载控制按钮
@property(nonatomic,retain)UIButton               *downLoadButton;
//姓名
@property(nonatomic,retain)UILabel                *nameLabel;
//设置等待状态
@property(nonatomic,assign)NSInteger               waitingLoad;

@end
