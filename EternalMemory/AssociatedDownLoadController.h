//
//  AssociatedDownLoadController.h
//  EternalMemory
//
//  Created by xiaoxiao on 1/13/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import "CustomNavBarController.h"


typedef NS_ENUM(NSInteger, AssocaitedLocation)
{
    AssocaitedLocationGroup = 0,
    AssocaitedLocationVedio,
    AssocaitedLocationStyleModel,
    AssocaitedLocationPhoto,
    AssocaitedLocationMusic,
    AssocaitedLocationAudio,
};


@interface AssociatedDownLoadController : CustomNavBarController<UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate,UIAlertViewDelegate>

@property(nonatomic,retain)NSMutableArray *associatedArray;

-(void)httpRequestSucess:(ASIHTTPRequest *)request;
-(void)httpRequestFail:(ASIHTTPRequest *)request;


@end

