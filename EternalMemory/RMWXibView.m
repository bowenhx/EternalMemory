

#import "RMWXibView.h"
#import "RMWXibViewUtils.h"


@implementation RMWXibView

+ (id)loadFromXib
{
    return [RMWXibViewUtils loadViewFromXibNamed:NSStringFromClass([self class])];
}
@end
