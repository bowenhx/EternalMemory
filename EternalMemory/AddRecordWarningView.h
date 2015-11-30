//
//  AddRecordWarningView.h
//  EternalMemory
//
//  Created by xiaoxiao on 2/24/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMAudio.h"
typedef void(^MakeRecord)(void);
typedef void(^PlayRecord)(void);
typedef void(^StopRecord)(void);

typedef enum RecordState {
	RecordStateMake = 0,
    RecordStateReadyPlay,
    RecordStateStop,
    RecordStateUpload,
} RecordState;


@interface AddRecordWarningView : UIView


@property(nonatomic,retain)UILabel        *testLabel;
@property(nonatomic,retain)UIImageView    *stateImageView;
@property(nonatomic,assign)RecordState     recordState;
@property(nonatomic,copy)  MakeRecord      makeRecord;
@property(nonatomic,copy)  PlayRecord      playRecord;
@property(nonatomic,copy)  StopRecord      stopRecord;

-(void)setsubViewFrame;
    
-(void)setRecordState:(RecordState)recordState WithEMAudio:(EMAudio *)audio;


@end
