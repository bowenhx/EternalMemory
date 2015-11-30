//
//  SweepInviteViewController.h
//  PeopleBaseNetwork
//
//  Created by kiri on 13-3-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CustomNavBarController.h"
#import "ZBarSDK.h"

@interface SweepNotourViewController : CustomNavBarController<NavBarDelegate>{
    UIImageView *imageview;
    UILabel     *label;
}
@property(nonatomic,retain)NSString *sweepResults;
@end
