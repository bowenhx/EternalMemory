//
//  OffLineDownLoadCell.h
//  EternalMemory
//
//  Created by xiaoxiao on 12/6/13.
//  Copyright (c) 2013 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DDProgressView.h"

@interface OffLineDownLoadCell : UITableViewCell


//@property(nonatomic,retain)UIImageView      *typeImage;
//@property(nonatomic,retain)UILabel          *nameLabel;
//@property(nonatomic,retain)UILabel          *percentageLabel;
//@property(nonatomic,retain)UIButton         *reLoadButton;
//@property(nonatomic,retain)UIButton         *deleteButton;
//@property(nonatomic,retain)UIProgressView   *progressView;

@property(nonatomic,retain)UIButton         *reloadButton;
@property(nonatomic,retain)UIButton         *cancelButton;
@property(nonatomic,retain)UIView           *separatorView;

@property(nonatomic,retain)UILabel          *nameLabel;

//失败列表下载时显示的数据
@property(nonatomic,retain)UILabel          *downlingNameLable;
@property(nonatomic,retain)UILabel          *percentageLabel;
@property(nonatomic,retain)DDProgressView   *progressView;


@property(nonatomic,assign)NSInteger         waitingLoad;

@property(nonatomic,copy)  void(^Dismiss)();
@property(nonatomic,copy)  void(^Reload)();


@end
