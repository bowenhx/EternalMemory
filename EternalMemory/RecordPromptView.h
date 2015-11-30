//
//  RecordPromptView.h
//  EternalMemory
//
//  Created by xiaoxiao on 2/24/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^StopRecord)(void);
typedef void(^DeleteRecord)(void);
typedef void(^UploadRecord)(void);
typedef void(^ListenRecord)(void);
typedef void(^StopListenRecord)(void);


@interface RecordPromptView : UIView
{
    UIView          *soundBackView;//半透明黑色背景图
    UIView          *lowerSoundBackView;//下层透明背景图
    UIImageView     *recordingView;//录音图片
    UIImageView     *volumeView;//音量大小图片
    UIButton        *confirmButton;//确定按钮
    UIButton        *deleteButton;//删除按钮
    UIButton        *stopButton;//停止录音按钮
    UILabel         *listenLabel;//文字提示按钮（试听、停止试听）
    UILabel         *timeLabel;//显示录音时间
    
    BOOL             _isRecord;//判断是否停止录音
    BOOL             _islisten;//判断是否在试听录音
}

@property(nonatomic,copy)StopRecord       stopRecord;
@property(nonatomic,copy)DeleteRecord     deleteRecord;
@property(nonatomic,copy)UploadRecord     uploadRecord;
@property(nonatomic,copy)ListenRecord     listenRecord;
@property(nonatomic,copy)StopListenRecord stopListenRecord;
@property(nonatomic,assign)BOOL           islisten;

- (id)initWithFrame:(CGRect)frame WithSelectPhoto:(BOOL)selectFromPhoto;
-(void)setsubViewFrameWithState:(NSInteger)rotation;

    
@end
