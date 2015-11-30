//
//  UIButton+ITTAdditions.m

#import "UIButton+RMWAdditions.h"

@implementation UIButton (RMWAdditions)

+ (UIButton *)buttonWithFrame:(CGRect)frame
                        title:(NSString *)title 
                   titleColor:(UIColor *)titleColor
          titleHighlightColor:(UIColor *)titleHighlightColor
                    titleFont:(UIFont *)titleFont
                        image:(UIImage *)image
                  tappedImage:(UIImage *)tappedImage
                       target:(id)target 
                       action:(SEL)selector 
                          tag:(NSInteger)tag{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = frame;
	if( title!=nil && title.length>0 ){
		[button setTitle:title forState:UIControlStateNormal];
		[button setTitleColor:titleColor forState:UIControlStateNormal];
		[button setTitleColor:titleHighlightColor forState:UIControlStateHighlighted];
		button.titleLabel.font = titleFont;
	}
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	button.tag = tag;
	if( image){
		[button setBackgroundImage:image forState:UIControlStateNormal];
	}
	if( tappedImage){
		[button setBackgroundImage:tappedImage forState:UIControlStateHighlighted];
	}
	
	return button;
}
@end
