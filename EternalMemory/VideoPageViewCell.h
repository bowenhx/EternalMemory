//
//  VideoPageViewCell.h
//  EternalMemory
//
//  Created by Guibing on 13-6-5.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol VideoPageViewCellDelegate <NSObject>

@optional
- (void)didDeleteVideoSheetBut:(NSInteger)index;
- (void)didSelectDownloadingVideo:(NSInteger)index isHint:(BOOL)isHint;

@end
@interface VideoPageViewCell : UITableViewCell
{
}
@property (nonatomic , assign)id<VideoPageViewCellDelegate>delegate;
@property (nonatomic , retain)UILabel *labText;
@property (nonatomic , readonly)UILabel *labTextNum;
@property (nonatomic , readonly)UIImageView *imageThumbnail;
@property (nonatomic , retain)UIButton *deleteBut;
@property (nonatomic , readonly)UIButton *downloadBut;

@end
