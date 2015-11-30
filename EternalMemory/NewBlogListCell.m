//
//  NewBlogListCell.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-15.
//  Copyright (c) 2013年 sun. All rights reserved.
//
#import "NewBlogListCell.h"
#import "DiaryMessageModel.h"
#import "BlogListDateLabel.h"
#import "AttributedStringBuilder.h"

@interface NewBlogListCell ()
{
    
}

@property (retain, nonatomic)  UIImageView *editableIndicator;
@property (nonatomic, retain)  UILabel *titleLabel;
@property (nonatomic, retain)  UILabel *contentLabel;
//@property (nonatomic, retain)  BlogListDateLabel *dateLabel;
@property (nonatomic, retain)  UILabel *monthLabel;
@property (nonatomic, retain)  UILabel *dayLabel;

@end


@implementation NewBlogListCell
@synthesize editableIndicator = _editableIndicator;
@synthesize titleLabel = _titleLabel;
@synthesize contentLabel = _contentLabel;
//@synthesize dateLabel = _dateLabel;
@synthesize monthLabel = _monthLabel;
@synthesize dayLabel = _dayLabel;

-(UILabel *)monthLabel
{
    if (!_monthLabel)
    {
        _monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 10, 50, 10)];
        _monthLabel.font = [UIFont systemFontOfSize:13.0f];
        _monthLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _monthLabel;
}

-(UILabel *)dayLabel
{
    if (!_dayLabel)
    {
        _dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(265, 28, 45, 30)];
        _dayLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40.0f];
        _dayLabel.textAlignment = NSTextAlignmentLeft;
        _dayLabel.backgroundColor = [UIColor whiteColor];
    }
    return _dayLabel;
}

-(UIImageView *)editableIndicator
{
    if (!_editableIndicator)
    {
        _editableIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(285, 33, 15, 15)];
    }
    return _editableIndicator;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 6, 215, 24)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
    }
    return _titleLabel;
}

-(UILabel *)contentLabel
{
    if (!_contentLabel)
    {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 30, 229, 16)];
        _contentLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addSubview:self.titleLabel];
        [self addSubview:self.contentLabel];
        [self addSubview:self.editableIndicator];
        [self addSubview:self.monthLabel];
        [self addSubview:self.dayLabel];
//        [self addSubview:self.dateLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCellWithModel:(DiaryMessageModel *)model
{
    if (_model != model) {
        [_model release];
        _model = [model retain];
    }
    NSString *title = _model.title;
    NSString *summary = _model.summary;
    NSString *creatTime = _model.createTime;
    CGFloat contentHeight = [self setContentLabelSize:summary];
    
    CGRect titleFrame = _titleLabel.frame;
    CGRect contentFrame = _contentLabel.frame;
    
    contentFrame.size.height = contentHeight;

    if (title.length == 0) {
        contentFrame.origin.y = titleFrame.origin.y;
        _contentLabel.frame = contentFrame;
        _titleLabel.hidden = YES;
    }
    
    _contentLabel.frame = contentFrame;
    _titleLabel.frame = titleFrame;
    
    NSDictionary *date = [self convertTimestampToData:creatTime];
    _dayLabel.text = date[@"KdateLabelDay"];
    _monthLabel.text = [NSString stringWithFormat:@"%@-%@",date[@"kDateLabelYear"],date[@"kDateLabelMonth"]];
    _titleLabel.text = title;
    _contentLabel.text = summary;
    
}

- (void)setIsEditing:(BOOL)isEditing
{
    __block typeof(self) bself = self;
    if (isEditing) {
        _editableIndicator.hidden = NO;
        [UIView animateWithDuration:0.1 animations:^{
            
            bself.dayLabel.frame = (CGRect){
                .origin.x = self.frame.size.width - 100,
                .origin.y = bself.dayLabel.frame.origin.y,
                .size.width  = bself.dayLabel.frame.size.width,
                .size.height = bself.dayLabel.frame.size.height
            };

            bself.monthLabel.frame = (CGRect){
                .origin.x = self.frame.size.width - 100,
                .origin.y = bself.monthLabel.frame.origin.y,
                .size.width  = bself.monthLabel.frame.size.width,
                .size.height = bself.monthLabel.frame.size.height
            };
            bself.contentLabel.frame = (CGRect){
              bself.contentLabel.frame.origin.x,
              bself.contentLabel.frame.origin.y,
              204,
              bself.contentLabel.frame.size.height
            };
        }];
        
    } else {
        _editableIndicator.hidden = YES;
        [UIView animateWithDuration:0.1 animations:^{
            
            bself.dayLabel.frame = (CGRect){
                .origin.x = self.frame.size.width - 60,
                .origin.y = bself.dayLabel.frame.origin.y,
                .size.width  = bself.dayLabel.frame.size.width,
                .size.height = bself.dayLabel.frame.size.height
            };
            bself.monthLabel.frame = (CGRect){
                .origin.x = self.frame.size.width - 60,
                .origin.y = bself.monthLabel.frame.origin.y,
                .size.width  = bself.monthLabel.frame.size.width,
                .size.height = bself.monthLabel.frame.size.height
            };
            bself.contentLabel.frame = (CGRect){
                bself.contentLabel.frame.origin.x,
                bself.contentLabel.frame.origin.y,
                229,
                bself.contentLabel.frame.size.height
            };


        }];
    }
}

- (void) setChecked:(BOOL)checked
{
	if (checked)
	{
		_editableIndicator.image = [UIImage imageNamed:@"bj_xz.png"];
	}
	else
	{
		_editableIndicator.image = [UIImage imageNamed:@"bj_wxz.png"];
	}
}

#pragma mark - private

- (CGFloat)setContentLabelSize:(NSString *)summary
{
    CGSize size = [summary sizeWithFont:_contentLabel.font constrainedToSize:CGSizeMake(229, 42)];
    
    return size.height;
}

- (NSDictionary *)convertTimestampToData:(NSString *)createTime
{
    NSTimeInterval interval = [createTime doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(interval / 1000)];

    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    NSString *year = [dateStr substringToIndex:4];
    NSString *month = [dateStr substringWithRange:NSMakeRange(5, 2)];
    NSString *day = [dateStr substringFromIndex:(dateStr.length - 2)];
    
    NSDictionary *dateDic = @{kDateLabelYear:year, kDateLabelMonth:month, kDateLabelDay:day};
    
    return dateDic;
}


- (void)dealloc
{
    [_model release];
    [_dayLabel release];
    [_monthLabel release];
    [_titleLabel release];
    [_contentLabel release];
    [_editableIndicator release];

    [super dealloc];
}

@end
