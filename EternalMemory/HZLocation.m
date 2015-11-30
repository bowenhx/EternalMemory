//
//  HZLocation.m
//  areapicker
//
//  Created by Cloud Dai on 12-9-9.
//  Copyright (c) 2012年 clouddai.com. All rights reserved.
//

#import "HZLocation.h"

@implementation HZLocation

@synthesize country = _country;
@synthesize state = _state;
@synthesize city = _city;
@synthesize district = _district;
@synthesize street = _street;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

-(void)dealloc{
    
    [_state release];
    [_city release];
    [_district release];
    [super dealloc];
}
-(id)init{
    self = [super init];
    if (self) {
        _state = [[NSMutableDictionary alloc] initWithCapacity:0];
        _city = [[NSMutableDictionary alloc] initWithCapacity:0];
        _district = [[NSMutableDictionary alloc] initWithCapacity:0];
        
    }
    return self;
}
@end
