//
//  VedioSendOperation.h
//  EternalMemory
//
//  Created by yanggongfu on 7/22/13.
//  Copyright (c) 2013 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface VedioSendOperation : NSOperation<ASIHTTPRequestDelegate>

@property(nonatomic,retain)    ASIFormDataRequest *dataRequest;

-(id)initWithVedioName:(NSString *)vedioName VedioPath:(NSString *)vedioPath VedioContent:(NSString *)vedioContent SwitchState:(BOOL)showPublic;

@end
