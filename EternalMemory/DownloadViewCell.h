//
//  DownloadViewCell.h
//  EternalMemory
//
//  Created by Guibing on 06/09/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//



@interface DownloadViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *imageVideo;
@property (retain, nonatomic) IBOutlet UIButton *downloadBut;
@property (retain, nonatomic) IBOutlet UIButton *delectBut;

@property (retain, nonatomic) IBOutlet UILabel *fileName;
@property (retain, nonatomic) IBOutlet UILabel *fileNum;
@property (retain, nonatomic) IBOutlet UIProgressView *progress;
@property (retain, nonatomic) IBOutlet UILabel *labStopDown;

@end
