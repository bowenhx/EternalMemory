

#import "UILabel+RMWAdditions.h"

@implementation UILabel (RMWAdditions)

+ (UILabel *)labelWithFrame:(CGRect)frame
                       text:(NSString *)text
                  textColor:(UIColor *)textColor
                       font:(UIFont *)font
                        tag:(NSInteger)tag
                  hasShadow:(BOOL)hasShadow{
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.text = text;
	label.textColor = textColor;
	label.backgroundColor = [UIColor clearColor];
	if( hasShadow ){
		label.shadowColor = [UIColor blackColor];
		label.shadowOffset = CGSizeMake(1,1);
	}
//	label.textAlignment = UITextAlignmentCenter;
	label.font = font;
	label.tag = tag;
	
	return [label autorelease];
}
+ (UILabel *)labelForNavigationBarWithTitle:(NSString*)title
                                  textColor:(UIColor *)textColor
                                       font:(UIFont *)font
                                  hasShadow:(BOOL)hasShadow{
	UILabel *titleLbl = [UILabel labelWithFrame:CGRectMake(0,0,320,44)
                                           text:title
                                      textColor:textColor
                                           font:font
                                            tag:0
                                      hasShadow:hasShadow];
//    titleLbl.textAlignment = UITextAlignmentCenter;
	return titleLbl;
}
@end
