//
//  City.h
//  EternalMemory
//
//  Created by kiri on 13-9-7.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface City : NSObject
+(NSMutableArray *)getProvinceNameAndId;
+(NSMutableArray *)getCityForstate:(NSInteger)stateId;
+(NSMutableArray *)getDistrictForCity:(NSInteger)cityId;
@end
