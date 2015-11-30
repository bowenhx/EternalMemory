//
//  ForbidInfo.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-23.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForbidInfo : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *address;

@property (nonatomic, copy) NSString *ieternalNum;

- (void)setDataWithDictionary:(NSDictionary *)dataDic;

@end
