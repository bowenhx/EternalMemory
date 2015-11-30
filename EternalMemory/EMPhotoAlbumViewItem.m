//
//  EMPhotoAlbumViewItem.m
//  EternalMemory
//
//  Created by FFF on 14-3-10.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "EMPhotoAlbumViewItem.h"

@interface  EMPhotoAlbumViewItem ()

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) CALayer     *templateLayer;
@property (nonatomic, retain) CALayer     *deleteIconLayer;

@end

@implementation EMPhotoAlbumViewItem

- (void) dealloc {
    [_deleteIconLayer release];
    [_imageView release];
    [_image release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        _templateLayer = [[CALayer alloc] init];
        _templateLayer.position = CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0);
        _templateLayer.bounds = CGRectMake(0, 0, 66, 66);
        _templateLayer.contentsGravity = @"resizeAspectFill";
        _templateLayer.masksToBounds = YES;
        [self.layer addSublayer:_templateLayer];
        
        self.layer.contents = (id)[[UIImage imageNamed:@"top_film"] CGImage];
        self.layer.contentsGravity = @"resizeAspect";
        self.layer.masksToBounds = YES;
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
        _imageView.center = CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0);
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        _deleteIconLayer = [CALayer layer];
        _deleteIconLayer.position = CGPointMake(_imageView.frame.origin.x + _imageView.frame.size.width - 2, _imageView.frame.origin.y);
        _deleteIconLayer.bounds = CGRectMake(0, 0, 15, 15);
        _deleteIconLayer.hidden = YES;
        _deleteIconLayer.contents = (id)[UIImage imageNamed:@"delete_cross"].CGImage;
        [self.layer addSublayer:_deleteIconLayer];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        [_image release];
        _image = [image retain];
    }
    
    [self.imageView setImage:_image];
    if (_showDeleteIcon && self.imageView.image) {
        _deleteIconLayer.hidden = NO;
    } else {
        _deleteIconLayer.hidden = YES;
    }
}

- (void)setTemplateImage:(UIImage *)templateImage {
    if (_templateImage != templateImage) {
        [_templateImage release];
        _templateImage = [templateImage retain];
    }
    
    self.templateLayer.contents = (id)[_templateImage CGImage];
}

- (CGSize)itemImageSize {
    return self.imageView.frame.size;
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
