//
//  EMPhotoAlbumTopView.m
//  EternalMemory
//
//  Created by FFF on 14-3-10.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "EMPhotoAlbumTopView.h"
#import "EMPhotoAlbumViewItem.h"
#import "EMMemorizeMessageModel.h"
#import "Utilities.h"
#import "EMAllLifeMemoDAO.h"
#import "DiaryPictureClassificationModel.h"

#define SCROLL_VIEW_HEIGHT   99

@import QuartzCore;

//static const CGSize itemSize = (CGSize){ SCROLL_VIEW_HEIGHT / 1.22 , SCROLL_VIEW_HEIGHT };
static const CGSize itemSize = (CGSize){ 80 , SCROLL_VIEW_HEIGHT };

@interface EMPhotoAlbumTopView () {
    EMPhotoItemSelectBlock _selectBlock;
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIView       *flagView;
@property (nonatomic, retain) UILabel      *titleLabel;
@property (nonatomic, retain) EMPhotoAlbumViewItem *item;
@property (nonatomic, retain) NSArray *photoItems;
@property (nonatomic, retain) NSArray *photos;

@end

@implementation EMPhotoAlbumTopView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){0, 65, frame.size.width, SCROLL_VIEW_HEIGHT}];
        _scrollView.backgroundColor = RGBCOLOR(111, 113, 114);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        [self addSubview:_scrollView];
        
        UIImage *image = [UIImage imageNamed:@"flag_view_bg"];
        image = [image stretchableImageWithLeftCapWidth:20 topCapHeight:0];
        _flagView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 150, 44/1.5)];
        _flagView.backgroundColor = [UIColor clearColor];
        _flagView.layer.contents = (id)[image CGImage];
        _flagView.layer.contentsGravity = @"resize";
        [self addSubview:_flagView];
        
        CALayer *cameraLogoLayer = [CALayer layer];
        cameraLogoLayer.bounds = CGRectMake(0, 0, 19, 16);
        cameraLogoLayer.position = CGPointMake(16, 13);
        cameraLogoLayer.contents = (id)[[UIImage imageNamed:@"album_camera"] CGImage];
        cameraLogoLayer.contentsGravity = @"resizeAspect";
        [_flagView.layer addSublayer:cameraLogoLayer];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 100, 30)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.text = @"一生记忆";
        [_flagView addSubview:_titleLabel];
        
        
    }
    return self;
}

- (void)setItemCount:(NSInteger)itemCount {
    _itemCount = itemCount;
    
    NSMutableArray *muArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < _itemCount; i ++) {
        NSInteger x = i * itemSize.width ;
        EMPhotoAlbumViewItem *item = [[EMPhotoAlbumViewItem alloc] initWithFrame:(CGRect){x, 0, itemSize}];
        item.itemPosition = i;
        item.backgroundColor = [UIColor clearColor];
        item.tag = 100 + i;
        [self.scrollView addSubview:item];
        [muArray addObject:item];
        [item release];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapItemAtIndex:)];
        [item addGestureRecognizer:tapGesture];
        [tapGesture release];
    }
    
    self.photoItems = [NSArray arrayWithArray:muArray];
    self.scrollView.contentSize = CGSizeMake(itemCount * itemSize.width, _scrollView.frame.size.height);
    [muArray release];
}

- (void)tapItemAtIndex:(UITapGestureRecognizer *)gesture {
    EMPhotoAlbumViewItem *item = (EMPhotoAlbumViewItem *)gesture.view;
    
    if (_editMode) {
        if (item.image == Nil) {
            return;
        }
        if (_deleteBlock) {
            _deleteBlock(item.itemPosition);
        }
//        [self removeItemAtPosition:item.itemPosition];
    } else {
        
        if (_selectBlock) {
             _selectBlock(_photos, self.diaryModel, item.itemPosition);
        }
    }
}

- (EMPhotoAlbumViewItem *)itemAtPosition:(ItemPosition)position {
    
    return _photoItems[position];
}


- (void)removeItemAtPosition:(ItemPosition)position {
    
    if (self.templateModels.count > 0) {
        EMPhotoAlbumViewItem *item = _photoItems[position];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.photos];
        
        MessageModel *modelToDel = arr[position];
        MessageModel *templateToReplace = nil;
        for (MessageModel *model in self.templateModels) {
            if ([modelToDel.photoWall integerValue] == [model.photoWall integerValue]) {
                templateToReplace = model;
                break;
            }
        }
        item.image = nil;
        
        if (arr.count == 0 || arr == nil) {
            return;
        }  
        
        [arr replaceObjectAtIndex:position withObject:templateToReplace];
        self.photos = [NSArray arrayWithArray:arr];
        
        NSString *photoWall = [NSString stringWithFormat:@"%@.png",templateToReplace.photoWall];
        NSString *fullPath = [Utilities lifeMemoPathOfTemplate];
        NSString *path = [fullPath stringByAppendingPathComponent:photoWall];
        NSData *data = [NSData dataWithContentsOfFile:path];
        __block UIImage *image = nil;
        if (!data) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:templateToReplace.thumbnail]];
                image = [UIImage imageWithData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [item setTemplateImage:image];
                });
                
                [imageData writeToFile:path atomically:YES];
            });
        } else {
            image = [UIImage imageWithData:data];
            item.templateImage = image;
        }
    }
    
}

- (void)setImage:(UIImage *)image ForPosition:(ItemPosition)position {
    EMPhotoAlbumViewItem *item = [self itemAtPosition:position];
//    item.image = image;
    item.image = image;
    [self.photos[position] setThumbnailImage:image];
}

- (void)setTemplateImage:(UIImage *)image forPosition:(ItemPosition)position {
    EMPhotoAlbumViewItem *item = [self itemAtPosition:position];
//    item.layer.contents = (id)[image CGImage];
    item.image = nil;
    item.templateImage = image;
    
}

- (void)setSelectBlock:(EMPhotoItemSelectBlock)selectBlock {
    if (_selectBlock != selectBlock) {
        [_selectBlock release];
        _selectBlock = [selectBlock copy];
    }
}

- (void)setPhotos:(NSArray *)photos {
    if (_photos != photos) {
        [_photos release];
        _photos = [photos retain];
    }
}

- (void)setPhoto:(MessageModel *)model atPosition:(ItemPosition)position {
    
    MessageModel *aModel = [model deepCopy];
    aModel.photoWall = [self.photos[position] photoWall];
    aModel.theOrder = [self.photos[position] theOrder];

    NSMutableArray *arr = [NSMutableArray arrayWithArray:_photos];
    arr[position] = aModel;
    
    self.photos = [NSArray arrayWithArray:arr];
    
    arr = nil;
    [aModel release];
}


- (void)removePhotoAtPosition:(ItemPosition)position {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:_photos];
    [arr removeObjectAtIndex:position];
    
    self.photos = [NSArray arrayWithArray:arr];
    
    arr = nil;
}

- (void)setTemplateImage:(NSArray *)templateImage {
    if (_templateImage != templateImage) {
        [_templateImage release];
        _templateImage = [templateImage retain];
    }
    
    [self.templateImage enumerateObjectsUsingBlock:^(EMPhotoAlbumViewItem *item, NSUInteger idx, BOOL *stop) {
        item.templateImage = [templateImage[idx] thumbnailImage];
    }];
}

- (void)setDiaryModel:(DiaryPictureClassificationModel *)diaryModel {
    [_diaryModel release];
    _diaryModel = [diaryModel retain];
    
    self.titleLabel.text = _diaryModel.title;
    
}

- (void)setEditMode:(BOOL)editMode {
    _editMode = editMode;
    [self.photoItems enumerateObjectsUsingBlock:^(EMPhotoAlbumViewItem *item, NSUInteger idx, BOOL *stop) {
        item.showDeleteIcon = _editMode;
    }];
}

- (void) dealloc {
    [_templateModels release];
    [_photoItems release];
    [_templateImage release];
    [_selectBlock release];
    [_diaryModel release];
    [_scrollView release];
    [_photos release];
    [super dealloc];
}

#pragma mark - private

- (BOOL)p_deleteImageAtRelativePath:(NSString *)path {
    NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    return [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
