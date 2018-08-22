//
//  WVideoPlayer.m
//  FBSnapshotTestCase
//
//  Created by 吴志强 on 2018/7/6.
//

#import "WVideoPlayer.h"

@interface WVideoPlayer ()
/**
 播放控制界面
 */
@property (nonatomic,strong) WVideoPlayControlView *controlView;

/**
 播放管理
 */
@property (nonatomic,strong) WVideoManager *videoManager;

/**
 原始的rect
 */
@property (nonatomic,assign) CGRect originRect;
@property (nonatomic,assign) BOOL keepOriginRect;

@property (nonatomic,copy) NSString *fileName;
@property (nonatomic,copy) NSString *urlString;
@property (nonatomic,strong) NSURL *urlPath;
@end


static dispatch_once_t onceToken;
static WVideoPlayer *sharedInstance;

@implementation WVideoPlayer

#pragma mark - 初始化方法
/**
 获取实例化的对象

 @return 返回实例化的对象
 */
+(WVideoPlayer *)videoPlayer;
{
    dispatch_once(&onceToken, ^{

        sharedInstance = [WVideoPlayer new];
    });
    return sharedInstance;
}


/**
 获取实例化的对象

 @param frame 尺寸
 @return 返回实例化的对象
 */
- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self createView];
        self.frame = frame;
        self.originRect = frame;
    }
    return self;
}


/**
 获取实例化的对象

 @return 返回实例化的对象
 */
- (instancetype) init
{
    self = [super init];
    if (self) {

        [self createView];
    }
    return self;
}


- (void) createView
{
    self.backgroundColor = [UIColor blackColor];
    self.layer.masksToBounds = YES;

    //-------------------------------监听屏幕方向-------------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];


    //-------------------------------创建播放控制视图-------------------------------
    [self.controlView removeFromSuperview];
    self.controlView = [[WVideoPlayControlView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.controlView.delegate = self;
    [self addSubview:self.controlView];


    //-------------------------------创建播放监听者-------------------------------
    self.videoManager = [[WVideoManager alloc] init];
    self.videoManager.delegate = self;
    [self.layer addSublayer:self.videoManager.layer];
}

#pragma mark - 处理控制视图回调
- (void) playStateChanged:(WPlayState)playState control:(WVideoPlayControlView *)control;
{
    self.videoManager.playState = playState;

    [self bringSubviewToFront:self.controlView];

    if ([self.delegate respondsToSelector:@selector(playerPlayStateChange:player:)]) {
        [self.delegate playerPlayStateChange:playState player:self];
    }
}

- (void) viewStateChanged:(WPlayViewState)viewState control:(WVideoPlayControlView *)control;
{
    //旋转界面
    if (viewState == WPlayViewState_FullScreen) {
        [self rotateView:UIDeviceOrientationLandscapeLeft];
    }
    else{
        [self rotateView:UIDeviceOrientationPortrait];
    }

    //传递视图状态的改变
    if ([self.delegate respondsToSelector:@selector(playerPlayStateChange:player:)]){
        [self.delegate playerViewStateChange:viewState player:self];
    }
}

- (void) playTimeChanged:(NSTimeInterval)timeInterval;
{
    [self.videoManager playWithTimeInterval:timeInterval];
}

- (void) slidingChanged:(BOOL)isSliding;
{
    if (isSliding) {
        self.videoManager.playState = WPlayState_Paused;
    }

    self.videoManager.isSliding = isSliding;
}

- (void) backBtnClicked;
{
    //传递返回事件
    if ([self.delegate respondsToSelector:@selector(backBtnClick:)]){
        [self.delegate backBtnClick:self];
    }
}


#pragma mark - 处理播放器回调
- (void) playStateChanged:(WPlayState)playState manager:(WVideoManager *)manager;
{
    self.controlView.playState = playState;

    [self bringSubviewToFront:self.controlView];

    //传递播放状态的改变
    if ([self.delegate respondsToSelector:@selector(playerPlayStateChange:player:)]){
        [self.delegate playerPlayStateChange:playState player:self];
    }

    //处理自动重新播放
    if (self.autoReplay) {

        if (playState == WPlayState_Finished) {

            [self play];
//            if (_fileName) {
//                [self playWithFile:_fileName];
//            }
//            else if (_urlPath) {
//                [self playWithUrl:_urlPath];
//            }
//            else if (_urlString) {
//                [self playWithUrlString:_urlString];
//            }
        }
    }
}

- (void) totalTimeChanged:(NSString *)totalTimeString totalTime:(NSTimeInterval)totalTime playItem:(WVideoPlayItem *)playItem;
{
    [self.controlView setTotalTime:totalTimeString totalInterval:totalTime];
}

- (void) scheduleTimeChanged:(NSString *)scheduleTimeString currentTime:(NSTimeInterval)currentTime playItem:(WVideoPlayItem *)playItem;
{
    [self.controlView updateTime:scheduleTimeString currentInterval:currentTime];
}

- (void) bufferTimeChanged:(NSTimeInterval)bufferTime playItem:(WVideoPlayItem *)playItem;
{
    [self.controlView updateBuffer:bufferTime];
}

#pragma mark - 处理旋转
- (void) handleDeviceOrientationDidChange:(NSNotification *)notifi
{
//    UIDevice *device = [UIDevice currentDevice];
//    [self rotateView:device.orientation];
}


-(void)rotateView:(UIDeviceOrientation)orientation
{
    self.keepOriginRect = YES;
    [self bringSubviewToFront:self.controlView];
    
    if (orientation == UIDeviceOrientationPortrait) {

        //打开系统的状态条
        //设置WindowLevel与状态栏平级，起到隐藏状态栏的效果
        [[[UIApplication sharedApplication] keyWindow] setWindowLevel:UIWindowLevelNormal];

        [UIView animateWithDuration:0.3 animations:^{

            //更新并旋转主界面
            self.transform = CGAffineTransformMakeRotation(0/180.0 * M_PI);
            self.frame = self.originRect;
            self.layer.cornerRadius = self.cornerRadius;

            [self.showInView addSubview:self];

            //更新控制视图
            self.controlView.frame = self.bounds;

            //更新播放图层
            self.videoManager.layer.frame = self.bounds;
        }];
    }
    else if (orientation == UIDeviceOrientationLandscapeLeft ||
             orientation == UIDeviceOrientationLandscapeRight) {

        //打开系统的状态条
        [[[UIApplication sharedApplication] keyWindow] setWindowLevel:UIWindowLevelStatusBar];

        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];

        [UIView animateWithDuration:0.3 animations:^{

            //更新并旋转主界面
            if (orientation == UIDeviceOrientationLandscapeLeft) {
                self.transform = CGAffineTransformMakeRotation(90/180.0 * M_PI);
            }else{
                self.transform = CGAffineTransformMakeRotation(270/180.0 * M_PI);
            }
            self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            self.layer.cornerRadius = 0;
            self.center = CGPointMake(ScreenWidth/2, ScreenHeight/2);

            //更新控制视图
            self.controlView.frame = self.bounds;

            //更新playerview
            self.videoManager.layer.frame = self.bounds;
        }];
    }
}


#pragma mark - 处理播放源
/**
 播放url地址

 @param urlString url地址
 */
-(void)playWithUrlString:(NSString *)urlString;
{
    _urlString = urlString;
    self.videoManager.item = [[WVideoPlayItem alloc] initWithURLString:urlString];
}


/**
 播放本地文件

 @param fileName 文件名
 */
-(void)playWithFile:(NSString *)fileName;
{
    _fileName = fileName;
    self.videoManager.item = [[WVideoPlayItem alloc] initWithfileName:fileName];
}



/**
 播放url地址

 @param url url地址
 */
-(void)playWithUrl:(NSURL *)url;
{
    _urlPath = url;
    self.videoManager.item = [[WVideoPlayItem alloc] initWithURL:url];
}


#pragma mark - 处理播放事件
/**
 停止播放
 */
- (void) play;
{
    self.controlView.playState = WPlayState_isPlaying;
    self.videoManager.playState = WPlayState_isPlaying;
}


/**
 停止播放
 */
- (void) pause;
{
    self.controlView.playState = WPlayState_Paused;
    self.videoManager.playState = WPlayState_Paused;
}


/**
 停止播放
 */
- (void) stop;
{
    self.controlView.playState = WPlayState_Stoped;
    self.videoManager.playState = WPlayState_Stoped;
}


#pragma mark - 处理设置事件
- (void) setCornerRadius:(float)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = _cornerRadius;
}

- (void) setTitle:(NSString *)title
{
    _title = title;
    self.controlView.title.text = title;
}

- (void) setShowBackBtn:(BOOL)showBackBtn
{
    _showBackBtn = showBackBtn;
    self.controlView.showBackBtn = showBackBtn;
}

- (void) setShowFullScreenBtn:(BOOL)showFullScreenBtn
{
    _showFullScreenBtn = showFullScreenBtn;
    self.controlView.showFullScreenBtn = showFullScreenBtn;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];

    if (!_keepOriginRect){
        self.originRect = frame;
    }
    self.keepOriginRect = NO;

    //处理控制视图
    self.controlView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.videoManager.layer.frame = self.bounds;
}

- (void) setShowInView:(UIView *)showInView
{
    _showInView = showInView;
    [_showInView addSubview:self];
}

- (void) setShowControlView:(BOOL)showControlView
{
    _showControlView = showControlView;
    if (!showControlView) {
        
        [_controlView removeFromSuperview];
    }
}

- (void) setVideoGravity:(AVLayerVideoGravity)videoGravity
{
    _videoGravity = videoGravity;
    self.videoManager.layer.videoGravity = _videoGravity;
}

- (void) setAutoReplay:(BOOL)autoReplay
{
    _autoReplay = autoReplay;
    self.videoManager.autoReplay = self.autoReplay;
}

//- (void) addSubview:(UIView *)view
//{
//    [super addSubview:view];
//
//    if (!_keepOriginView){
//        self.showInView = view;
//    }
//    self.keepOriginView = NO;
//}

- (void)dealloc
{

}
@end
