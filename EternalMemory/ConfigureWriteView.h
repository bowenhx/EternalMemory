//
//  ConfigureWriteView.h
//  EternalMemory
//
//  Created by SuperAdmin on 13-11-11.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConfigureWriteViewDelegate <NSObject>

//coverflow
-(void)showCoverFlow;
//设置字体颜色
-(void)setTextColor;
//隐藏、显示设置界面
-(void)setViewHide:(BOOL)Hide;

@end

@interface ConfigureWriteView : UIView
{
    id<ConfigureWriteViewDelegate> _delegate;
}

@property(nonatomic,assign)id<ConfigureWriteViewDelegate> delegate;

@end
