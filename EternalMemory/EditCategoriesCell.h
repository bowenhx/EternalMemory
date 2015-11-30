//
//  EditCategoriesCell.h
//  EternalMemory
//
//  Created by sun on 13-6-1.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMWButton.h"
@protocol EditCategoriesCellDelegate<NSObject>
- (void)editCategories:(NSInteger)deleteBtnIndex;
@end
@interface EditCategoriesCell : UITableViewCell
{
    id <EditCategoriesCellDelegate> _delegate;
 
}
@property (nonatomic, retain) IBOutlet RMWButton *deleteBtn;
@property (nonatomic, retain) IBOutlet UITextField *titleTF;
@property (nonatomic, assign) id <EditCategoriesCellDelegate> delegate;
@property (nonatomic, assign) BOOL deleteAble;
+ (EditCategoriesCell *)viewForNib;
- (IBAction)onDeleteBtnClicked:(EditCategoriesCell *)cell;
@end
