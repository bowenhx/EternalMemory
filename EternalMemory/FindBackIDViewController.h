//
//  FindBackIDViewController.h
//  EternalMemory
//
//  Created by zhaogl on 13-12-12.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "CustomNavBarController.h"

@interface FindBackIDViewController : CustomNavBarController<
    NavBarDelegate,
    UIWebViewDelegate>


@property(nonatomic,retain)NSURL *url;
@end
