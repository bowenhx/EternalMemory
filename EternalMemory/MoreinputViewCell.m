//
//  MoreinputViewCell.m
//  EternalMemory
//
//  Created by Guibing Li on 13-5-23.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "MoreinputViewCell.h"

@implementation MoreinputViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //R46 G154 B222
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//- (void)setFrame:(CGRect)frame {
//    
//    CGFloat TABLE_CELL_EXPAND=-10.0f;
//    frame.origin.x += TABLE_CELL_EXPAND;
//    frame.size.width -= 2 * TABLE_CELL_EXPAND;
//    [super setFrame:frame];
//}

- (void)dealloc {
    [_labTextRoom release];
    [_labTextRoomNum release];
    [_progressNum release];
    [_labTextTime release];
    [_labTextTimeNum release];
    [super dealloc];
}
@end
