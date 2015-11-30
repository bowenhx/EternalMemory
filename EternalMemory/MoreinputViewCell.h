//
//  MoreinputViewCell.h
//  EternalMemory
//
//  Created by Guibing Li on 13-5-23.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreinputViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *labTextRoom;
@property (retain, nonatomic) IBOutlet UILabel *labTextRoomNum;
@property (retain, nonatomic) IBOutlet UIProgressView *progressNum;
@property (retain, nonatomic) IBOutlet UILabel *labTextTime;
@property (retain, nonatomic) IBOutlet UILabel *labTextTimeNum;

@end
