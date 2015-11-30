//
//  MultiPicEditView.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-8-26.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "MultiPicEditView.h"

#import <QuartzCore/QuartzCore.h>

@implementation MultiPicEditView

- (void)dealloc
{
    [_showActionSheetBlock release];
    [_choseGroupBlock release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(1, 1);
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        self.backgroundColor = [UIColor whiteColor];

        
    }
    return self;
}

- (void)setGroupButtonTitle:(NSString *)title
{
    [_choseGroupButton setTitle:title forState:UIControlStateNormal];
}

- (void)setupTextView
{
    _photoDesTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 10, self.frame.size.width - 10, 90)];
    _photoDesTextView.text = @"请输入照片描述";
    _photoDesTextView.delegate = self;
    _photoDesTextView.font = [UIFont systemFontOfSize:15];
    _photoDesTextView.textColor = RGBCOLOR(99, 112, 120);
    [self addSubview:_photoDesTextView];
    
    [_photoDesTextView release];
}

- (void)setupSeperateLine
{
    UIImage *line = [UIImage imageNamed:@"dtfgx.png"];
    _seperateLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 122, SCREEN_WIDTH, line.size.height)];
    [_seperateLine setImage:line];
    [self addSubview:_seperateLine];
    [_seperateLine release];
    
}

- (void)setupAddPhotoButton
{
    UIImage *addPhotoImage = [UIImage imageNamed:@"dxt.png"];
    _addPhtotButt = [UIButton buttonWithType:UIButtonTypeCustom];
    _addPhtotButt.frame = CGRectMake(8, 127, 30, 30);
    [_addPhtotButt setImage:addPhotoImage forState:UIControlStateNormal];
    [_addPhtotButt addTarget:self action:@selector(addPhotos:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addPhtotButt];
}

- (void)setuptextLabel
{
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 127, 65, 30)];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.text = @"上传到";
    _textLabel.font = [UIFont systemFontOfSize:15];
    _textLabel.textColor = RGBCOLOR(99, 112, 120);
    [self addSubview:_textLabel];
    [_textLabel release];
    
}

- (void)setupChoseGroupView
{
    UIImage *foreSqureImage = [UIImage imageNamed:@"fltb.png"];
    UIImage *arrowImage     = [UIImage imageNamed:@"jt_right.png"];
    
    _foreSqureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 136, 13, 13)];
    [_foreSqureImageView setImage:foreSqureImage];
    [self addSubview:_foreSqureImageView];
    [_foreSqureImageView release];
    
    _choseGroupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_choseGroupButton setFrame:CGRectMake(220, 124, 80, 36)];
    [_choseGroupButton setBackgroundColor:[UIColor clearColor]];
    _choseGroupButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_choseGroupButton setTitle:@"默认相册" forState:UIControlStateNormal];
    [_choseGroupButton setTitleColor:RGBCOLOR(96, 113, 129) forState:UIControlStateNormal];
    _choseGroupButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_choseGroupButton addTarget:self action:@selector(choseGroup:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_choseGroupButton];
    
    _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 10, 136, 8, 13)];
    [_arrowImageView setImage:arrowImage];
    [self addSubview:_arrowImageView];
    [_arrowImageView release];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    NSLog(@" called ----------");
    [self setupTextView];
    [self setupSeperateLine];
    [self setupAddPhotoButton];
    [self setuptextLabel];
    [self setupChoseGroupView];
}

- (void)addPhotos:(id)sender
{
    if (_showActionSheetBlock) {
        _showActionSheetBlock();
    }
}

- (void)choseGroup:(id)sender
{
    if (_choseGroupBlock) {
        _choseGroupBlock();
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_photoDesTextView resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"请输入照片描述"]) {
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0) {
        textView.text = @"请输入照片描述";
    }
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
