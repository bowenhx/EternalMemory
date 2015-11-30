//
//  PhotoCategoryViewController.h
//  EternalMemory
//
//  Created by FFF on 13-12-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "CustomNavBarController.h"
#import "EMPhotoAlbumTopView.h"

@interface PhotoCategoryViewController : CustomNavBarController<UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UITableView *_tableView;
}

@property (nonatomic, readonly) UICollectionView *collectionView;
@property (nonatomic, readonly) EMPhotoAlbumTopView *topView;
@property (nonatomic, readonly) NSArray *albums;


@end
