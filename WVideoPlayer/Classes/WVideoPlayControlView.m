//
//  WVideoPlayControlView.m
//  FBSnapshotTestCase
//
//  Created by 吴志强 on 2018/7/6.
//

#import "WVideoPlayControlView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface WVideoPlayControlView ()

@property (nonatomic,strong) UIImageView *playIMG;
@property (nonatomic,strong) UIImageView *retryBtn;
@property (nonatomic,strong) UILabel *currentTime;
@property (nonatomic,strong) UILabel *totalTime;
@property (nonatomic,strong) UIImageView *fullScreen;
@property (nonatomic,strong) UIView *fullScreenTapView;
@property (nonatomic,strong) UISlider *currentProgress;
@property (nonatomic,strong) UIProgressView *currentProgress2;
@property (nonatomic,strong) UIProgressView *bufferProgress;
@property (nonatomic,strong) UILabel *valueLab;
@property (nonatomic,strong) UIImageView *backImage;

@property (nonatomic,strong) MPVolumeView *volumeView;
@property (nonatomic,strong) UIView *lightControlView;
@property (nonatomic,strong) UIView *volumeControlView;

@property (nonatomic,strong) UITapGestureRecognizer *tap;

@property (nonatomic,assign) BOOL keepOriginRect;
@property (nonatomic,assign) CGRect originRect;
@property (nonatomic,assign) NSTimeInterval totalInterVals;

@property (nonatomic,strong) UIView *backView;
@property (nonatomic,assign) BOOL isSliding;

@property (nonatomic,assign) int timeCount;
@property (nonatomic, strong) NSTimer *timer; //定时器

#define MYBUNDLE_PATH [[NSBundle mainBundle] pathForResource:@"WVideoPlayer" ofType:@"bundle"]

#define MYBUNDLE        [NSBundle bundleWithPath:MYBUNDLE_PATH]

@end

@implementation WVideoPlayControlView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {

        _playState = WPlayState_PrepareToPlay;
        _viewState = WPlayViewState_Normalize;

        self.userInteractionEnabled = YES;
        self.opaque = YES;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];

        //所有控件的父视图
        _backView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_backView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideControlBar)];
        [self addGestureRecognizer:tap];

        //-------------------------------touchview-------------------------------
//        _lightControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width/2, self.height)];
//        _lightControlView.alpha = 0;
//        [_lightControlView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(lightControlTouch:)]];
//        [_backView addSubview:_lightControlView];
//
//        _volumeControlView = [[UIView alloc] initWithFrame:CGRectMake(self.width/2, 0, self.width/2, self.height)];
//        _volumeControlView.alpha = 0;
//        [_volumeControlView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(volumeControlTouch:)]];
//        [_backView addSubview:_volumeControlView];

        
        //=======返回按钮
        _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, ScreenWidth, 30)];
        _title.font = [UIFont systemFontOfSize:18];
        _title.textColor = [UIColor whiteColor];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.alpha = 0;
        [_backView addSubview:_title];

        _backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 30, 30)];
        _backImage.image = [UIImage imageNamed:@"left_back_icon_white_60x60"];
        _backImage.userInteractionEnabled = YES;
        [_backImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back)]];
        [_backView addSubview:_backImage];

        //-------------------------------播放控制器区-------------------------------
        int playImgHeight = 50;

        _playIMG = [[UIImageView alloc] init];
        _playIMG.frame = CGRectMake((self.width-playImgHeight)/2, (self.height-playImgHeight)/2, playImgHeight, playImgHeight);
        _playIMG.image = [UIImage imageNamed:@"btn_video_play_90x90"];
        _playIMG.userInteractionEnabled = YES;
        [_playIMG addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(play)]];
        [_backView addSubview:_playIMG];


        _retryBtn = [[UIImageView alloc] initWithFrame:CGRectMake((self.width-60)/2, (self.height-30)/2, 60, 30)];
        _retryBtn.image = [UIImage imageNamed:@"btn_play_again_icon_160x80"];
        _retryBtn.userInteractionEnabled = YES;
        _retryBtn.alpha = 0;
        [_retryBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retry)]];
        [_backView addSubview:_retryBtn];


        _valueLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
        _valueLab.font = [UIFont systemFontOfSize:18];
        _valueLab.textColor = [UIColor whiteColor];
        _valueLab.textAlignment = NSTextAlignmentCenter;
        _valueLab.alpha = 0;
        [_backView addSubview:_valueLab];


        //=======全屏按钮
        _currentTime = [[UILabel alloc] initWithFrame:CGRectMake(10, self.height-AVPLAYER_BAR_HEIGHT, 40, AVPLAYER_BAR_HEIGHT)];
        _currentTime.font = [UIFont systemFontOfSize:13];
        _currentTime.textColor = [UIColor whiteColor];
        _currentTime.text = @"00:00";
        _currentTime.textAlignment = NSTextAlignmentCenter;
        [_backView addSubview:_currentTime];


        //=======全屏按钮
        _fullScreen = [[UIImageView alloc] initWithFrame:CGRectMake(self.width-25, (AVPLAYER_BAR_HEIGHT-15)/2+_currentTime.top, 15, 15)];
        _fullScreen.image = [UIImage imageNamed:@"video_amplification"];
        [_backView addSubview:_fullScreen];


        //=======全屏按钮
        _fullScreenTapView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth-50, self.height-50, 50, 50)];
        [_fullScreenTapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullScreen)]];
        [_backView addSubview:_fullScreenTapView];


        //=======总的时间
        _totalTime = [[UILabel alloc] initWithFrame:CGRectMake(_fullScreen.left-45, _currentTime.top, 40, _currentTime.height)];
        _totalTime.font = [UIFont systemFontOfSize:13];
        _totalTime.textColor = [UIColor whiteColor];
        _totalTime.text = @"00:00";
        _totalTime.textAlignment = NSTextAlignmentCenter;
        [_backView addSubview:_totalTime];


        //=======当前播放进度条
//        _bufferProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(_currentTime.right+5, _currentTime.top, self.width-_currentTime.width-_totalTime.width-_fullScreen.width-20-15, _currentTime.height)];
//        _bufferProgress.center = _currentProgress.center;
//        _bufferProgress.tintColor = [UIColor whiteColor];
//        [_backView addSubview:_bufferProgress];

        _currentProgress = [[UISlider alloc] initWithFrame:CGRectMake(_currentTime.right+5, _currentTime.top, self.width-_currentTime.width-_totalTime.width-_fullScreen.width-20-15, _currentTime.height)];
        _currentProgress.minimumValue = 0;
        _currentProgress.value = 0;
        _currentProgress.tintColor = [UIColor whiteColor];
//        [_currentProgress setMaximumTrackTintColor:[UIColor redColor]];
//        [_currentProgress setMinimumTrackTintColor:[UIColor redColor]];
//        [_currentProgress settra];

        [_currentProgress setThumbImage:[UIImage imageNamed:@"椭圆-1"] forState:UIControlStateNormal];
        [_currentProgress setThumbImage:[UIImage imageNamed:@"椭圆-1"] forState:UIControlStateHighlighted];
        [_backView addSubview:_currentProgress];



//        _currentProgress2 = [[UIProgressView alloc] initWithFrame:CGRectMake(0, self.height-2, self.width, 2)];
//        _currentProgress2.alpha = 0;
//        _currentProgress2.tintColor = [UIColor whiteColor];
//        [self addSubview:_currentProgress2];


        //=======当前进度条操作事件
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollTap:)];
        [_tap setNumberOfTouchesRequired:1];
        [_currentProgress addGestureRecognizer:_tap];
        [_currentProgress addTarget:self action:@selector(handleTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_currentProgress addTarget:self action:@selector(progressChanged) forControlEvents:UIControlEventValueChanged];
        [_currentProgress addTarget:self action:@selector(handleTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [_currentProgress addTarget:self action:@selector(handleTouchUp:) forControlEvents:UIControlEventTouchUpOutside];

//        [_currentProgress addTarget:self action:@selector(handleTouchUp:) forControlEvents:UIControlEventTouchDragInside];
//        [_currentProgress addTarget:self action:@selector(handleTouchUp:) forControlEvents:UIControlEventTouchDragOutside];

        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideControl) userInfo:nil repeats:YES];
    }
    return self;
}


/**
 设置总时间

 @param totalTime 总的时间字符串
 @param totalInterval 总的时间
 */
- (void) setTotalTime:(NSString *)totalTime
        totalInterval:(NSTimeInterval)totalInterval;
{
    self.totalTime.text = totalTime;
    self.currentProgress.maximumValue = totalInterval;
    _totalInterVals = totalInterval;
}


/**
 更新时间

 @param currentTime 当前时间字符串
 @param currentInterval 当前时间
 */
- (void) updateTime:(NSString *)currentTime
      currentInterval:(NSTimeInterval)currentInterval;
{
//    NSLog(@">>>%f",currentInterval);
    self.currentTime.text = currentTime;
    self.currentProgress.value = currentInterval;
    self.currentProgress2.progress = currentInterval/_totalInterVals;
}


/**
 更新缓冲进度

 @param currentInterval 缓冲进度
 */
- (void) updateBuffer:(NSTimeInterval)currentInterval;
{
//    NSLog(@"+++%f",currentInterval);
    self.bufferProgress.progress = currentInterval/_totalInterVals;
}


#pragma mark - 处理点击事件
- (void) showOrHideControlBar
{
    [UIView animateWithDuration:0.3 animations:^{

        if (self.backView.alpha == 0) {

            self.backView.alpha = 1;
            self.currentProgress2.alpha = 0;
        }else{

            self.backView.alpha = 0;
            self.currentProgress2.alpha = 1;
        }
    }];

    if (self.backView.alpha == 1 &&
        !self.isSliding &&
        self.playState == WPlayState_isPlaying &&
        _timeCount == 0) {

        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideControl) userInfo:nil repeats:YES];
    }
}


- (void) hideControl
{
    if (_timeCount < 3) {

        _timeCount ++;
    }
    else{

        [self showOrHideControlBar];
        [self cancelTimer];
    }
}


/**
 取消定时器
 */
-(void)cancelTimer
{
    _timeCount = 0;
    //取消定时器
    [self.timer invalidate];
    self.timer = nil;
}


- (void) showFullScreen
{
    if (self.viewState == WPlayViewState_FullScreen) {

        self.viewState = WPlayViewState_Normalize;
    }
    else{

        self.viewState = WPlayViewState_FullScreen;
    }

    if ([self.delegate respondsToSelector:@selector(viewStateChanged:control:)]) {
        [self.delegate viewStateChanged:self.viewState control:self];
    }
}

-(void)retry
{
    self.playState = WPlayState_isPlaying;
    if ([self.delegate respondsToSelector:@selector(playStateChanged:control:)]) {
        [self.delegate playStateChanged:self.playState control:self];
    }
}


-(void)play
{
    if (self.playState == WPlayState_Paused ||
        self.playState == WPlayState_PrepareToPlay ||
        self.playState == WPlayState_Finished) {

        [self cancelTimer];
        [self showOrHideControlBar];
        self.playState = WPlayState_isPlaying;
    }
    else if (self.playState == WPlayState_isPlaying) {

        [self cancelTimer];
        self.playState = WPlayState_Paused;
    }

    if ([self.delegate respondsToSelector:@selector(playStateChanged:control:)]) {
        [self.delegate playStateChanged:self.playState control:self];
    }
}

- (void) progressChanged
{
    //赋值播放时间
    self.currentTime.text = [WVideoPlayItem convertTime:self.currentProgress.value];

    //播放时间变化回调
    if ([self.delegate respondsToSelector:@selector(playTimeChanged:)]) {
        [self.delegate playTimeChanged:self.currentProgress.value];
    }
}


-(void)scrollTap:(UITapGestureRecognizer *)recognizer
{
        //    CGPoint touchPoint = [recognizer locationInView:_currentProgress];
        //    CGFloat value = touchPoint.x / CGRectGetWidth(_currentProgress.frame);
        //    [_currentProgress setValue:value animated:YES];
        //
        //    //让视频从指定处播放
        //    [self.manager playWithVaule:10000 percent:value];
}


- (void)handleTouchDown:(UITapGestureRecognizer *)sender
{
    _tap.enabled = NO;
    self.isSliding = YES;

    if ([self.delegate respondsToSelector:@selector(slidingChanged:)]) {
        [self.delegate slidingChanged:self.isSliding];
    }
}

- (void)handleTouchUp:(UITapGestureRecognizer *)sender
{
    _tap.enabled = YES;
    self.isSliding = NO;

    if ([self.delegate respondsToSelector:@selector(slidingChanged:)]) {
        [self.delegate slidingChanged:self.isSliding];
    }
}

-(void)back
{
    if (self.viewState == WPlayViewState_FullScreen) {

        self.viewState = WPlayViewState_Normalize;

        if ([self.delegate respondsToSelector:@selector(viewStateChanged:control:)]) {
            [self.delegate viewStateChanged:self.viewState control:self];
        }
    }
    else{

        if ([self.delegate respondsToSelector:@selector(backBtnClicked)]) {
            [self.delegate backBtnClicked];
        }
    }
}

#pragma mark - 设置亮度和音量
-(void)lightControlTouch:(UIPanGestureRecognizer *)pan
{
    CGPoint moviePoint = [pan translationInView:self];
    float screenBrightNess = -moviePoint.y/300;
    screenBrightNess += [WVideoPlayControlView getScreenBrightness];
    if (screenBrightNess >= 1) {

        screenBrightNess = 1;
    }else if (screenBrightNess <= -1) {

        screenBrightNess = 0;
    }

    //设置屏幕亮度
    [WVideoPlayControlView setScreenBrightness:screenBrightNess];
        //设置百分比
//    [self setHintLab:screenBrightNess];
}


-(void)volumeControlTouch:(UIPanGestureRecognizer *)pan
{
    CGPoint moviePoint = [pan translationInView:self];
    float volume = -moviePoint.y/300;
    volume += [WVideoPlayControlView getScreenBrightness];
    if (volume >= 1) {

        volume = 1;
    }else if (volume <= -1) {

        volume = 0;
    }

//        设置系统音量
//    [self setSystemVolume:volume];
//        //设置百分比
//    [self setHintLab:volume];
}


/**
 设置系统屏幕亮度

 @param brightness 屏幕亮度
 */
+(void)setScreenBrightness:(CGFloat)brightness;
{
    [[UIScreen mainScreen] setBrightness:brightness];
}


/**
 获取屏幕亮度

 @return 返回屏幕亮度
 */
+(float)getScreenBrightness;
{
    return [UIScreen mainScreen].brightness;
}

#pragma mark - 处理设置事件
- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];

    if (!_keepOriginRect){
        self.originRect = frame;
    }
    self.keepOriginRect = NO;

    [self reSetFrames];
}


- (void) setShowBackBtn:(BOOL)showBackBtn
{
    _showBackBtn = showBackBtn;
    if (!_showBackBtn &&
        self.viewState == WPlayViewState_Normalize) {
        self.backImage.alpha = 0;
    }
}


/**
 重新设置按钮的位置
 */
- (void) reSetFrames
{
    _backView.frame = self.bounds;

    _lightControlView.frame = CGRectMake(0, 0, self.width/2, self.height);

    _volumeControlView.frame = CGRectMake(self.width/2, 0, self.width/2, self.height);

    //=======返回按钮
    _backImage.frame = CGRectMake(0, 10, 30, 30);

    //-------------------------------播放控制器区-------------------------------
    //=======播放暂停按钮
    int playImgHeight = 50;
    _playIMG.frame = CGRectMake((self.width-playImgHeight)/2, (self.height-playImgHeight)/2, playImgHeight, playImgHeight);

    //=======重试按钮
    _retryBtn.frame = CGRectMake((self.width-60)/2, (self.height-30)/2, 60, 30);

    //=======显示声音和亮度百分比
    _valueLab.frame = CGRectMake(0, 0, ScreenWidth, 30);

    //=======当前时间
    _currentTime.frame = CGRectMake(10, self.height-AVPLAYER_BAR_HEIGHT, 40, AVPLAYER_BAR_HEIGHT);

    //=======全屏按钮图片
    _fullScreen.frame = CGRectMake(self.width-25, (AVPLAYER_BAR_HEIGHT-15)/2+_currentTime.top, 15, 15);

    //=======全屏按钮点击区域
    _fullScreenTapView.frame = CGRectMake(self.width-50, self.height-50, 50, 50);

    //=======总的时间
    _totalTime.frame = CGRectMake(_fullScreen.left-45, _currentTime.top, 40, _currentTime.height);

    //=======当前播放进度条
    _currentProgress.frame = CGRectMake(_currentTime.right+5, _currentTime.top, self.width-_currentTime.width-_totalTime.width-_fullScreen.width-20-15, _currentTime.height);

    _bufferProgress.frame = _currentProgress.frame;
    _bufferProgress.center = _currentProgress.center;

    _currentProgress2.frame = CGRectMake(0, self.height-2, self.width, 2);
}


/**
 设置播放状态

 @param playState 播放状态
 */
-(void)setPlayState:(WPlayState)playState;
{
    _playState = playState;

    if (self.playState == WPlayState_isPlaying ||
        self.playState == WPlayState_Stoped) {

        //播放按钮
        self.playIMG.image = [UIImage imageNamed:@"btn_video_stop_90x90"];
        self.playIMG.alpha = 1;

        //关闭重试按钮
        self.retryBtn.alpha = 0;
    }
    else if (self.playState == WPlayState_Paused ||
             self.playState == WPlayState_Seeking) {

        //播放按钮
        self.playIMG.image = [UIImage imageNamed:@"btn_video_play_90x90"];
        self.playIMG.alpha = 1;

        //关闭重试按钮
        self.retryBtn.alpha = 0;
    }
    else if (self.playState == WPlayState_Finished ||
             self.playState == WPlayState_PrepareToPlay) {

        //播放按钮
        self.playIMG.image = [UIImage imageNamed:@"btn_video_play_90x90"];
        self.playIMG.alpha = 0;
        self.retryBtn.alpha = 1;

        //重置控制器
        self.currentTime.text = @"00:00";
        self.currentProgress.value = 0;
    }
}


-(void)setViewState:(WPlayViewState)viewState
{
    //已经最小化想全屏
    if (_viewState == WPlayViewState_Normalize) {

        _viewState = WPlayViewState_FullScreen;

        //全屏按钮
        _fullScreen.image = [UIImage imageNamed:@"narrow_btn"];
        _lightControlView.alpha = 0;
        _volumeControlView.alpha = 0;
        _backImage.alpha = 1;

        self.keepOriginRect = YES;
        self.frame = self.originRect;
    }
    //已经全皮想最小化
    else if (_viewState == WPlayViewState_FullScreen) {

        _viewState = WPlayViewState_Normalize;

        //全屏按钮
        _fullScreen.image = [UIImage imageNamed:@"video_amplification"];
        _lightControlView.alpha = 1;
        _volumeControlView.alpha = 1;
        if (!_showBackBtn &&
            self.viewState == WPlayViewState_Normalize) {
            self.backImage.alpha = 0;
        }

        self.keepOriginRect = YES;
        self.frame = CGRectMake(0, 0, ScreenHeight, ScreenWidth);
    }
}

- (void) setShowFullScreenBtn:(BOOL)showFullScreenBtn
{
    _showFullScreenBtn = showFullScreenBtn;
    if (!showFullScreenBtn) {

        [_fullScreen removeFromSuperview];
        [self reSetFrames];
    }
}


- (void)dealloc
{

}
@end
