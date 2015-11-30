//
//  DiaryModel.m
//  EternalMemory
//
//  Created by sun on 13-6-4.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "MessageModel.h"
#import "Config.h"
#import "MD5.h"
#import "EMAudio.h"
#import "EMAlbumImage.h"

@implementation MessageModel
-(id)initWithDict:(NSDictionary *)dict{
    
    self = [super init];
    if (self) {
        
        
        _accessLevel =[[dict objectForKey:@"accessLevel"] copy];
        _blogId =[[dict objectForKey:@"blogId"] copy];
        _blogType =[[dict objectForKey:@"blogType"] copy];
        _ID =[[dict objectForKey:@"clientid"] intValue];
        _localBlogId =[[dict objectForKey:@"clientid"] copy];
        _content =[[dict objectForKey:@"content"]  copy];
        _summary =[[dict objectForKey:@"summary"]  copy];
        _createTime =[[dict objectForKey:@"createTime"] copy];
        _deletestatus =[[dict objectForKey:@"deleteStatus"] boolValue];
        _groupId =[[dict objectForKey:@"groupId"] copy];
        _lastModifyTime = [[dict objectForKey:@"lastModifyTime"] copy];
        _remark =[[dict objectForKey:@"remark"] copy];
        _syncTime=[[dict objectForKey:@"syncTime"] copy];
        _title =[[dict objectForKey:@"title"] copy];
        _userId =[[dict objectForKey:@"userId"] copy];
        _serverVer =[[dict objectForKey:@"versions"] copy];
        _attachURL      = [[dict objectForKey:@"attachURL"] copy];
        _thumbnail      = [[dict objectForKey:@"thumbnail"] copy];
        _groupname      = [[dict objectForKey:@"groupname"] copy];
        _tempSPath      = [[dict objectForKey:@"temp_paths"] copy];
        _tempPath       = [[dict objectForKey:@"temp_spaths"] copy];
        _photoWall = [dict[@"photowall"] copy];
        _theOrder  = [dict[@"theorder"] copy];
        
        EMAudio *audio = [EMAudio new];
        audio.audioURL = dict[@"voiceURL"];
        audio.size = [dict[@"voiceSize"] integerValue];
        audio.duration = [dict[@"duration"] integerValue];
        audio.audioStatus = EMAudioSyncStatusNone;
        
        _audio = audio;
                
    }
    return self;
}



- (void)setThumbnailImage:(UIImage *)thumbnailImage
{
    if (_thumbnailImage != thumbnailImage) {
        [_thumbnailImage release];
        _thumbnailImage = (EMAlbumImage *)[thumbnailImage retain];
    }
}

- (NSString *)pathForSavedThumbnailImageToLocalPath
{
    NSString *imageName      = [NSString stringWithFormat:@"simg_%@.png",self.thumbnail];
    NSString *localImageName = [MD5 md5:imageName];
    
    NSString *path           = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"ETMemory"] stringByAppendingPathComponent:@"Photos"];
    NSString *usernameStr    = USERID;
    NSString *imageRootPath  = [path stringByAppendingPathComponent:usernameStr];

    BOOL bo = [[NSFileManager defaultManager] createDirectoryAtPath:imageRootPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSAssert(bo,@"创建Diarys目录失败");
    
    NSString *fullPath = [imageRootPath stringByAppendingPathComponent:localImageName];
    
    NSData *imageData = UIImagePNGRepresentation(self.thumbnailImage);
    if ([imageData writeToFile:fullPath atomically:YES])
    {
        self.spaths = fullPath;
    }
    return fullPath;
}

- (void)getThumbnailImageFromLocalPath
{
    self.thumbnailImage = (EMAlbumImage *)[EMAlbumImage imageWithContentsOfFile:self.spaths];
}

- (UIImage *)thumbnailImageAtLocalPath
{
    UIImage *image = [EMAlbumImage imageWithContentsOfFile:self.spaths];
    return image;
}

- (BOOL)isEqual:(id)object
{
    [super isEqual:object];
    MessageModel *model = (MessageModel *)object;
    return [self.blogId isEqualToString:model.blogId];
}

//- (NSString *)description
//{
//    return [NSString stringWithFormat:@"blogID = %@, path = %@",self.blogId, self.paths];
//}
- (instancetype)deepCopy {
    MessageModel *model = [MessageModel new];
    model.blogId = [_blogId copy];
    model.blogType = [_blogType copy];
    model.content = [_content copy];
    model.summary = [_summary copy];
    model.title = [_title copy];
    model.groupId = [_groupId copy];
    model.groupname = [_groupname copy];
    model.accessLevel = [_accessLevel copy];
    model.attachURL = [_attachURL copy];
    model.thumbnail = [_thumbnail copy];
    model.paths = [_paths copy];
    model.spaths = [_spaths copy];
    model.serverVer = [_serverVer copy];
    model.localVer = [_localVer copy];
    model.status = [_status copy];
    model.size = [_size copy];
    model.createTime = [_createTime copy];
    model.lastModifyTime = [_lastModifyTime copy];
    model.syncTime = [_syncTime copy];
    model.remark = [_remark copy];
    model.userId = [_userId copy];
    model.tempPath = [_tempPath copy];
    model.tempSPath = [_tempSPath copy];
    model.photoWall = [_photoWall copy];
    model.theOrder = [_theOrder copy];
    model.templateImagePath = [_templateImagePath copy];
    model.templateImageURL = [_templateImageURL copy];
    model.thumbnailImage = [_thumbnailImage copy];
    model.rawImage = [_rawImage copy];
    return model;
}

- (id)copyWithZone:(NSZone *)zone {

    MessageModel *model = [[MessageModel allocWithZone:zone] init];
    model.blogId = [_blogId copy];
    model.blogType = [_blogType copy];
    model.content = [_content copy];
    model.summary = [_summary copy];
    model.title = [_title copy];
    model.groupId = [_groupId copy];
    model.groupname = [_groupname copy];
    model.accessLevel = [_accessLevel copy];
    model.attachURL = [_attachURL copy];
    model.thumbnail = [_thumbnail copy];
    model.paths = [_paths copy];
    model.spaths = [_spaths copy];
    model.serverVer = [_serverVer copy];
    model.localVer = [_localVer copy];
    model.status = [_status copy];
    model.size = [_size copy];
    model.createTime = [_createTime copy];
    model.lastModifyTime = [_lastModifyTime copy];
    model.syncTime = [_syncTime copy];
    model.remark = [_remark copy];
    model.userId = [_userId copy];
    model.tempPath = [_tempPath copy];
    model.tempSPath = [_tempSPath copy];
    model.photoWall = [_photoWall copy];
    model.theOrder = [_theOrder copy];
    model.templateImagePath = [_templateImagePath copy];
    model.templateImageURL = [_templateImageURL copy];
    model.thumbnailImage = [_thumbnailImage copy];
    model.rawImage = [_rawImage copy];
    return model;
}

-(void)dealloc
{
    
    RELEASE_SAFELY(_size);
    RELEASE_SAFELY(_status);
    RELEASE_SAFELY(_localVer);
    RELEASE_SAFELY(_paths);
    RELEASE_SAFELY(_spaths);
    RELEASE_SAFELY(_title);
    RELEASE_SAFELY(_content);
    RELEASE_SAFELY(_groupname);
    RELEASE_SAFELY(_attachURL);
    RELEASE_SAFELY(_thumbnail);
    RELEASE_SAFELY(_remark);
    RELEASE_SAFELY(_userId);
    RELEASE_SAFELY(_localBlogId);
    RELEASE_SAFELY(_accessLevel);
    RELEASE_SAFELY(_blogId);
    RELEASE_SAFELY(_createTime);
    RELEASE_SAFELY(_groupId);
    RELEASE_SAFELY(_lastModifyTime);
    RELEASE_SAFELY(_syncTime);
    RELEASE_SAFELY(_serverVer);
    RELEASE_SAFELY(_summary)
    RELEASE_SAFELY(_blogType);
    RELEASE_SAFELY(_tempPath);
    RELEASE_SAFELY(_tempSPath);
    RELEASE_SAFELY(_rawImage);
    RELEASE_SAFELY(_thumbnailImage);
    RELEASE_SAFELY(_audio);
    RELEASE_SAFELY(_photoWall);
    RELEASE_SAFELY(_theOrder);
    [super dealloc];

}


@end
