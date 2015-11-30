//
//  StyleSelectListViewCtrl.h
//  EternalMemory
//
//  Created by Guibing on 13-8-20.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
@class DownLoadButton;
@interface HomeStyleBgView : UIScrollView
{
}

@end
//每个风格下面的小view，用来显示进度条，下载和删除按钮
@interface  HomeStyleBgViewSubView : UIView

@property (nonatomic , retain)UIProgressView *progress;
@property (nonatomic , retain)DownLoadButton *downloadBut;
@property (nonatomic , retain)UIButton *delectBut;
@property (nonatomic , retain)UILabel *textLab;
@end

@interface StyleSelectListViewCtrl : CustomNavBarController<ASIHTTPRequestDelegate,UIAlertViewDelegate,UIScrollViewDelegate>{
    
   
}
@property (retain, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (retain, nonatomic) IBOutlet UIScrollView *titleScrollView;

+ (void)offLineStyleSelect:(NSString *)styleID;
@end
