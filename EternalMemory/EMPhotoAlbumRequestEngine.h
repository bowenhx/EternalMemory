//
//  EMPhotoAlbumRequestEngine.h
//  EternalMemory
//
//  Created by FFF on 14-3-11.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  一生记忆相册中所有的照片
 */
extern NSString * const kEMAlbumRequestEngineResultAlbumArray;
/**
 *  除一生记忆外所有的相册
 */
extern NSString * const kEMAlubmRequestEngineResultMemoPhotoArray;
/**
 *  一生记忆的相册
 */
extern NSString * const kEMAlbumRequestEngineResultLifeTimeAlbum;

typedef void(^EMPhotoAlbumRequestSuccessBlock)(NSDictionary *albums);
typedef void(^EMPhotoAlbumRequestFailureBlock)(id errorCode, id errorMsg);

@interface EMPhotoAlbumRequestEngine : NSObject

+ (instancetype)sharedEngine;

- (void)startRequest;

- (void)setSuccessBlock:(EMPhotoAlbumRequestSuccessBlock)successBlock;
- (void)setFailureBlock:(EMPhotoAlbumRequestFailureBlock)failureBlock;


@end
