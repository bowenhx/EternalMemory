//
//  AssociatedInfoInputView.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-24.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "AssociatedInfoInputView.h"
#import "GenealogyMetaData.h"
#import "MyToast.h"
#import <QuartzCore/QuartzCore.h>

@interface AssociatedInfoInputView ()

@property (nonatomic, copy) NSString  *hintText;
@property (nonatomic, retain) NSMutableArray *textFieldTags;
@property (nonatomic, retain) NSMutableDictionary *dic;


@end

@implementation AssociatedInfoInputView

- (void)dealloc
{
    [_hintText release];
    [_titleLabel release];
    [_btnPressedBlock release];
    [_textFieldTags release];
    [_dic release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithAssociationType:(AssociationType)type
{
    _associationType = type;
    NSUInteger numOfTextField = 0;
    CGRect frame = CGRectZero;
    

    
    switch (type) {
            
        case AssociationTypeEternalcode:
        {
            frame = CGRectMake(0, 0, SCREEN_WIDTH - 80, 200);
            numOfTextField = 2;
            break;
        }
        case AssociationTypeAuthcode:
        {
            frame = CGRectMake(0, 0, SCREEN_WIDTH - 80, 150);
            numOfTextField = 1;
            break;
        }
            
        default:
            self.frame = frame;
            break;
    }
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = RGBCOLOR(221, 221, 221);
        self.layer.cornerRadius = 10.f;
        self.alpha = 0.8;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        
        [self layoutSubviewsWithTextField:numOfTextField];

    }
    
    return self;
}

- (void)layoutSubviewsWithTextField:(NSUInteger)num
{
    
    _textFieldTags = [[NSMutableArray alloc] initWithCapacity:0];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"请输入";
    [self addSubview:_titleLabel];
    
    NSArray *arr = nil;
    (num == 2) ? (arr = @[@" 请输入永恒号",@" 请输入授权码(8位)"]) : (arr = @[@"请输入授权码"]);
    
    for (int i = 0 ; i < num; i ++) {
        
        CGFloat height = 30;
        CGFloat offset = 13;
        CGFloat y = 50 + i * (height + offset);
        UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(10, y, self.frame.size.width - 20, height)];
        textfield.placeholder = arr[i];
        textfield.keyboardType = UIKeyboardTypeAlphabet;
        textfield.delegate = self;
        textfield.tag = i + 100;
        textfield.borderStyle = UITextBorderStyleNone;
        textfield.layer.cornerRadius = 4;
        textfield.backgroundColor = [UIColor whiteColor];
        textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self addSubview:textfield];
        [textfield release];
        
        if (i == 0) {
            [self performSelector:@selector(setTextFieldRespond:) withObject:textfield afterDelay:0.3];
        }
        
        [_textFieldTags addObject:@(textfield.tag)];
        
    }
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(10, 0, self.frame.size.width - 20, 30);
    confirmBtn.center = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 35);
    confirmBtn.backgroundColor = [UIColor colorWithRed:32/255. green:156/255. blue:215/255. alpha:0.8];
    [confirmBtn addTarget:self action:@selector(confirmBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self addSubview:confirmBtn];
    
}



- (void)setTextFieldRespond:(UITextField *)textField
{
    [textField becomeFirstResponder];
}

- (void)confirmBtnPressed:(id)sender
{
    for (NSNumber *tag in _textFieldTags) {
        NSInteger aTag = tag.integerValue;
        UITextField *textField = (UITextField *)[self viewWithTag:aTag];
        if (textField.text.length <= 0) {
            [MyToast showWithText:@"请将数据填写完整" :130];
            return;
        }
        [textField resignFirstResponder];
    }
    
    if (_btnPressedBlock) {
        _btnPressedBlock(_dic,_associationType);
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (_associationType == AssociationTypeAuthcode) {
        _dic[kAssociateAuthCode] = textField.text;
    }
    if (_associationType == AssociationTypeEternalcode) {
        NSInteger tag = textField.tag;
        NSString *authcode = nil;
        NSString *eteralnum = nil;
        if (tag == 100) {
            eteralnum = textField.text;
            _dic[kAssociateValue] = eteralnum;
        }
        if (tag == 101) {
            authcode = textField.text;
            _dic[kAssociateAuthCode] = authcode;
        }
    
    }
    
    
    return YES;
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
