//
//  WVideoPlayer.m
//  FBSnapshotTestCase
//
//  Created by 吴志强 on 2018/7/6.
//

#import "WVideoPlayer.h"

@interface WVideoPlayer ()
/**
 模糊涂层
 */
@property (nonatomic,strong) UIVisualEffectView *effectView;

/**
 是否显示控制条
 */
@property (nonatomic,assign) BOOL isShowControl;

/**
 原始的rect
 */
@property (nonatomic,assign) CGRect originRect;

@end

static dispatch_once_t onceToken;
static WVideoPlayer *sharedInstance;

@implementation WVideoPlayer

#pragma mark - 初始化方法
/**
 获取实例化的对象

 @param frame 尺寸
 @return 返回实例化的对象
 */
+(WVideoPlayer *)instenceWithFrame:(CGRect)frame;
{
    dispatch_once(&onceToken, ^{

        sharedInstance = [[self alloc] initWithFrame:frame];
    });
    return sharedInstance;
}


/**
 初始化

 @param frame 尺寸
 @return 返回实例化对象
 */
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor blackColor];
        self.originRect = frame;
        self.layer.masksToBounds = YES;

        WEAK_SELF(WVideoPlayer);

        // 添加模糊效果视图
        //        _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        //        _effectView.frame = CGRectMake(0, 100, 320, 200);
        //        [self addSubview:_effectView];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideControlBar)];
        tap.cancelsTouchesInView = YES;
        [self addGestureRecognizer:tap];

        _control = [[WVideoPlayer alloc] initWithFrame:frame];
        _control.stateChanged = ^(WPlayState state) {

            if (state == WPlayState_isPlaying) {

                weakSelf.isShowControl = YES;
            }else if (state == WPlayState_Finished ||
                      state == WPlayState_Stoped ||
                      state == WPlayState_Paused) {

                weakSelf.isShowControl = YES;
            }
        };
        _control.viewChanged = ^(WPlayViewState state) {

                //控制器重新赋值
            if (state) {

                [weakSelf rotateView:UIDeviceOrientationLandscapeLeft];
            }else {

                [weakSelf rotateView:UIDeviceOrientationPortrait];
            }
        };
        _control.backBtnClick = ^(BOOL state) {

            if (weakSelf.backBtnClick) {
                weakSelf.backBtnClick(state);
            }
        };
        [self addSubview:_control];

        //加载视频图层
        [self.layer addSublayer:[self.control.manager getPlayLayer]];
        //总是显示控制条
        _isShowControl = YES;


            //-------------------------------监听屏幕方向-------------------------------
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDeviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil
         ];
    }
    return self;
}



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


/**
 停止播放
 */
-(void)stopPlay;
{

}
@end
