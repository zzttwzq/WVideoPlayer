//
//  WVideoPlayer.h
//  FBSnapshotTestCase
//
//  Created by 吴志强 on 2018/7/6.
//

#import <WExpandLibrary/WExpandHeader.h>
#import <WBasicLibrary/WBasicHeader.h>
#import "WVideoPlayControlView.h"
#import "WVideoManager.h"


@class WVideoPlayer;
@protocol  WPlayerProtocol <NSObject>
//------播放器播放生命周期
//播放器准备播放
- (void) playerPreparePlay:(WVideoPlayer *)player;
//播放器开始播放
- (void) playerDidPlay:(WVideoPlayer *)player;
//播放器结束播放
- (void) playerFinishPlay:(WVideoPlayer *)player;


//------播放器播放状态
- (void) playerPlayStateChange:(WPlayState)playState player:(WVideoPlayer *)player;

//------播放器视图改变
- (void) playerViewStateChange:(WPlayViewState)viewState player:(WVideoPlayer *)player;


//------返回按钮点击
- (void) backBtnClick;
@end


@interface WVideoPlayer : UIView



#pragma mark - 播放属性
@property (nonatomic,assign) int cornerRadio;


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
