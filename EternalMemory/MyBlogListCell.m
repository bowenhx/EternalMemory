//
//  MyBlogListCell.m
//  EternalMemory
//
//  Created by sun on 13-5-31.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "MyBlogListCell.h"
#import "CommonData.h"
@implementation MyBlogListCell
@synthesize dateLb = _dateLb;
@synthesize titleLb = _titleLb;
@synthesize bodyTextView = _bodyTextView;
@synthesize m_checkImageView = _m_checkImageView;
@synthesize m_checked = _m_checked;
@synthesize line = _line;
+(MyBlogListCell *)viewForNib
{
    UIViewController *_cellController = [[UIViewController alloc] initWithNibName:@"MyBlogListCell" bundle:nil];
    MyBlogListCell *_cell = (MyBlogListCell *)_cellController.view;
    [_cellController release];
    return _cell;
}
- (void)dealloc{
   
    RELEASE_SAFELY(_dateLb);
    RELEASE_SAFELY(_titleLb);
    RELEASE_SAFELY(_bodyTextView);
    RELEASE_SAFELY(_m_checkImageView);
    RELEASE_SAFELY(_line);
    [super dealloc];
}
- (void)setData:(DiaryMessageModel *)model
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *dateStr = [NSDate dateWithTimeIntervalSince1970:[model.createTime doubleValue] / 1000];
    
    NSString *strTime = [formatter stringFromDate:dateStr];
    
    self.dateLb.text = strTime;
    self.titleLb.text = model.title;
    if (model.summary!=nil&&(NSNull *)model.summary!=[NSNull null]) {
        self.bodyTextView.text = model.summary;
    }else if (model.content!=nil&&(NSNull *)model.content!=[NSNull null]&&model.content.length < 50) {
         self.bodyTextView.text = model.content;
    }else if(model.content!=nil&&(NSNull *)model.content!=[NSNull null]&&model.content.length > 50){
        self.bodyTextView.text = [model.content substringWithRange:NSMakeRange(0, 50)];
    }
    
    [formatter release];
}
- (void) setChecked:(BOOL)checked
{
	if (checked)
	{
		_m_checkImageView.image = [UIImage imageNamed:@"bj_xz.png"];
	}
	else
	{
		_m_checkImageView.image = [UIImage imageNamed:@"bj_wxz.png"];
	}
	_m_checked = checked;
}

- (void)drawRect:(CGRect)rect
{
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextMoveToPoint(ctx, 0, 0);
//    CGContextAddLineToPoint(ctx, Screen_Width, 0);
//    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
//    CGContextSetLineWidth(ctx, 1);
//    
//    CGContextStrokePath(ctx);
}

//- (void)setEditing:(BOOL)editting animated:(BOOL)animated
//{
//	if (self.editing == editting)
//	{
//		return;
//	}
//	
//	[super setEditing:editting animated:animated];
//	
//	if (editting)
//	{
//        [self setChecked:_m_checked];
//		_m_checkImageView.hidden = NO;
//	}
//	else
//	{
//		_m_checked = NO;
//		_m_checkImageView.hidden = YES;
//		}
//	
//}


@end
