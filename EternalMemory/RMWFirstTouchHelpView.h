

#import <UIKit/UIKit.h>
#import "RMWXibView.h"

@interface RMWFirstTouchHelpView : RMWXibView
{

}

+ (id)loadFromXib;
-(void)startHelpWithHelpImageArray:(NSArray *)imageArray iphone5ImageArray:(NSArray *)iphone5ImageArray;

@end
