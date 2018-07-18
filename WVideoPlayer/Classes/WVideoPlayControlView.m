//
//  WVideoPlayControlView.m
//  FBSnapshotTestCase
//
//  Created by 吴志强 on 2018/7/6.
//

#import "WVideoPlayControlView.h"
#import <WExpandLibrary/WExpandHeader.h>
#import <WBasicLibrary/WBasicHeader.h>
#import <MediaPlayer/MediaPlayer.h>

@interface WVideoPlayControlView ()

@property (nonatomic,strong) UIImageView *playIMG;
@property (nonatomic,strong) UIImageView *retryBtn;
@property (nonatomic,strong) UILabel *currentTime;
@property (nonatomic,strong) UILabel *totalTime;
@property (nonatomic,strong) UIImageView *fullScreen;
@property (nonatomic,strong) UIView *fullScreenTapView;
@property (nonatomic,strong) UISlider *currentProgress;
@property (nonatomic,strong) UILabel *valueLab;
@property (nonatomic,strong) UIImageView *backImage;

@property (nonatomic,strong) MPVolumeView *volumeView;
@property (nonatomic,strong) UIView *lightControlView;
@property (nonatomic,strong) UIView *volumeControlView;

@property (nonatomic,strong) UITapGestureRecognizer *tap;

@property (nonatomic,assign) BOOL isFullScreen;
@property (nonatomic,assign) CGRect originRect;
@end

@implementation WVideoPlayControlView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    if (self) {

        _playState = WPlayState_PrepareToPlay;
        _viewState = WPlayViewState_Normalize;

        self.userInteractionEnabled = YES;
        self.opaque = YES;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];

        //-------------------------------touchview-------------------------------
        _lightControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width/2, self.height)];
        _lightControlView.alpha = 0;
        [_lightControlView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(lightControlTouch:)]];
        [self addSubview:_lightControlView];

        _volumeControlView = [[UIView alloc] initWithFrame:CGRectMake(self.width/2, 0, self.width/2, self.height)];
        _volumeControlView.alpha = 0;
        [_volumeControlView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(volumeControlTouch:)]];
        [self addSubview:_volumeControlView];



        //=======返回按钮
        _backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 30, 30)];
        _backImage.image = [UIImage imageNamed:@"left_back_icon_white_40x40"];
        _backImage.userInteractionEnabled = YES;
        [_backImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back)]];
        [self addSubview:_backImage];

        //-------------------------------播放控制器区-------------------------------
        int playImgHeight = 50;

        _playIMG = [[UIImageView alloc] init];
        _playIMG.frame = CGRectMake((self.width-playImgHeight)/2, (self.height-playImgHeight)/2, playImgHeight, playImgHeight);
        _playIMG.image = [UIImage imageNamed:@"btn_video_play_90x90"];
        _playIMG.userInteractionEnabled = YES;
        [_playIMG addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(play)]];
        [self addSubview:_playIMG];


        _retryBtn = [[UIImageView alloc] initWithFrame:CGRectMake((self.width-60)/2, (self.height-30)/2, 60, 30)];
        _retryBtn.image = [UIImage imageNamed:@"btn_play_again_icon_160x80"];
        _retryBtn.userInteractionEnabled = YES;
        _retryBtn.alpha = 0;
        [_retryBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retry)]];
        [self addSubview:_retryBtn];


        _valueLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
        _valueLab.font = [UIFont systemFontOfSize:18];
        _valueLab.textColor = [UIColor whiteColor];
        _valueLab.textAlignment = NSTextAlignmentCenter;
        _valueLab.alpha = 0;
        [self addSubview:_valueLab];


        //=======全屏按钮
        _currentTime = [[UILabel alloc] initWithFrame:CGRectMake(10, self.height-AVPLAYER_BAR_HEIGHT, 40, AVPLAYER_BAR_HEIGHT)];
        _currentTime.font = [UIFont systemFontOfSize:13];
        _currentTime.textColor = [UIColor whiteColor];
        _currentTime.text = @"00:00";
        _currentTime.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_currentTime];


        //=======全屏按钮
        _fullScreen = [[UIImageView alloc] initWithFrame:CGRectMake(self.width-25, (AVPLAYER_BAR_HEIGHT-15)/2+_currentTime.top, 15, 15)];
        _fullScreen.image = [UIImage imageNamed:@"video_amplification"];
        [self addSubview:_fullScreen];


        //=======全屏按钮
        _fullScreenTapView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth-50, self.height-50, 50, 50)];
        [_fullScreenTapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullScreen)]];
        [self addSubview:_fullScreenTapView];


        //=======总的时间
        _totalTime = [[UILabel alloc] initWithFrame:CGRectMake(_fullScreen.left-45, _currentTime.top, 40, _currentTime.height)];
        _totalTime.font = [UIFont systemFontOfSize:13];
        _totalTime.textColor = [UIColor whiteColor];
        _totalTime.text = @"00:00";
        _totalTime.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_totalTime];





        //=======当前播放进度条
        _currentProgress = [[UISlider alloc] initWithFrame:CGRectMake(_currentTime.right+5, _currentTime.top, self.width-_currentTime.width-_totalTime.width-_fullScreen.width-20-15, _currentTime.height)];
        _currentProgress.minimumValue = 0;
        _currentProgress.value = 0;
        _currentProgress.tintColor = [UIColor whiteColor];
        [_currentProgress setThumbImage:[UIImage imageNamed:@"椭圆-1"] forState:UIControlStateNormal];
        [_currentProgress setThumbImage:[UIImage imageNamed:@"椭圆-1"] forState:UIControlStateHighlighted];


        //=======当前进度条操作事件
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollTap:)];
        [_tap setNumberOfTouchesRequired:1];
        [_currentProgress addGestureRecognizer:_tap];
        [_currentProgress addTarget:self action:@selector(handleTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_currentProgress addTarget:self action:@selector(progressChanged) forControlEvents:UIControlEventValueChanged];
        [_currentProgress addTarget:self action:@selector(handleTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [_currentProgress addTarget:self action:@selector(handleTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [self addSubview:_currentProgress];
    }
    return self;
}

#pragma mark - 设置亮度和音量
-(void)leftTap:(UIPanGestureRecognizer *)pan
{
    CGPoint moviePoint = [pan translationInView:self];
    float screenBrightNess = -moviePoint.y/300;
    screenBrightNess += [WDevice getScreenBrightness];
    if (screenBrightNess >= 1) {

        screenBrightNess = 1;
    }else if (screenBrightNess <= -1) {

        screenBrightNess = 0;
    }

        //设置屏幕亮度
    [WDevice setScreenBrightness:screenBrightNess];
        //设置百分比
//    [self setHintLab:screenBrightNess];
}


-(void)rightTap:(UIPanGestureRecognizer *)pan
{
    CGPoint moviePoint = [pan translationInView:self];
    float volume = -moviePoint.y/300;
    volume += [WDevice getScreenBrightness];
    if (volume >= 1) {

        volume = 1;
    }else if (volume <= -1) {

        volume = 0;
    }

        //设置系统音量
//    [self setSystemVolume:volume];
//        //设置百分比
//    [self setHintLab:volume];
}


@end
