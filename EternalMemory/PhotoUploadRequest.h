//
//  PhotoUploadEngine.h
//  EternalMemory
//
//  Created by FFF on 13-12-11.
//  Copyright (c) 2013年 sun. All rights reserved.
//


#define kModel          @"model"

@interface PhotoUploadRequest : ASIFormDataRequest


- (void)setupRequestForUplodingImage:(UIImage *)image groupid:(NSString *)groupid;
- (void)setupRequestForUplodingImageData:(NSData *)imageData;
@end