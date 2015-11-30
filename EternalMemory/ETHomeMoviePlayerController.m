//
//  ETHomeMoviePlayerController.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-8-26.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "ETHomeMoviePlayerController.h"

@implementation ETHomeMoviePlayerController

- (void)dealloc
{
    [_moviePlayerController release];
    
    [super dealloc];
}

- (id)initWithURL:(NSURL *)url
{
    if (self = [super init]) {
        _movieUrl = url;
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:_movieUrl];
    _moviePlayerController.view.frame = self.view.bounds;
    _moviePlayerController.shouldAutoplay = YES;
    _moviePlayerController.controlStyle = MPMovieControlStyleEmbedded;
    [_moviePlayerController play];
    
    [self.view addSubview:_moviePlayerController.view];
    
}

@end
