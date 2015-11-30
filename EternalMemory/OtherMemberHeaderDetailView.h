//
//  OtherMemberHeaderDetailView.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-16.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtherMemberHeaderDetailView : UIView

- (instancetype)initWithNib;
- (void)configData:(NSDictionary *)data andParentType:(NSString *)type;

@end
