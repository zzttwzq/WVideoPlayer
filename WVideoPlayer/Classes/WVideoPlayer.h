//
//  WVideoPlayer.h
//  FBSnapshotTestCase
//
//  Created by 吴志强 on 2018/7/6.
//

#import "WVideoPlayControlView.h"
#import "WVideoManager.h"
#import "UIView+WZQView.h"

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
@property (nonatomic,assign) float cornerRadius;
@property (nonatomic,assign) BOOL showBackBtn;
@property (nonatomic,assign) BOOL showFullScreenBtn;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,weak) id<WPlayerProtocol> delegate;
/**
 要显示的view (nil 则是显示在window上)
 */
@property (nonatomic,strong) UIView *showInView;


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
