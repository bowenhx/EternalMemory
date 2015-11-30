//
//  PhotoUploadEngine.m
//  EternalMemory
//
//  Created by FFF on 13-12-11.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "PhotoUploadRequest.h"
#import "UIImage+UIImageExt.h"
#import "SavaData.h"
#import "EMMemorizeMessageModel.h"

@implementation PhotoUploadRequest


- (void)setCommonPostValue
{
    [self setRequestMethod:@"POST"];
    [self setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];

    [self setPostValue:USER_AUTH_GETOUT  forKey:@"serverauth"];
    
}

- (void)setupRequestForUplodingImage:(UIImage *)image groupid:(NSString *)groupid
{
    [self setCommonPostValue];
    //[self setPostValue:@"0" forKey:@"blogtype"];
    [self setPostValue:groupid forKey:@"groupid"];
    [self setPostValue:@""  forKey:@"content"];
    
    //压缩图片质量
//    UIImage *aImage = [image fixOrientation];
    NSData *imgData = UIImageJPEGRepresentation(image, 0.3);
    NSString *name = [NSString stringWithFormat:@"img%lu.png",(unsigned long)image.hash];
    [self addData:imgData withFileName:name andContentType:@"image/jpg" forKey:@"upfile"];
    [self setTimeOutSeconds:30.0];

}

- (void)setupRequestForUplodingImageData:(NSData *)imageData
{
    [self setCommonPostValue];
    [self setPostValue:@"0" forKey:@"blogtype"];
    [self setPostValue:@"0" forKey:@"groupid"];
    [self setPostValue:@""  forKey:@"content"];
    
    //压缩图片质量

    NSString *name = [NSString stringWithFormat:@"img%lu.png",(unsigned long)imageData.hash];
    [self addData:imageData withFileName:name andContentType:@"image/jpg" forKey:@"upfile"];
    [self setTimeOutSeconds:30.0];
}


@end
