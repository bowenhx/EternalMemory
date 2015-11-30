
#import "RMWXibViewUtils.h"

@implementation RMWXibViewUtils

+ (id)loadViewFromXibNamed:(NSString*)xibName withFileOwner:(id)fileOwner
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:xibName owner:fileOwner options:nil];
    if (array && [array count]) {
        return [array objectAtIndex:0];
    }else {
        return nil;
    }
}

+ (id)loadViewFromXibNamed:(NSString*)xibName
{
    return [RMWXibViewUtils loadViewFromXibNamed:xibName withFileOwner:self];
}

@end
