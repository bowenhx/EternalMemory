//
//  RecordPlayView.h
//  EternalMemory
//
//  Created by xiaoxiao on 2/24/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^StopListenRecord)(void);


@interface RecordPlayView : UIView
{
//    UIProgressView  *_progressView;//进度条
    UILabel     *_showTimeLabel;//时间展示
}
//@property(nonatomic,retain)UIProgressView *progressView;
@property(nonatomic,copy)StopListenRecord stopListenRecord;
@property(nonatomic,retain)UILabel  *showTimeLabel;

@end
