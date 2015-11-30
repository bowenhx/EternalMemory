//
//  BookShelfViewController.h
//  EternalMemory
//
//  Created by SuperAdmin on 13-11-11.
//  Copyright (c) 2013年 sun. All rights reserved.
//
#import "CustomNavBarController.h"

#import "GSBookShelfView.h"
#import "MyCategoryView.h"
#import <UIKit/UIKit.h>

@class MyBelowBottomView;

typedef enum {
    BOOK_UNSELECTED,
    BOOK_SELECTED
}BookStatus;



@interface BookShelfViewController : CustomNavBarController<GSBookShelfViewDelegate, GSBookShelfViewDataSource,MycategoryViewDelegate,UIAlertViewDelegate,NavBarDelegate>{
    GSBookShelfView *_bookShelfView;
    
    NSMutableArray *_bookArray;
    NSMutableArray *_bookStatus;
    
    NSMutableIndexSet *_booksIndexsToBeRemoved;
    
    BOOL _editMode;
    
    UIBarButtonItem *_editBarButton;
    UIBarButtonItem *_cancleBarButton;
    UIBarButtonItem *_trashBarButton;
    UIBarButtonItem *_editCategoryBarButton;
    
    MyBelowBottomView *_belowBottomView;
    UISearchBar *_searchBar;
}


@end
