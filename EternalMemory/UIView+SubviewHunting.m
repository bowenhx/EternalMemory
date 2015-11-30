//
//  UIView+SubviewHunting.m
//  LargeTableGrip
//
//  Created by Tom Parry on 21/08/13.
//
//

#import "UIView+SubviewHunting.h"

@implementation UIView (SubviewHunting)

- (UIView*) huntedSubviewWithClassName:(NSString*) className
{
	if([[[self class] description] isEqualToString:className])
		return self;
	
	for(UIView* subview in self.subviews)
	{
		UIView* huntedSubview = [subview huntedSubviewWithClassName:className];
		
		if(huntedSubview != nil)
			return huntedSubview;
	}
	
	return nil;
}


@end
