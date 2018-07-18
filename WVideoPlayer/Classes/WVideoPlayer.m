//
//  WVideoPlayer.m
//  FBSnapshotTestCase
//
//  Created by 吴志强 on 2018/7/6.
//

#import "WVideoPlayer.h"

@interface WVideoPlayer ()
/**
 原始的rect
 */
@property (nonatomic,assign) CGRect originRect;


/**
 要显示的view (nil 则是显示在window上)
 */
@property (nonatomic,strong) UIView *showInView;


/**
 播放控制器
 */
@property (nonatomic,strong) WVideoPlayControlView *controlView;

@property (nonatomic,assign) WPlayState *playState;

@property (nonatomic,assign) WPlayViewState *viewState;

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


- (instancetype) init
{
    self = [super init];
    if (self) {

        self.backgroundColor = [UIColor blackColor];
        self.layer.masksToBounds = YES;


        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideControlBar)];
        tap.cancelsTouchesInView = YES;
        [self addGestureRecognizer:tap];


        //-------------------------------监听屏幕方向-------------------------------
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDeviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }

    return self;
}


- (void) showOrHideControlBar
{

}

#pragma mark - 处理播放源
/**
 播放url地址

 @param urlString url地址
 */
-(void)playWithUrlString:(NSString *)urlString;
{

}


/**
 播放本地文件

 @param fileName 文件名
 */
-(void)playWithFile:(NSString *)fileName;
{

}


#pragma mark - 处理播放事件
/**
 停止播放
 */
- (void) play;
{

}


/**
 停止播放
 */
- (void) pause;
{

}


/**
 停止播放
 */
- (void) stop;
{

}


#pragma mark - 处理设置事件
- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.originRect = frame;

    //处理控制视图
}


- (void) addSubview:(UIView *)view
{
    [super addSubview:view];
    self.showInView = view;
}
@end
