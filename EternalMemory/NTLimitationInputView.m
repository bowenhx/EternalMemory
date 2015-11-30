//
//  LimitationTextView.m
//  LimitationTextViewDemo
//
//  Created by FFF on 13-12-19.
//  Copyright (c) 2013年 dvlprliu. All rights reserved.
//

#import "NTLimitationInputView.h"
#import "LimitePasteTextView.h"
@import QuartzCore;

#define CAPACITY_LABEL_HEIGHT       15

@interface NTLimitationInputView () <UITextViewDelegate>

@property (nonatomic, strong) UILabel *capacityLabel;

@end


@implementation NTLimitationInputView

@synthesize string = _string;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _maxLength = 0 ;

        [self initilazeTextView];
        [self initilazeCapacityLabel];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initilazeTextView];
    [self initilazeCapacityLabel];
}

- (void)initilazeTextView
{
    if (!_textView) {
        
        __block typeof(self) bself = self;
        LPCommonBlock didPasteBlock = ^(NSInteger length){
            [bself setCurrentCapacityWithCurrenLength:length];
        };
        _textView = [[LimitePasteTextView alloc] initWithFrame:(CGRect){
            .origin.x = 0,
            .origin.y = 0,
            .size.width  = self.frame.size.width,
            .size.height = self.frame.size.height - CAPACITY_LABEL_HEIGHT
        }];
        _textView.delegate = self;
        _textView.editable = YES;
        _textView.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15];
        _textView.backgroundColor = [UIColor clearColor];
        UIColor *_color = [UIColor grayColor];
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"请输入照片描述" attributes:@{NSForegroundColorAttributeName: _color}];
        _textView.attributedText = str;
        [str release];
        _textView.didPasteBlock = didPasteBlock;
        [self addSubview:_textView];

    }
}
- (void)initilazeCapacityLabel
{
    if (!_capacityLabel) {
        
        _capacityLabel = [[UILabel alloc] initWithFrame:(CGRect){
            .origin.x = 5,
            .origin.y = self.frame.size.height - CAPACITY_LABEL_HEIGHT,
            .size.width  = self.frame.size.width - 10,
            .size.height = CAPACITY_LABEL_HEIGHT
        }];
        _capacityLabel.backgroundColor = [UIColor clearColor];
        _capacityLabel.textAlignment = NSTextAlignmentRight;
        _capacityLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14];
        _capacityLabel.textColor = [UIColor blackColor];
        _capacityLabel.text = [NSString stringWithFormat:@"%ld",(long)_maxLength];
        _capacityLabel.hidden = YES;
        [self addSubview:_capacityLabel];
    }
}

- (void)setMaxLength:(NSInteger)maxLength
{
    _maxLength = maxLength;
    _textView.pasteStringLengthLimitation = maxLength;
    _capacityLabel.text = [NSString stringWithFormat:@"%ld",(long)_maxLength];
}

- (void)setCurrentCapacityWithCurrenLength:(NSInteger)currentLength
{
    NSInteger currentCapacity = _maxLength - currentLength;
    
    _capacityLabel.text = [NSString stringWithFormat:@"%ld",(long)currentCapacity];
    if (currentCapacity < 0) {
        _capacityLabel.textColor = [UIColor redColor];
    } else {
        _capacityLabel.textColor = [UIColor blackColor];
    }
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    
    NSInteger currentLength = textView.text.length;
    [self setCurrentCapacityWithCurrenLength:currentLength];
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    _capacityLabel.hidden = NO;
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    
    _capacityLabel.hidden = YES;

}
- (NSString *)string
{
    return self.textView.text;
}

- (void)setString:(NSString *)string
{
    if (_string != string) {
        [_string release];
        _string = [string copy];
    }
    
    self.textView.text = _string;
    [self setCurrentCapacityWithCurrenLength:_string.length];
}

- (void)dealloc
{
    [super dealloc];
}


@end
