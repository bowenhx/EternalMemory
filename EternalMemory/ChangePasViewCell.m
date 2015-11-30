//
// Created by user on 13-5-30.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ChangePasViewCell.h"


@implementation ChangePasViewCell {

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        UIImageView *image = [[UIImageView alloc] initWithFrame:self.frame];
          image.userInteractionEnabled = YES;
//        image.layer.borderWidth = 1;       
//        image.image = [[UIImage imageNamed:@"public_table_upBg"]stretchableImageWithLeftCapWidth:15 topCapHeight:10];
        
        self.backGroundImage = image;
        [image release];
        [self addSubview:self.backGroundImage];



    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)dealloc {
    [_backGroundImage release];
    [super dealloc];
}
@end