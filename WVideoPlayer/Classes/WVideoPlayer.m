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

/**
 要显示的view (nil 则是显示在window上)
 */
@property (nonatomic,strong) UIView *showInView;
@property (nonatomic,assign) BOOL keepOriginView;

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

    typeof(WVideoPlayer *)weakSelf = self;

    //-------------------------------监听屏幕方向-------------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

    
    //-------------------------------创建播放控制视图-------------------------------
    self.controlView = [[WVideoPlayControlView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.controlView.playStateChanged = ^(WPlayState state) {

        weakSelf.videoManager.playState = state;
    };
    self.controlView.playTimeChanged = ^(NSTimeInterval playTime) {

        [weakSelf.videoManager playWithTimeInterval:playTime];
    };
    self.controlView.slideChanged = ^(BOOL state) {

        if (state) {
            weakSelf.videoManager.playState = WPlayState_Paused;
        }

        weakSelf.videoManager.isSliding = state;
    };
    self.controlView.viewChanged = ^(WPlayViewState state) {

        //旋转界面
        if (state == WPlayViewState_FullScreen) {
            [weakSelf rotateView:UIDeviceOrientationLandscapeLeft];
        }
        else{
            [weakSelf rotateView:UIDeviceOrientationPortrait];
        }

        //传递视图状态的改变
        if ([weakSelf.delegate respondsToSelector:@selector(playerPlayStateChange:player:)]){
            [weakSelf.delegate playerViewStateChange:state player:weakSelf];
        }
    };
    self.controlView.backBtnClick = ^(BOOL state) {

        //传递返回事件
        if ([weakSelf.delegate respondsToSelector:@selector(backBtnClick:)]){
            [weakSelf.delegate backBtnClick:weakSelf];
        }
    };
    [self addSubview:self.controlView];


    //-------------------------------创建播放监听者-------------------------------
    self.videoManager = [[WVideoManager alloc] init];
    self.videoManager.stateChanged = ^(WPlayState state) {

        weakSelf.controlView.playState = state;

        //传递播放状态的改变
        if ([weakSelf.delegate respondsToSelector:@selector(playerPlayStateChange:player:)]){
            [weakSelf.delegate playerPlayStateChange:state player:weakSelf];
        }
    };
    self.videoManager.totalTimeChanged = ^(NSString * _Nullable totalTime, NSTimeInterval totalSecond) {

        [weakSelf.controlView setTotalTime:totalTime totalInterval:totalSecond];
    };
    self.videoManager.scheduleTimeChanged = ^(NSString * _Nullable currentTime, NSTimeInterval currentSecond) {

        [weakSelf.controlView updateTime:currentTime currentInterval:currentSecond];
    };
    self.videoManager.bufferTimeChanged = ^(NSTimeInterval currentSecond) {

        [weakSelf.controlView updateBuffer:currentSecond];
    };
    [self.layer addSublayer:self.videoManager.layer];

}

- (void) setShowBackBtn:(BOOL)showBackBtn
{
    _showBackBtn = showBackBtn;
    self.controlView.showBackBtn = showBackBtn;
}

#pragma mark - 处理旋转
- (void) handleDeviceOrientationDidChange:(NSNotification *)notifi
{
    UIDevice *device = [UIDevice currentDevice];
    [self rotateView:device.orientation];
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

        NSLog(@">>>UIDeviceOrientationLandscapeLeft");

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
    self.videoManager.item = [[WVideoPlayItem alloc] initWithURLString:urlString];
}


/**
 播放本地文件

 @param fileName 文件名
 */
-(void)playWithFile:(NSString *)fileName;
{
    self.videoManager.item = [[WVideoPlayItem alloc] initWithfileName:fileName];
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

- (void) addSubview:(UIView *)view
{
    [super addSubview:view];

    if (!_keepOriginView){
        self.showInView = view;
    }
    self.keepOriginView = NO;
}
@end
