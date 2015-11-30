//
//  UploadingListCell.h
//  EternalMemory
//
//  Created by Guibing on 13-6-18.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^StopOrResume)(BOOL stop,int index);
typedef void(^RemoveUploadFile)(int index);

@interface UploadingListCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *labTitle;
@property (retain, nonatomic) IBOutlet UILabel *labNum;
@property (retain, nonatomic) IBOutlet UIProgressView *progress;
@property (retain, nonatomic) __block IBOutlet UIButton *delectBut;
@property (retain, nonatomic) IBOutlet UILabel *labStopDown;
@property (retain, nonatomic) __block IBOutlet UIButton *resumeButton;


@property(nonatomic,copy)  StopOrResume       StopOrResume;
@property(nonatomic,copy)  RemoveUploadFile   removeUpLoadFile;


- (IBAction)stopOrResumeUpload:(id)sender;
- (IBAction)removeUploadFile:(id)sender;

@end
