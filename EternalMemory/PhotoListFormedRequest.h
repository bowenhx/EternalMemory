//
//  PhotoListFormedRequest.h
//  EternalMemory
//
//  Created by FFF on 13-12-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//


@class MessageModel;

@interface PhotoListFormedRequest : ASIFormDataRequest

- (void)setupRequestForGettingPhotoList;
- (void)setupRequestForDeletingPhoto:(MessageModel *)model;
- (void)setupRequestForDeletingPhotoWithBlogid:(NSString *)blogid;
- (void)setupRequestForUpdatePhotoDes:(MessageModel *)model;

- (NSArray *)handleRequestResultForGroupId:(NSString *)groupId;

- (BOOL)handleDeletingRequest;
- (NSDictionary *)requestForUpdatingPhotoDesSuccess;

@end
