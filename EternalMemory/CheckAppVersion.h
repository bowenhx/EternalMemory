//
//  CheckAppVersion.h
//  EternalMemory
//
//  Created by zhaogl on 14-3-27.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface CheckAppVersion : NSObject<ASIHTTPRequestDelegate>{
    
}


+(void)checkAppVersionFromWhere:(UIViewController *)where;
@end
