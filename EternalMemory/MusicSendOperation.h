//
//  MusicSendOperation.h
//  EternalMemory
//
//  Created by yanggongfu on 7/19/13.
//  Copyright (c) 2013 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface MusicSendOperation : NSOperation<ASIHTTPRequestDelegate>
{
    NSString *nameStr;//音乐名字
    MPMediaItemCollection *mediaItem;
}

@property(nonatomic,retain)    ASIFormDataRequest *dataRequest;


-(id)initWithName:(NSString *)name WithmediaItem:(MPMediaItemCollection *)mediaitem;

-(void)sendMusic;

- (void)uplodingMusic:(NSData *)data musicName:(NSString *)name musicArtist:(NSString *)artist musicIntro:(NSString *)intro;

@end
