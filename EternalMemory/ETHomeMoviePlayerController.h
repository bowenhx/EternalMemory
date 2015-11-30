//
//  ETHomeMoviePlayerController.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-8-26.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface ETHomeMoviePlayerController : UIViewController
{
    NSURL                       *_movieUrl;
    MPMoviePlayerController     *_moviePlayerController;
}

- (id)initWithURL:(NSURL*)url;

@end
