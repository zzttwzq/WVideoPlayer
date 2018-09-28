//
//  WVideoPlayer.h
//  FBSnapshotTestCase
//
//  Created by 吴志强 on 2018/7/6.
//

#import "WVideoPlayControlView.h"
#import "WVideoManager.h"
#import <WBasicLibrary/WBasicHeader.h>

@class WVideoPlayer;
@protocol  WPlayerProtocol <NSObject>

//------播放器播放状态
- (void) playerPlayStateChange:(WPlayState)playState player:(WVideoPlayer *)player;

//------播放器视图改变
- (void) playerViewStateChange:(WPlayViewState)viewState player:(WVideoPlayer *)player;

//------返回按钮点击
- (void) backBtnClick:(WVideoPlayer *)player;

@end


@interface WVideoPlayer : UIView<WPlayControlDelegate,WPlayManagerDelegate>
/**
 代理
 */
@property (nonatomic,weak) id<WPlayerProtocol> delegate;

/**
 要显示的view (nil 则是显示在window上)
 */
@property (nonatomic,strong) UIView *showInView;

/**
 视频拉伸模式
 */
@property (nonatomic,assign) AVLayerVideoGravity videoGravity;

/**
 自动重新播放
 */
@property (nonatomic,assign) BOOL autoReplay;

/**
 视频圆角(全屏下不显示)
 */
@property (nonatomic,assign) float cornerRadius;

/**
 显示控制图层
 */
@property (nonatomic,assign) BOOL showControlView;

/**
 显示返回按钮
 */
@property (nonatomic,assign) BOOL showBackBtn;

/**
 显示全屏按钮
 */
@property (nonatomic,assign) BOOL showFullScreenBtn;

/**
 播放视频的标题
 */
@property (nonatomic,copy) NSString *title;


/**
 获取实例化的对象

 @return 返回实例化的对象
 */
+(WVideoPlayer *)videoPlayer;


#pragma mark - 处理播放源
/**
 播放url地址

 @param urlString url地址
 */
-(void)playWithUrlString:(NSString *)urlString;


/**
 播放url地址

 @param url url地址
 */
-(void)playWithUrl:(NSURL *)url;


/**
 播放本地文件

 @param fileName 文件名
 */
-(void)playWithFile:(NSString *)fileName;


#pragma mark - 处理播放事件
/**
 停止播放
 */
- (void) play;


/**
 停止播放
 */
- (void) pause;


/**
 停止播放
 */
- (void) stop;

@end
