//
//  LimitePasteTextView.m
//  EternalMemory
//
//  Created by FFF on 13-12-19.
//  Copyright (c) 2013年 dvlprliu. All rights reserved.
//

#import "LimitePasteTextView.h"

NSString * const DidPasteContentNotification = @"DidPasteContentNotification";

@implementation LimitePasteTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(paste:) || action == @selector(copy:));
}

- (void)paste:(id)sender
{
    UIPasteboard *pastBoard = [UIPasteboard generalPasteboard];
    NSString *string = pastBoard.string;
    if (string.length >  _pasteStringLengthLimitation) {
        self.text = [string substringToIndex:_pasteStringLengthLimitation];
    }
    
    if (_didPasteBlock) {
        _didPasteBlock(self.text.length);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DidPasteContentNotification object:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
