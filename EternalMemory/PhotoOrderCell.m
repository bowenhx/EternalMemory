//
//  PhotoOrderCell.m
//  EternalMemory
//
//  Created by zhaogl on 14-3-10.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "PhotoOrderCell.h"
#import "UIView+SubviewHunting.h"
#import "LimitePasteTextView.h"


@implementation PhotoOrderCell
@synthesize editBtnPressedBlock = _editBtnPressedBlock;
-(void)dealloc{
    
    [super dealloc];
}

-(void)awakeFromNib{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.showsReorderControl = NO;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        _photoImg.backgroundColor = [UIColor redColor];
//        [self reDrawRecorferControll];
//        [self setEditing:YES];
//        [self reDrawRecorferControll];
        
        [[self.photoImg layer] setShadowOffset:CGSizeMake(5, 5)]; // 阴影的范围
        [[self.photoImg layer] setShadowRadius:2];                // 阴影扩散的范围控制
        [[self.photoImg layer] setShadowOpacity:1];               // 阴影透明度
        [[self.photoImg layer] setShadowColor:[UIColor brownColor].CGColor]; // 阴影的颜色
        
    }
    return self;
}
-(IBAction)editBtnPressed:(id)sender{
    
    if (_editBtnPressedBlock) {
        _editBtnPressedBlock();
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.contentTextField resignFirstResponder];
    return YES;
}

-(void)reDrawRecorferControll{
    
    UIView* reorderControl = [self huntedSubviewWithClassName:@"UITableViewCellReorderControl"];
    reorderControl.backgroundColor = [UIColor clearColor];
    
	UIView* resizedGripView = [[UIView alloc] initWithFrame:CGRectMake(-205, 0, 300, 78)];
    resizedGripView.userInteractionEnabled = YES;
    resizedGripView.backgroundColor = [UIColor redColor];
	[resizedGripView addSubview:reorderControl];
	[self addSubview:resizedGripView];
    
	CGSize sizeDifference = CGSizeMake(resizedGripView.frame.size.width - reorderControl.frame.size.width, resizedGripView.frame.size.height - reorderControl.frame.size.height);
	CGSize transformRatio = CGSizeMake(resizedGripView.frame.size.width / reorderControl.frame.size.width, resizedGripView.frame.size.height / reorderControl.frame.size.height);
    
	CGAffineTransform transform = CGAffineTransformIdentity;
    
	//	Scale custom view so grip will fill entire cell
	transform = CGAffineTransformScale(transform, transformRatio.width, transformRatio.height);
    
	//	Move custom view so the grip's top left aligns with the cell's top left
	transform = CGAffineTransformTranslate(transform, -sizeDifference.width / 2.0, -sizeDifference.height / 2.0);
    
	[resizedGripView setTransform:transform];
    
	for(UIImageView* cellGrip in reorderControl.subviews)
	{
		if([cellGrip isKindOfClass:[UIImageView class]])
            cellGrip.backgroundColor = [UIColor clearColor];
        [cellGrip setImage:nil];
	}

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
