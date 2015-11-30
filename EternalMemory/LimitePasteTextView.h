//
//  LimitePasteTextView.h
//  EternalMemory
//
//  Created by FFF on 13-12-19.
//  Copyright (c) 2013年 dvlprliu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LPCommonBlock)(NSInteger);

extern NSString * const DidPasteContentNotification;

@interface LimitePasteTextView : UITextView

@property (nonatomic, assign) NSInteger pasteStringLengthLimitation;
@property (nonatomic, copy)   LPCommonBlock didPasteBlock;

@end
