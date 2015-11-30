//
//  EMPhotoAlbumCollectionCell.m
//  EternalMemory
//
//  Created by FFF on 14-3-10.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "EMPhotoAlbumCollectionCell.h"
#import "DiaryPictureClassificationModel.h"

@interface EMPhotoAlbumCollectionCell ()

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel     *titleLabel;
@property (nonatomic, retain) UILabel     *countLabel;
@property (nonatomic, retain) DiaryPictureClassificationModel *model;

@end

@implementation EMPhotoAlbumCollectionCell

- (void)dealloc {
    [_countLabel release];
    [_titleLabel release];
    [_title release];
    [_imageView release];
    [_image release];
    
    [super dealloc];
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.backgroundColor = [UIColor grayColor];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        CGFloat demonsion = MIN(frame.size.width, frame.size.height);
        CALayer *backgrouLayer = [CALayer layer];
        backgrouLayer.frame = CGRectMake(0, 0, demonsion, demonsion);
        backgrouLayer.contents = (id)[[UIImage imageNamed:@"default_album_bg.png"] CGImage];
        backgrouLayer.masksToBounds = YES;
        backgrouLayer.contentsGravity = @"resizeAspect";
        [self.layer addSublayer:backgrouLayer];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, demonsion - 20, demonsion - 20)];
        _imageView.center = backgrouLayer.position;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, backgrouLayer.frame.size.height , frame.size.width, 25)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor colorWithRed:104/255. green:105/255. blue:107/255. alpha:1];
        _titleLabel.font = [UIFont systemFontOfSize:14];

        [self addSubview:_titleLabel];
        
        
        
        CALayer *countBgLayer = [CALayer layer];
//        countBgLayer.backgroundColor = [UIColor blackColor].CGColor;
        countBgLayer.bounds = CGRectMake(0, 0, 20, 20);
        countBgLayer.position = CGPointMake(75, 20);
        countBgLayer.contents = (id)[UIImage imageNamed:@"photo_count"].CGImage;
        countBgLayer.contentsGravity = @"resizeAspect";
        [self.layer addSublayer:countBgLayer];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(65.5, 9.3, 20, 20)];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textColor = [UIColor colorWithRed:55/255. green:37/255. blue:64/255. alpha:1];
        _countLabel.font = [UIFont systemFontOfSize:10];
        _countLabel.textAlignment = NSTextAlignmentCenter;

        [self addSubview:_countLabel];
    }
    return self;
}

- (void)configCellWithDiaryModel:(DiaryPictureClassificationModel *)model {
    
    [_model release];
    _model = [model retain];
    self.image = _model.thumbnail;
    self.title = _model.title;
    self.countLabel.text = [NSString stringWithFormat:@"%@",_model.blogcount];
 
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        [_image release];
        _image = [image retain];
    }
    
    [self.imageView setImage:_image];
}

- (void)setTitle:(NSString *)title {
    if (_title != title) {
        [_title release];
        _title = [title copy];
    }
    
    self.titleLabel.text = title;
}
@end
