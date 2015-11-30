//
//  MusicViewCell.h
//  EternalMemory
//
//  Created by Guibing Li on 13-5-31.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MusicViewCellDelegate <NSObject>

@optional
- (void)didDeleteActionSheetBut:(NSInteger)index;
- (void)didPlayMusicBut:(id)index;
@end
@interface MusicViewCell : UITableViewCell

@property (nonatomic ,assign)id<MusicViewCellDelegate> delegate;
@property (nonatomic ,retain)UIImageView *playImage;
@property (nonatomic , retain)UILabel *musicName;
@property (nonatomic , retain)UILabel *playTime;
@property (nonatomic ,retain)UIButton *deleteBut;

@property (nonatomic ,retain)UIActivityIndicatorView *activityIndicatorView;
//@property (nonatomic ,retain)UIProgressView *progressV;
//@property (nonatomic,copy) void (^didDeleteActionSheetBlock)();
@end
