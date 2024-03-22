//
//  CPDFSoundPlayBar.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//


#import "CPDFSoundPlayBar.h"

#import "CAnnotStyle.h"

#import <AVFAudio/AVFAudio.h>
#import <AVFoundation/AVFoundation.h>

#import <ComPDFKit/ComPDFKit.h>

typedef NS_ENUM(NSInteger, CPDFAudioState) {
    CPDFAudioState_Pause,
    CPDFAudioState_Recording,
    CPDFAudioState_Playing,
};

#define SOUND_TMP_DICT [NSTemporaryDirectory() stringByAppendingPathComponent:@"soundCache"]

@interface CPDFSoundPlayBar ()<AVAudioPlayerDelegate>

@property (nonatomic, strong) CAnnotStyle *annotStyle;

@property (nonatomic, strong) NSTimer *voiceTimer;

@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UILabel *timeDisplayLabel;

@property (nonatomic, strong) NSDateFormatter *formatter;

@property (nonatomic, strong) AVAudioRecorder *avAudioRecorder;

@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer;

@property (nonatomic,assign) CPDFSoundState soundState;

@property (nonatomic,assign) CPDFAudioState state;

@end

@implementation CPDFSoundPlayBar

#pragma mark - Initializers

- (instancetype)initWithStyle:(CAnnotStyle *)annotStyle {
    if (self = [super init]) {
        self.annotStyle = annotStyle;
        
        [self setDateFormatter];

        [self initWithView];
    }
    return self;
}

#pragma mark - Accessors

- (void)setDateFormatter {
    if (nil == _formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
        [_formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        _formatter.dateFormat = @"HH:mm:ss";
    }
}

#pragma mark - Public

- (void)showInView:(UIView *)subView soundState:(CPDFSoundState)soundState  {
    self.soundState = soundState;

    if(CPDFSoundStatePlay == soundState) {
        self.frame = CGRectMake((subView.frame.size.width - 146.0)/2, subView.frame.size.height - 120 - 10, 146.0, 40);
        self.sureButton.hidden = YES;
        self.closeButton.frame = CGRectMake(self.frame.size.width - 8 - 24, (self.frame.size.height - 24.0)/2, 24, 24);
        [self.playButton setImage:[UIImage imageNamed:@"CPDFSoundImageNamePlay" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    } else if (CPDFSoundStateRecord == soundState) {
        self.frame = CGRectMake((subView.frame.size.width - 174.0)/2, subView.frame.size.height - 120 - 10, 174.0, 40);
        self.sureButton.hidden = NO;
        self.sureButton.frame = CGRectMake(self.frame.size.width - 8 - 24, (self.frame.size.height - 24.0)/2, 24, 24);
        self.closeButton.frame = CGRectMake(self.frame.size.width - 8 - 24 - self.sureButton.frame.size.width - 10, (self.frame.size.height - 24.0)/2, 24, 24);
        [self.playButton setImage:[UIImage imageNamed:@"CPDFSoundImageNamePlay" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    }
    self.layer.cornerRadius = 5.0;
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [subView addSubview:self];
}

- (void)setURL:(NSURL *)url {
    if (self.soundState == CPDFSoundStateRecord) {
        [self audioRecorderInitWithURL:url];
    }else if (self.soundState == CPDFSoundStatePlay){
        [self audioPlayerInitWithURL:url];
    }
    [self setDateFormatter];
}

- (void)startRecord {
    self.state = CPDFAudioState_Recording;

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    if ([_avAudioRecorder prepareToRecord]) {
        [_avAudioRecorder record];
    }else{
        NSLog(@"error:unprepare to record!");
        return;
    }
}

- (void)stopRecord {
    self.state = CPDFAudioState_Pause;
    [self stopTimer];
    if (_avAudioRecorder.currentTime > 0.1) {
        [_avAudioRecorder stop];
        NSURL *url = _avAudioRecorder.url;
        NSString *path = [url path];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:path]) {
            if ([self.delegate respondsToSelector:@selector(soundPlayBarRecordFinished:withFile:)]) {
                [self.delegate soundPlayBarRecordFinished:self withFile:path];
            }
        }
    } else {
        [_avAudioRecorder stop];
    }
    
    [self removeFromSuperview];
}

- (void)startAudioPlay {
    self.state = CPDFAudioState_Playing;
    NSError* err = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:&err];
    [[AVAudioSession sharedInstance] setActive:YES error:&err];
    if (err) {
        return;
    }
    
    [self startTimer];
    [_avAudioPlayer play];
}

- (void)stopAudioPlay{
    self.state = CPDFAudioState_Pause;
    if (_avAudioPlayer.playing) {
        [_avAudioPlayer stop];
    }
    [self stopTimer];
    
    _timeDisplayLabel.text = @"00:00:00";
    
    [self.playButton setImage:[UIImage imageNamed:@"CPDFSoundImageNameStop" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
}

#pragma mark - Private

- (void)initWithView {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.frame = CGRectMake(8, 8, 24, 24);
    [self.playButton setImage:[UIImage imageNamed:@"CPDFSoundImageNamePlay" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(buttonItemClicked_Play:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playButton];
    
    _timeDisplayLabel = [[UILabel alloc] init];
    _timeDisplayLabel.backgroundColor = [UIColor clearColor];
    _timeDisplayLabel.textColor = [UIColor whiteColor];
    _timeDisplayLabel.font = [UIFont systemFontOfSize:13.0];
    _timeDisplayLabel.text = @"00:00:00";
    [_timeDisplayLabel sizeToFit];
    _timeDisplayLabel.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame)+ 10, 8, _timeDisplayLabel.frame.size.width + 20, 24.0);
    [self addSubview:_timeDisplayLabel];
    
    self.sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sureButton.frame = CGRectMake(self.frame.size.width - 8 - 24, 8, 24, 24);
    self.sureButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.sureButton setImage:[UIImage imageNamed:@"CPDFSoundImageNameSure" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.sureButton addTarget:self action:@selector(buttonItemClicked_Sure:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sureButton];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.closeButton.frame = CGRectMake(self.frame.size.width - 8 - 24 - self.sureButton.frame.size.width - 10, 8, 24, 24);
    self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.closeButton setImage:[UIImage imageNamed:@"CPDFSoundImageNameClose" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(buttonItemClicked_Close:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];
}

- (void)startAudioRecord {
    [self setURL:nil];

    [self startTimer];
    [self startRecord];
}

- (void)startTimer {
    if (_voiceTimer) {
        [_voiceTimer invalidate];
        _voiceTimer = nil;
    }
    _voiceTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(reflashAsTimeGoesBy) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (_voiceTimer) {
        [_voiceTimer invalidate];
        _voiceTimer = nil;
    }
}

- (void)audioRecorderInitWithURL:(NSURL *)url {
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:11025] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    if (!url) {
        NSString *path = NULL;
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL isDict = NO;
        BOOL dictOK = NO;
        if ([manager fileExistsAtPath:SOUND_TMP_DICT isDirectory:&isDict] && isDict){
            dictOK = YES;
        }else{
            if ([manager createDirectoryAtPath:SOUND_TMP_DICT withIntermediateDirectories:NO attributes:nil error:nil]) {
                dictOK = YES;
            }
        }
        
        if (dictOK) {
            for (NSInteger i=0; i<NSIntegerMax; i++) {
                path = [NSString stringWithFormat:@"%@/%@_%ld.%s",SOUND_TMP_DICT,@"tmp",i,"wav"];
                if (![manager fileExistsAtPath:path]) {
                    break;
                }
            }
        }else{
            NSLog(@"tmp file dict error!");
        }
        url = [NSURL fileURLWithPath:path];
    }
    
    if (_avAudioRecorder) {
        _avAudioRecorder = nil;
    }
    NSError *error = nil;
    _avAudioRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
    _avAudioRecorder.meteringEnabled = YES;
}

- (void)audioPlayerInitWithURL:(NSURL *)url {
    if (_avAudioPlayer) {
        _avAudioPlayer = nil;
    }
    
    NSError *error = nil;
    _avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [_avAudioPlayer setVolume:1.0];
    _avAudioPlayer.delegate = self;
}

#pragma mark - Action

- (IBAction)buttonItemClicked_Play:(id)sender {
    if (self.soundState == CPDFSoundStateRecord) {
        if(CPDFAudioState_Pause == self.state) {
            [self.playButton setImage:[UIImage imageNamed:@"CPDFSoundImageNamePlay" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            [self startTimer];
            [self startRecord];
            _state = CPDFAudioState_Recording;
        } else {
            [self.playButton setImage:[UIImage imageNamed:@"CPDFSoundImageNameRec" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            [self stopTimer];
            [_avAudioRecorder pause];
            self.state = CPDFAudioState_Pause;
        }
    } else if(self.soundState == CPDFSoundStatePlay) {
        if(CPDFAudioState_Pause == self.state) {
            [self.playButton setImage:[UIImage imageNamed:@"CPDFSoundImageNamePlay" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            [self startTimer];
            [_avAudioPlayer play];
            _state = CPDFAudioState_Playing;
        } else {
            [self.playButton setImage:[UIImage imageNamed:@"CPDFSoundImageNameStop" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            
            [self stopTimer];
            [_avAudioPlayer pause];
            _state = CPDFAudioState_Pause;
        }
    }
}

- (IBAction)buttonItemClicked_Sure:(id)sender {
    if (self.soundState == CPDFSoundStateRecord) {
        [self stopRecord];
    }
}

- (IBAction)buttonItemClicked_Close:(id)sender {
    [self removeFromSuperview];
    if (self.soundState == CPDFSoundStateRecord) {
        [_avAudioRecorder stop];
        if ([self.delegate respondsToSelector:@selector(soundPlayBarRecordCancel:)]) {
            [self.delegate soundPlayBarRecordCancel:self];
        }
    } else if(self.soundState == CPDFSoundStatePlay) {
        [self stopAudioPlay];

        if ([self.delegate respondsToSelector:@selector(soundPlayBarPlayClose:)]) {
            [self.delegate soundPlayBarPlayClose:self];
        }
    }
}

- (void)reflashAsTimeGoesBy {
    NSTimeInterval time;
    
    if (self.soundState == CPDFSoundStateRecord) {
        time = _avAudioRecorder.currentTime;
        [_avAudioRecorder updateMeters];
        
        NSDate *dateToShow = [NSDate dateWithTimeIntervalSince1970:time];
        NSString *stringToShow = [_formatter stringFromDate:dateToShow];
        _timeDisplayLabel.text = stringToShow;
        
        if (time >= 3600 ) {
            [self stopRecord];
        }
    }else if (self.soundState == CPDFSoundStatePlay){
        time = _avAudioPlayer.currentTime;
        
        NSDate *dateToShow = [NSDate dateWithTimeIntervalSince1970:time];
        NSString *stringToShow = [_formatter stringFromDate:dateToShow];
        _timeDisplayLabel.text = stringToShow;
    }
}

#pragma mark - AvaudioPlayer delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopAudioPlay];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
    [self stopAudioPlay];
}

@end
