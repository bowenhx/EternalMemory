//
//  EMAllLifeMemoDAO.h
//  EternalMemory
//
//  Created by FFF on 14-3-17.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MessageModel;
@class DiaryPictureClassificationModel;
@interface EMAllLifeMemoDAO : NSObject

+ (instancetype)sharedInstance;

@end

@interface EMAllLifeMemoDAO (threadsafe)

- (void)insertModelSafely:(NSArray *)models;

@end


@interface EMAllLifeMemoDAO (insertertion)

+ (void)insertMemoModels:(NSArray *)model;
+ (void)insertMemoModel:(MessageModel *)model;

@end

@interface EMAllLifeMemoDAO (deletation)

+ (void)deleteAllMemos;

@end

@interface EMAllLifeMemoDAO (update)

+ (void)updateMemoModels:(NSArray *)models AndStatus:(NSString *)status;
+ (void)updateMemoPath:(NSString *)path ForBlogId:(NSString *)blogId;
+ (void)updateMemoPath:(NSString *)path forPhotoWall:(NSString *)photoWall;
+ (void)updateTemplatePath:(NSString *)path forPhotoWall:(NSString *)photoWall;

@end

@interface EMAllLifeMemoDAO (query)

+ (NSArray *)allMemoModels;
+ (DiaryPictureClassificationModel *)getMemoAudio;
+ (MessageModel *)modelAtCertainWall:(NSString *)photoWall;
+ (NSString *)templateImagePathForCertainWall:(NSString *)photoWall;

@end
