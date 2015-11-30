



#define HELPIMAGE_BYEOND_WIDTH 40

#import "RMWFirstTouchHelpView.h"
#import "EternalMemoryAppDelegate.h"
#import "RMWXibViewUtils.h"

@interface RMWFirstTouchHelpView ()
{
    NSArray                     *_iphone5ImagArray;
    NSArray                     *_helpImageArray;
    IBOutlet UIScrollView       *_scrollView;   
}

@end

@implementation RMWFirstTouchHelpView

- (void)dealloc
{
    if (_iphone5ImagArray) {
         [_iphone5ImagArray release];
    }
    if (_helpImageArray) {
        [_helpImageArray release];
    }
    [_scrollView release];
    [super dealloc];
}

+(id)loadFromXib
{
    return [RMWXibViewUtils loadViewFromXibNamed:NSStringFromClass([self class])];
}

-(void)startHelpWithHelpImageArray:(NSArray *)imageArray iphone5ImageArray:(NSArray *)iphone5ImageArray
{
    if (iPhone5) {
        _iphone5ImagArray = [iphone5ImageArray retain];
        for (int index = 0; index < [_iphone5ImagArray count]; index++) {
            UIImageView *helpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[_iphone5ImagArray objectAtIndex:index]]];
            helpImageView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * index, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            [_scrollView addSubview:helpImageView];
            [helpImageView release];
            _scrollView.contentSize=CGSizeMake([UIScreen mainScreen].bounds.size.width * [_iphone5ImagArray count] + HELPIMAGE_BYEOND_WIDTH, [UIScreen mainScreen].bounds.size.height);
        }
    }else{
       _helpImageArray =[imageArray retain];
        for (int index = 0; index < [_helpImageArray count]; index++) {
            UIImageView *helpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[_helpImageArray  objectAtIndex:index]]];
            helpImageView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * index, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            [_scrollView addSubview:helpImageView];
            [helpImageView release];
        }
        _scrollView.contentSize=CGSizeMake([UIScreen mainScreen].bounds.size.width * [_helpImageArray count] + HELPIMAGE_BYEOND_WIDTH, [UIScreen mainScreen].bounds.size.height);
    }
    
    self.frame = [UIScreen mainScreen].bounds;
    UIWindow *win = [EternalMemoryAppDelegate getAppDelegate].window;
    win.windowLevel = UIWindowLevelAlert;
    [win addSubview:self];
    [win bringSubviewToFront:self];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint currentOffset = [scrollView contentOffset];
    int scrollViewMaxOffset = 0;

    if (iPhone5) {
        scrollViewMaxOffset = [UIScreen mainScreen].bounds.size.width * ([_iphone5ImagArray count] - 1);
    }else{
        scrollViewMaxOffset = [UIScreen mainScreen].bounds.size.width * ([_helpImageArray count] - 1);
    }
    
    if (currentOffset.x > scrollViewMaxOffset) {
        UIWindow *win = [EternalMemoryAppDelegate getAppDelegate].window;
        win.windowLevel = UIWindowLevelNormal;
        [UIView animateWithDuration:0.3 
                         animations:^{
                             self.alpha = 0;
                         } 
                         completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"RMWFirstTouchHelpView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
