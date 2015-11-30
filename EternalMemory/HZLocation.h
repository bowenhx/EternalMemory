//
//  HZLocation.h
//  areapicker
//
//  Created by Cloud Dai on 12-9-9.
//  Copyright (c) 2012年 clouddai.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HZLocation : NSObject

@property (copy, nonatomic) NSString *country;
@property (copy, nonatomic) NSMutableDictionary *state;
@property (copy, nonatomic) NSMutableDictionary *city;
@property (copy, nonatomic) NSMutableDictionary *district;
@property (copy, nonatomic) NSMutableDictionary *street;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
-(id)init;
@end
