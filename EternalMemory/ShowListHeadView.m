//
//  ShowListHeadView.m
//  EternalMemory
//
//  Created by Guibing on 13-7-13.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "ShowListHeadView.h"

@implementation ShowListHeadView
@synthesize downLabText = _downLabText;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self initView];
    }
    return self;
}
- (void)initView
{
    //上传与下载图片
    UIImageView *viewUplod = [[UIImageView alloc] initWithFrame:CGRectMake(10, 14, 20, 16)];
    viewUplod.image = [UIImage imageNamed:@"list_up_down_image"];
    [self addSubview:viewUplod];
    [viewUplod release];
    
    //描述文字
    _downLabText = [[UILabel alloc] initWithFrame:CGRectMake(40, 6, self.bounds.size.width - 80, 30)];
    _downLabText.text = @"";
    _downLabText.font = [UIFont boldSystemFontOfSize:14];
    _downLabText.textAlignment = NSTextAlignmentCenter;
    _downLabText.textColor = RGBCOLOR(196, 198, 197);
    _downLabText.backgroundColor = [UIColor clearColor];
    [self addSubview:_downLabText];
    
    //右侧配饰图片
    UIImageView *imageMack = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-20, 15, 10, 14)];
    imageMack.image = [UIImage imageNamed:@"list_up_down_mark"];
    [self addSubview:imageMack];
    [imageMack release];
    
    

}
- (void)dealloc
{
    [_downLabText release];
    [super dealloc];
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
