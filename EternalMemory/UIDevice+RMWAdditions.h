

#import <UIKit/UIKit.h>

#define IS_IPAD_DEVICE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

@interface UIDevice (RMWAdditions)

+ (UIInterfaceOrientation)currentOrientation;

- (BOOL) hasRetinaDisplay;
- (BOOL) is4InchScreen;

- (NSUInteger) totalMemory;
- (NSUInteger) userMemory;

- (NSString *) getMacAddress;
- (NSString *) platformString;

@end
