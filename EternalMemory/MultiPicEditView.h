//
//  MultiPicEditView.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-8-26.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ShowActionSheetBlock)(void);
typedef void(^ChoseGroupBlock)(void);

@interface MultiPicEditView : UIView<UITextViewDelegate>
{
    UITextView              *_photoDesTextView;
    UIButton                *_addPhtotButt;
    UILabel                 *_textLabel;
    UIImageView             *_seperateLine;
    UIImageView             *_foreSqureImageView;
    UIButton                *_choseGroupButton;
    UIImageView             *_arrowImageView;
}

@property (nonatomic, retain) UIButton           *choseGroupButton;
@property (nonatomic, copy) ShowActionSheetBlock showActionSheetBlock;
@property (nonatomic, copy) ChoseGroupBlock      choseGroupBlock;
@property (nonatomic, retain) UITextView         *photoDesTextView;

- (void)setGroupButtonTitle:(NSString *)title;

@end
