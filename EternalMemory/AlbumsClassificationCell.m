//
//  AlbumsClassificationCell.m
//  EternalMemory
//
//  Created by sun on 13-5-22.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "AlbumsClassificationCell.h"
#import "MessageModel.h"
#import "MessageSQL.h"
#import "Utilities.h"
#import "SavaData.h"
#import "MD5.h"
#import "DiaryPictureClassificationSQL.h"
@implementation AlbumsClassificationCell
@synthesize  albumsImg =_albumsImg;
@synthesize albumNameLb = _albumNameLb;
+(AlbumsClassificationCell *)viewForNib{
    UIViewController *cellController = [[UIViewController alloc] initWithNibName:@"AlbumsClassificationCell" bundle:nil];
    AlbumsClassificationCell *cell = (AlbumsClassificationCell *)cellController.view;
    cell.backgroundColor = [UIColor clearColor];
    [cellController release];
    return cell;
}
- (void)dealloc{
    RELEASE_SAFELY(_albumNameLb);
    RELEASE_SAFELY(_accessoryImg);
    RELEASE_SAFELY(_albumsImg);
    [super dealloc];
}
- (void)setData:(DiaryPictureClassificationModel *)groupModel
{

    NSString *albumNameLbText = nil;
    NSArray *arr = [MessageSQL getGroupIDMessages:groupModel.groupId AndUserId:USERID];
    NSString *count = [NSString stringWithFormat:@"%d",arr.count];
    if ([groupModel.blogcount isEqualToString:@"0"]) {
        albumNameLbText = [NSString stringWithFormat:@"%@   ",groupModel.title];
       [_albumsImg setImage:[UIImage imageNamed:@"xc_mrfm.png"]];
    }
    else
    {
        albumNameLbText = [NSString stringWithFormat:@"%@（%@）",groupModel.title, count];
        [_albumsImg setImage:[UIImage imageNamed:@"xc_mrfm.png"]];

        if (groupModel.latestPhotoURL.length > 0 || groupModel.latestPhotoPath > 0) {
            
            NSURL *url = [NSURL URLWithString:groupModel.latestPhotoURL];
            NSString *localName = [MD5 md5:[NSString stringWithFormat:@"simg_%@.png",groupModel.latestPhotoURL]];
//            NSString *path = [self dataPath:localName];
            NSString *path = [Utilities dataPath:localName FileType:@"Photos" UserID:USERID];

            NSData *data = [NSData dataWithContentsOfFile:groupModel.latestPhotoPath];
            UIImage *albumImage = nil;
            
            if (path.length > 0) {
                albumImage = [UIImage imageWithContentsOfFile:path];
                [_albumsImg setImage:albumImage];
                if (!albumImage)
                {
                    [_albumsImg setImage:[UIImage imageWithContentsOfFile:groupModel.latestPhotoPath]];
                }
            }
            else if (data.length > 0)
            {
                albumImage = [UIImage imageWithContentsOfFile:groupModel.latestPhotoPath];
                [_albumsImg setImage:albumImage];
            }
            else if(groupModel.latestPhotoPath.length > 0)
            {
                albumImage = [UIImage imageWithContentsOfFile:groupModel.latestPhotoPath];
                [_albumsImg setImage:albumImage];
            } 

            
            if (!albumImage) {

                [_albumsImg setImage:[UIImage imageNamed:@"xc_mrfm.png"]];

                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                
                [request setDownloadDestinationPath:path];
                [request startAsynchronous];
                
                [request setCompletionBlock:^{
                    UIImage *image = [UIImage imageWithContentsOfFile:path];
                    [_albumsImg setImage:image];
                }];
                
                groupModel.latestPhotoPath = path;
                [DiaryPictureClassificationSQL updateDiaryWithArr:@[groupModel]WithUserID:USERID];
            }
            else
            {
                ;
               
            }
        }
    }
    
    _albumNameLb.adjustsFontSizeToFitWidth = YES;
    [_albumNameLb setText:albumNameLbText];
    
}

#pragma mark -- img
//- (void)dowork: (NSURL*) url{
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    NSError *error;
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    NSHTTPURLResponse *response;
//    
//    NSData* retData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//
//    if (response.statusCode == 200) {
//        UIImage* img = [UIImage imageWithData:retData];
//        [self   performSelectorOnMainThread:@selector(refreshUI:) withObject:img waitUntilDone:YES];
//    }
//    [pool drain];
//}


- (void)refreshUI:(UIImage *)img
{

    [_albumsImg setImage: img];
}
#pragma mark - 保存图片至沙盒
- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    int wid = currentImage.size.width;
    int hight = currentImage.size.height;
    CGSize size = CGSizeMake(wid, hight);
    UIGraphicsBeginImageContext(size);
    [currentImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    currentImage = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imgData = UIImageJPEGRepresentation(currentImage, 1.0f);
//    NSString *fullPath = [self dataPath:imageName];
    NSString *fullPath = [Utilities dataPath:imageName FileType:@"Photos" UserID:USERID];
    [imgData writeToFile:fullPath atomically:NO];


}
//- (NSString *)dataPath:(NSString *)file
//{
//    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"ETMemory"] stringByAppendingPathComponent:@"Photoes"];
//    NSString *usernameStr = USERID;
//    NSString *fullPath = [path stringByAppendingPathComponent:usernameStr] ;
//    BOOL bo = [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
//    NSAssert(bo,@"创建Images目录失败");
//    NSString *result = [fullPath stringByAppendingPathComponent:file];
//    return result;
//}

@end
