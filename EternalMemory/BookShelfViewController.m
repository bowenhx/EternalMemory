//
//  BookShelfViewController.m
//  EternalMemory
//
//  Created by SuperAdmin on 13-11-11.
//  Copyright (c) 2013年 sun. All rights reserved.
//


#import "MyBlogListViewController.h"
#import "BookShelfViewController.h"
#import "MyCellView.h"
#import "MyCategoryView.h"
#import "MyBelowBottomView.h"

#define CELL_HEIGHT 125


@interface BookShelfViewController ()

//添加新的分类
-(void)addNewBookCategory;


@end

@implementation BookShelfViewController

- (void)initBooks {
    NSInteger numberOfBooks = 15;
    _bookArray = [[NSMutableArray alloc] initWithCapacity:numberOfBooks];
    _bookStatus = [[NSMutableArray alloc] initWithCapacity:numberOfBooks];
    for (int i = 0; i < numberOfBooks; i++) {
        NSNumber *number = [NSNumber numberWithInt:i];
        [_bookArray addObject:number];
        [_bookStatus addObject:[NSNumber numberWithInt:BOOK_UNSELECTED]];
    }
    
    _booksIndexsToBeRemoved = [NSMutableIndexSet indexSet];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self initBooks];
    self.titleLabel.text = @"文献";
    self.middleBtn.hidden = YES;
    _editMode = NO;
    //AboveTopView *aboveTop = [[AboveTopView alloc] initWithFrame:CGRectMake(0, 0, 320, 164)];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"editBookShelf"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CannotEditBookShelf:) name:@"CannotEditBookShelf" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CannotMobileFirstCategoryView:) name:@"CannotMobileFirstCategoryView" object:nil];
    
    _belowBottomView = [[MyBelowBottomView alloc] initWithFrame:CGRectMake(0, 0, 320, CELL_HEIGHT * 2)];
    
    //MyBelowBottomView *belowBottom = [[MyBelowBottomView alloc] initWithFrame:CGRectMake(0, 0, 320, CELL_HEIGHT * 2)];
    if (iOS7)
    {
        _bookShelfView = [[GSBookShelfView alloc] initWithFrame:CGRectMake(0, 64, 320, SCREEN_HEIGHT - 64)];
    }
    else
    {
        _bookShelfView = [[GSBookShelfView alloc] initWithFrame:CGRectMake(0, 44, 320, 460 - 44)];
    }

    [_bookShelfView setDataSource:self];
    //[_bookShelfView setShelfViewDelegate:self];
    
    [self.view addSubview:_bookShelfView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

#pragma mark GSBookShelfViewDataSource

- (NSInteger)numberOfBooksInBookShelfView:(GSBookShelfView *)bookShelfView {
    return [_bookArray count];
}

- (NSInteger)numberOFBooksInCellOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 2;
}

- (UIView *)bookShelfView:(GSBookShelfView *)bookShelfView bookViewAtIndex:(NSInteger)index {
    static NSString *identifier = @"bookView";
    MyCategoryView *bookView = (MyCategoryView *)[bookShelfView dequeueReuseableBookViewWithIdentifier:identifier];
    if (bookView == nil) {
        bookView = [[MyCategoryView alloc] initWithFrame:CGRectZero];
        bookView.reuseIdentifier = identifier;
        bookView.delegate = self;
    }
    [bookView setIndex:index];
    [bookView setSelected:[(NSNumber *)[_bookStatus objectAtIndex:index] intValue]];
    int imageNO = [(NSNumber *)[_bookArray objectAtIndex:index] intValue] % 4 + 1;
    if (index != 0)
    {
        [bookView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"Blog_bg_%d.jpg", imageNO]]]];
        [bookView setEdit:_editMode];
    }
    else
    {
        [bookView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"tjtp.png"]]]];
        [bookView setHideCategoryInfo:YES];
    }
    return bookView;
}

- (UIView *)bookShelfView:(GSBookShelfView *)bookShelfView cellForRow:(NSInteger)row {
    static NSString *identifier = @"cell";
    MyCellView *cellView = (MyCellView *)[bookShelfView dequeueReuseableCellViewWithIdentifier:identifier];
    if (cellView == nil) {
        cellView = [[MyCellView alloc] initWithFrame:CGRectZero];
        cellView.reuseIdentifier = identifier;
    }
    if (row == 0)
    {
        cellView.categoryImageView.image = nil;
    }
    else
    {
        cellView.categoryImageView.image = [UIImage imageNamed:@"bookshelf.png"];
    }
    return cellView;
}

- (UIView *)aboveTopViewOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return nil;
}

- (UIView *)belowBottomViewOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return _belowBottomView;
}

- (UIView *)headerViewOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return nil;
}

- (CGFloat)cellHeightOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 165.0f;
}

- (CGFloat)cellMarginOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 35.0f;
}

- (CGFloat)bookViewHeightOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 120.0f;
}

- (CGFloat)bookViewWidthOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 110.0f;
}

- (CGFloat)bookViewBottomOffsetOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 175.0f;
}

- (CGFloat)cellShadowHeightOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 0.0f;
}

- (void)bookShelfView:(GSBookShelfView *)bookShelfView moveBookFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    if ([(NSNumber *)[_bookStatus objectAtIndex:fromIndex] intValue] == BOOK_SELECTED) {
        [_booksIndexsToBeRemoved removeIndex:fromIndex];
        [_booksIndexsToBeRemoved addIndex:toIndex];
    }
    
    [_bookArray moveObjectFromIndex:fromIndex toIndex:toIndex];
    [_bookStatus moveObjectFromIndex:fromIndex toIndex:toIndex];
    
    // the bookview is recognized by index in the demo, so change all the indexes of affected bookViews here
    // This is just a example, not a good one.In your code, you'd better use a key to recognize the bookView.
    // and you won't need to do the following
    MyCategoryView *bookView;
    bookView = (MyCategoryView *)[_bookShelfView bookViewAtIndex:toIndex];
    [bookView setIndex:toIndex];
    if (fromIndex <= toIndex) {
        for (int i = fromIndex; i < toIndex; i++) {
            bookView = (MyCategoryView *)[_bookShelfView bookViewAtIndex:i];
            [bookView setIndex:bookView.index - 1];
        }
    }
    else {
        for (int i = toIndex + 1; i <= fromIndex; i++) {
            bookView = (MyCategoryView *)[_bookShelfView bookViewAtIndex:i];
            [bookView setIndex:bookView.index + 1];
        }
    }
}
//分类编辑按钮
//-(void)editCategoryButtonClicked:(id)sender
-(void)rightBtnPressed
{
    _editMode = !_editMode;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:_editMode] forKey:@"editBookShelf"];
    
    NSInteger categoryCount = _bookArray.count;
    for (int i = 1; i <categoryCount; i ++)
    {
        MyCategoryView *bookView = (MyCategoryView *)[_bookShelfView bookViewAtIndex:i];
        [bookView setEdit:_editMode];
    }
}

-(void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addButtonClicked:(id)sender {
    
}



//添加新的分类
-(void)addNewBookCategory
{
    MyCategoryView *bookView = (MyCategoryView *)[_bookShelfView bookViewAtIndex:0];
    [bookView setHideCategoryInfo:NO];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:0];
    [_bookArray insertObject:[NSNumber numberWithInt:1] atIndex:0];
    [_bookStatus insertObject:[NSNumber numberWithInt:BOOK_UNSELECTED] atIndex:0];
    [_bookShelfView insertBookViewsAtIndexs:indexSet animate:YES];
}

#pragma mark - NSNotificationCenter

-(void)CannotEditBookShelf:(NSNotification *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"编辑状态不能移动分类" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    alertView.tag = 101;
    [alertView show];
}
-(void)CannotMobileFirstCategoryView:(NSNotification *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"不能移动添加分类标签" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    alertView.tag =102;
    [alertView show];
    
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resetTouchValue" object:nil];
    }
    else
    {
        ;
    }
}

#pragma mark -MyCategoryViewDelegate

-(void)addNewCategory
{
    if (_editMode == YES)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"编辑状态不能添加新分类" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return;
    }
    [self addNewBookCategory];
}

-(void)deleteCategoryAtIndex:(NSInteger)index
{
    [_bookArray removeObjectAtIndex:index];
    [_bookStatus removeObjectAtIndex:index];
    [_bookShelfView removeBookViewsAtIndexs:[NSIndexSet indexSetWithIndex:index] animate:YES];
}

-(void)showCategoryInfo
{
    MyBlogListViewController *_myBlogListViewController = [[MyBlogListViewController alloc]init];
    [self.navigationController pushViewController:_myBlogListViewController animated:YES];
    [_myBlogListViewController release];

}

#pragma mark - BookView Listener

- (void)bookViewClicked:(MyCategoryView *)button {
    if (button.index == 0)
    {
        [self addNewCategory];
        return;
    }
    MyCategoryView *bookView = (MyCategoryView *)button;
    
    if (_editMode) {
        NSNumber *status = [NSNumber numberWithInt:bookView.selected];
        [_bookStatus replaceObjectAtIndex:bookView.index withObject:status];
        
        if (bookView.selected) {
            [_booksIndexsToBeRemoved addIndex:bookView.index];
        }
        else {
            [_booksIndexsToBeRemoved removeIndex:bookView.index];
        }
    }
    else {
        [bookView setSelected:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
