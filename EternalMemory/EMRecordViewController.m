//
//  EMRecordViewController.m
//  EternalMemory
//
//  Created by FFF on 14-2-18.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "EMRecordViewController.h"
#import "EMRecordEngine.h"
#import "Utilities.h"
#import "MessageModel.h"
#import "MessageSQL.h"
//#import "VoiceConverter.h"
#import "EMAudio.h"
#import "EMAudioUploader.h"
#import "RequestParams.h"
#import "EMPhotoSyncEngine.h"
#import "RecordPromptView.h"

#include "amrFileCodec.h"

@import AVFoundation;

@interface EMRecordViewController ()<UIAlertViewDelegate>
{
    
    AVAudioPlayer *audioPlayer;
}

@property (nonatomic, copy) NSString *audioPath;
@property (nonatomic, retain) EMAudio *audio;
@property (retain, nonatomic) IBOutlet UIButton *stopRecordButton;
@property (retain, nonatomic) IBOutlet UIButton *listeningTestButton;
@property (retain, nonatomic) IBOutlet UIButton *finashButton;

- (IBAction)stopRecord:(id)sender;
- (IBAction)listeningTest:(id)sender;
- (IBAction)finash:(id)sender;
- (IBAction)close:(id)sender;
- (void)stopListenTest;

@end

@implementation EMRecordViewController
@synthesize backImage = _backImage;
@synthesize recordPromptView = _recordPromptView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{ 
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:_backImage];
    self.listeningTestButton.hidden = YES;
    self.finashButton.hidden = YES;
    self.finashButton.alpha = 0;
    self.listeningTestButton.alpha = 0;
    __block typeof(self) this = self;

    _recordPromptView = [[RecordPromptView alloc] initWithFrame:self.view.bounds WithSelectPhoto:NO];
    _recordPromptView.userInteractionEnabled = YES;
//    UIWindow *tempWindow=[[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [self.view addSubview:_recordPromptView];
    _recordPromptView.stopRecord = ^(void){
        [this stopRecord:nil];
    };
    _recordPromptView.deleteRecord = ^(void){
        [this close:nil];
    };
    _recordPromptView.uploadRecord = ^(void){
        [this finash:nil];
    };
    _recordPromptView.listenRecord = ^(void){
        [this listeningTest:nil];
    };
    _recordPromptView.stopListenRecord = ^(void){
        [this stopListenTest];
    };
    
    [self startRecord];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopRecord:) name:EMRecordTimeupNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRecordTimeTooShortNotification:) name:EMRecordTimeTooShortNotification object:nil];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_stopRecordButton release];
    [_listeningTestButton release];
    [_finashButton release];
    [_model release];
    [_stopBlock release];
    [_dismissBlock release];
    [_timeTooShortBlock release];
    [super dealloc];
}

- (void)handleRecordTimeTooShortNotification:(NSNotification *)notification {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startRecord {
    NSString *fileName = [Utilities audioFileNameWithType:@"wav"];
    
    [EMRecordEngine sharedEngine].maxRecordTime = 300;
    [[EMRecordEngine sharedEngine] startRecordWithFilename:fileName];
}

- (IBAction)stopRecord:(id)sender {
    
    if (self.stopBlock) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        __block typeof(self) bself = self;
        [[EMRecordEngine sharedEngine] stopRecordWithCompletionBlock:^(NSString *path, CGFloat duration) {
            EMAudio *audio = [EMAudio new];
            audio.wavPath = path;
            audio.duration = duration;
            
            bself.stopBlock(audio);
            [audio release];
        }];
        return;
    }
    
    __block typeof(self) bself = self;
    [[EMRecordEngine sharedEngine] stopRecordWithCompletionBlock:^(NSString *path, CGFloat duration) {
        if (duration < 1) {
            bself.model.audio.wavPath = @"";
            bself.model.audio.amrPath = @"";
            bself.model.audio.audioURL = @"";
            bself.model.audio.duration = 0;
            if (self.timeTooShortBlock) {
                self.timeTooShortBlock(self.model.audio);
            }
            return;
        }
        bself.audioPath = path;
        bself.model.audio.wavPath = path;
        bself.model.audio.duration = duration;
    }];
    
    [self animateWithDuration:0.3f];
}

- (IBAction)listeningTest:(id)sender {
    NSData *audioData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.audioPath]];
    audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
    [audioPlayer prepareToPlay];
    audioPlayer.delegate = self;
    [audioPlayer play];

//    [audioPlayer release];
}
- (void)stopListenTest
{
    [audioPlayer stop];
    [audioPlayer release];
    audioPlayer = nil;
}

- (IBAction)close:(id)sender {
    if (audioPlayer)
    {
        [audioPlayer stop];
        [audioPlayer release];
        audioPlayer = nil;
    }
    
//    if (audioPlayer.isPlaying) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"返回后将会删除这段录音，您确定要删除么？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        [alert release];
//    } else {
//        if (self.dismissBlock) {
//            self.dismissBlock(nil);
//        }
//    }
    
    

}

/**
 *  完成按钮点击调用的方法。讲录音文件由wav转码为amr格式，封装成EMAudio交给EMAudioUploader处理上传操作。
 *
 *  @param sender UIButton实例
 */
- (IBAction)finash:(id)sender {
    if (audioPlayer)
    {
        [audioPlayer stop];
        [audioPlayer release];
        audioPlayer = nil;
    }
    NSString *wavPath = self.audioPath;
    NSString *amrFileName = [Utilities audioFileNameWithType:@"amr"];
    
    NSString *amrPath = [Utilities dataPath:amrFileName FileType:@"Audioes" UserID:USERID];
    __block typeof(self) this = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        EMAudio *audio = this.model.audio;
        audio.audioData = [NSData dataWithContentsOfFile:amrPath];
        audio.ID = this.model.ID;
        audio.amrPath = amrPath;
        audio.blogId = this.model.blogId;
        this.model.audio = audio;
        
        //    [self dismissViewControllerAnimated:YES completion:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (this.dismissBlock) {
                this.dismissBlock(audio);
            }
        });
        if (! EncodeWAVEFileToAMRFile([wavPath cStringUsingEncoding:NSASCIIStringEncoding], [amrPath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16)) {
        }
        
        audio.audioData = [NSData dataWithContentsOfFile:amrPath];
        EMAudioUploader *uploader = [EMAudioUploader sharedUploader];
        [uploader startUploadAudio:this.model.audio];
        [_recordPromptView removeFromSuperview];
    });
    
}


#pragma mark - AVAudioDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"recordReceiveEnd" object:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger index = buttonIndex;
    switch (index) {
        case 0:
            ;
            break;
        case 1:
            [self stopAndDeleteThePlayingAudio];
            break;
        default:
            break;
    }
}

#pragma mark -

- (void)stopAndDeleteThePlayingAudio {
    __block typeof(self) bself = self;
    [[EMRecordEngine sharedEngine] stopRecordWithCompletionBlock:^(NSString *path, CGFloat duration) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        bself.model.audio.audioData = nil;
        bself.model.audio.wavPath = nil;
        bself.model.audio.amrPath = nil;
        bself.model.audio.size = 0;
        bself.model.audio.duration = 0;
    }];
    [_recordPromptView removeFromSuperview];
    //    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.dismissBlock) {
        self.dismissBlock(nil);
    }
}



- (void)animateWithDuration:(CGFloat)duration {
    __block typeof(self) bself = self;
    [UIView animateWithDuration:duration animations:^{
        bself.stopRecordButton.alpha = 0;
        bself.finashButton.hidden = NO;
        bself.listeningTestButton.hidden = NO;
        
        bself.finashButton.alpha = 1;
        bself.listeningTestButton.alpha = 1;
    }];
}

- (BOOL)shouldAutorotate {
    return NO;
}

    
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_recordPromptView setsubViewFrameWithState:toInterfaceOrientation];
}

@end
