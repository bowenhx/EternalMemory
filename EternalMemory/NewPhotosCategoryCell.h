//
//  NewPhotosCategoryCell.h
//  EternalMemory
//
//  Created by sun on 13-5-23.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMWTextView.h"

@interface NewPhotosCategoryCell : UITableViewCell<UITextViewDelegate>
@property (nonatomic, retain) IBOutlet UILabel *lable;
@property (nonatomic, retain) IBOutlet RMWTextView *textView;
@property (nonatomic, retain) NSString *textViewText;
+(NewPhotosCategoryCell *)viewForNib;
@end
