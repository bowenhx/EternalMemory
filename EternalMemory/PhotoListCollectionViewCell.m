//
//  PhotoListCollectionViewCell.m
//  EternalMemory
//
//  Created by FFF on 13-12-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "PhotoListCollectionViewCell.h"
#import "MessageModel.h"
#import "Utilities.h"
#import "SavaData.h"
#import "PhotoListCollectionViewCell.h"
@import QuartzCore;

@interface PhotoListCollectionViewCell ()

@property (nonatomic, retain) CALayer   *deleteImageLayer;
@property (nonatomic, retain) CALayer   *checkedLayer;
@property (nonatomic, retain) CALayer   *imageLayer;
@property (nonatomic, retain) CALayer   *audioLayer;

@end

@implementation PhotoListCollectionViewCell

- (void)dealloc
{
    [_deleteImageLayer release];
    [_checkedLayer release];
    [_image release];
    [super dealloc];
}

- (id)init {
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self setup];
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    
}

- (void)setup
{
    
    self.layer.contents = (id)[UIImage imageNamed:@"photo_mr"].CGImage;
    
    if (!_imageLayer) {
        
        
        CALayer *shadowLayer = [CALayer layer];
        shadowLayer.frame = self.bounds;
        shadowLayer.backgroundColor = [UIColor whiteColor].CGColor;
        shadowLayer.shadowColor = [UIColor lightGrayColor].CGColor;
        shadowLayer.shadowOpacity = 0.5;
        shadowLayer.shadowRadius  = 1;
        shadowLayer.shadowOffset = CGSizeMake(0, 0);
        shadowLayer.shadowPath = [UIBezierPath bezierPathWithRect:shadowLayer.bounds].CGPath;
        shadowLayer.contents = (id)[UIImage imageNamed:@"photo_mr"].CGImage;
        [self.layer addSublayer:shadowLayer];
        
        
        _imageLayer = [CALayer layer];
        _imageLayer.frame = self.bounds;
        _imageLayer.contentsGravity = @"resizeAspectFill";
        _imageLayer.masksToBounds = YES;
        
        _imageLayer.shadowColor = [UIColor lightGrayColor].CGColor;
        _imageLayer.shadowOpacity = 0.4;
        _imageLayer.shadowOffset = CGSizeMake(1, 1);
        _imageLayer.shadowPath = [UIBezierPath bezierPathWithRect:_imageLayer.bounds].CGPath;
        
//        _imageLayer.contents = (id)[UIImage imageNamed:@"photo_mr.png"].CGImage;
        [self.layer addSublayer:_imageLayer];
        
        
    }
    
    CGFloat length = 18;
    CGFloat margin = 3;
    
    CGRect checkFrame = (CGRect){
        .origin.x = _imageLayer.frame.size.width - length - margin,
        .origin.y = _imageLayer.frame.size.height - length - margin,
        .size.width  = length,
        .size.height = length
    };
    
    if (!_deleteImageLayer) {
        _deleteImageLayer = [[CALayer alloc] init];
        _deleteImageLayer.frame = checkFrame;
        _deleteImageLayer.contents = (id)[UIImage imageNamed:@"choose_icon.png"].CGImage;
        [_imageLayer addSublayer:_deleteImageLayer];
        
        _deleteImageLayer.hidden = YES;
    }
    
    if (!_checkedLayer) {
        
        self.checkedLayer = [CALayer layer];
        self.checkedLayer.frame = checkFrame;
        self.checkedLayer.contents = (id)[UIImage imageNamed:@"bj_xz.png"].CGImage;
        self.checkedLayer.hidden = YES;
        [_imageLayer addSublayer:_checkedLayer];
    }
    
    if (!_audioLayer) {
        self.audioLayer = [CALayer layer];
        self.audioLayer.frame = CGRectMake(5, 73, 15, 15);
        self.audioLayer.backgroundColor = [UIColor clearColor].CGColor;
        self.audioLayer.hidden = YES;
        self.audioLayer.contents = (id)[UIImage imageNamed:@"audio_icon"].CGImage;
        self.audioLayer.contentsGravity = @"resizeAspect";
        [self.layer addSublayer:self.audioLayer];
    }
}

- (void)setImage:(UIImage *)image
{
    if (_image != image) {
        [_image release];
        _image = [image retain];
    }
    _imageLayer.contents = (id)_image.CGImage;
//    _imageLayer.backgroundColor = [UIColor colorWithPatternImage:_image].CGColor;
}

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
    
    if (editing) {
        _deleteImageLayer.hidden = NO;
    } else {
        _deleteImageLayer.hidden = YES;
    }
}

- (void)setChecked:(BOOL)checked
{
    _checked = checked;
    
    if (_checked) {
        _checkedLayer.hidden = NO;
    } else {
        _checkedLayer.hidden = YES;
    }
}

- (void)setHasAudio:(BOOL)hasAudio {
    _hasAudio = hasAudio;
    
    _audioLayer.hidden = !_hasAudio;
}

- (BOOL)configCellWithModel:(MessageModel *)model
{
    BOOL success = NO;
    
    self.hasAudio = ((model.audio.audioURL.length > 0 || model.audio.wavPath.length > 0 || model.audio.amrPath.length > 0) && (model.audio.audioStatus != EMAudioSyncStatusNeedsToBeDeleted));
    UIImage *image = model.thumbnailImage;
    if (image) {
        self.image = image;
        return YES;
    }
//    self.image = [UIImage imageNamed:@"photo_mr.png"];
    NSString *thumbnailPath_abs = model.spaths;
    NSString *imageName = [[thumbnailPath_abs componentsSeparatedByString:@"/"] lastObject];
    NSString *imagePath = [Utilities dataPath:imageName FileType:@"Photos" UserID:USERID];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    model.thumbnailImage = [UIImage imageWithContentsOfFile:imagePath];
    self.image = model.thumbnailImage;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        CGSize imageSize = image.size;
        UIGraphicsBeginImageContext(imageSize);
        [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
                [self setImage:image];
                model.thumbnailImage = image;
            } else {
//                [self setImage:[UIImage imageNamed:@"photo_mr.png"]];
            }
            
        });
    });
    
    return success;
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
