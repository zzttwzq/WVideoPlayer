//
//  WVideoManager.m
//  Pods
//
//  Created by 吴志强 on 2018/7/18.
//

#import "WVideoManager.h"

@interface WVideoManager ()

@property (nonatomic,strong) AVPlayer *player;

@property (nonatomic,assign) NSTimeInterval totalSecond;
@property (nonatomic,assign) CGFloat duration;
@property (nonatomic,assign) CGFloat fps;
@property (nonatomic,strong) id playerObserve;

@end

@implementation WVideoManager
/**
 初始化播放器

 @return 返回实例化的播放器
 */
-(instancetype)init
{
    self = [super init];
    if (self) {

        _player = [AVPlayer new];
        _layer = [AVPlayerLayer playerLayerWithPlayer:_player];

        typeof(WVideoManager *)weakSelf = self;
        //        对于1分钟以内的视频就每1/30秒刷新一次页面，大于1分钟的每秒一次就行
        CMTime interval = _duration > 60 ? CMTimeMake(1, 1) : CMTimeMake(1, 30);
        //        这个方法就是每隔多久调用一次block，函数返回的id类型的对象在不使用时用-removeTimeObserver:释放，官方api是这样说的
        _playerObserve = [_player addPeriodicTimeObserverForInterval:interval
                                                               queue:dispatch_get_main_queue()
                                                          usingBlock:^(CMTime time) {

                                                              if (weakSelf.totalSecond <= CMTimeGetSeconds(time)) {

                                                                  //设置状态
                                                                  weakSelf.playState = WPlayState_Finished;
                                                                  if (weakSelf.stateChanged) {
                                                                      weakSelf.stateChanged(weakSelf.playState);
                                                                  }
                                                              }else{

                                                                  [weakSelf scheduleRefreshControl];
                                                              }
                                                          }];
    }
    return self;
}


/**
 播放到当前时间

 @param timeinterval  播放时间
 */
- (void) playWithTimeInterval:(NSTimeInterval)timeinterval;
{
    self.playState = WPlayState_Paused;

    CMTime startTime = CMTimeMakeWithSeconds(timeinterval, _fps);

    NSString *currentTime = [WVideoPlayItem convertTime:timeinterval];// 转换成播放时间
    if (_scheduleTimeChanged) {
        _scheduleTimeChanged(currentTime,timeinterval);
    }

    [self.player seekToTime:startTime completionHandler:^(BOOL finished) {

        if (!self.isSliding) {

            self.playState = WPlayState_isPlaying;
            if (self.stateChanged) {
                self.stateChanged(self.playState);
            }
        }
    }];
}

#pragma mark - 设置方法
/**
 设置播放状态

 @param playState 播放状态
 */
-(void)setPlayState:(WPlayState)playState;
{
    _playState = playState;

    if (self.playState == WPlayState_isPlaying) {

        [self.player play];
    }
    else if (self.playState == WPlayState_Paused ||
             self.playState == WPlayState_Seeking) {

        [self.player pause];
    }
    else if (self.playState == WPlayState_Finished ||
             self.playState == WPlayState_PrepareToPlay) {
        //暂停
        [self.player pause];

        //重置时间
        [self.player seekToTime:kCMTimeZero];
    }
    else if (self.playState == WPlayState_Stoped) {

        //暂停
        [self.player pause];

        //移除观察者
        [_item.playerItem cancelPendingSeeks];
        [_item.playerItem.asset cancelLoading];

        _item = nil;
    }
}



/**
 设置播放项目

 @param item item
 */
- (void) setItem:(WVideoPlayItem *)item
{
    typeof(WVideoManager *)weakSelf = self;

    _item = item;
    _item.itemStatusCallBack = ^(id objc) {

        AVPlayerItem *playerItem = (AVPlayerItem *)objc;
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {

            // 转换成秒
            weakSelf.totalSecond = playerItem.duration.value / playerItem.duration.timescale;

            // 转换成播放时间
            NSString *totaltime = [WVideoPlayItem convertTime:weakSelf.totalSecond];

            //获取总时间，并回调
            if (weakSelf.totalTimeChanged) {
                weakSelf.totalTimeChanged(totaltime,weakSelf.totalSecond);
            }

            //设置播放状态
            weakSelf.playState = WPlayState_isPlaying;
            if (weakSelf.stateChanged) {
                weakSelf.stateChanged(weakSelf.playState);
            }
            [WVideoPlayItem showDebugMessage:@"开始播放!!!"];
        }
        else if ([playerItem status] == AVPlayerStatusFailed) {

            //设置播放状态
            weakSelf.playState = WPlayState_Failed;
            if (weakSelf.stateChanged) {
                weakSelf.stateChanged(weakSelf.playState);
            }
            [WVideoPlayItem showDebugMessage:@"播放失败"];
        }
        else if ([playerItem status] == AVPlayerStatusUnknown) {

            //设置播放状态
            weakSelf.playState = WPlayState_UnKown;
            if (weakSelf.stateChanged) {
                weakSelf.stateChanged(weakSelf.playState);
            }
            [WVideoPlayItem showDebugMessage:@"播放状态未知"];
        }

        //获取播放参数
        weakSelf.duration = CMTimeGetSeconds(weakSelf.item.playerItem.asset.duration);
        NSArray *videoArray = [weakSelf.item.playerItem.asset tracksWithMediaType:AVMediaTypeVideo];
        if (videoArray.count > 0) {

            weakSelf.fps = [[videoArray objectAtIndex:0] nominalFrameRate];
        }
    };
    _item.playBufferCallBack = ^(id objc) {

        AVPlayerItem *playerItem = (AVPlayerItem *)objc;

        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度

        if (weakSelf.bufferTimeChanged) {
            weakSelf.bufferTimeChanged(totalBuffer);
        }
    };

    //放置播放源
    [self.player replaceCurrentItemWithPlayerItem:_item.playerItem];

    self.playState = WPlayState_isPlaying;
}


#pragma mark - 其他状态
/**
 更新时间
 */
- (void) scheduleRefreshControl
{
    double currentSecond = CMTimeGetSeconds(_item.playerItem.currentTime);
    if (_totalSecond >= [[NSString stringWithFormat:@"%0.0f",currentSecond] integerValue]) {

        NSString *currentTime = [WVideoPlayItem convertTime:currentSecond];// 转换成播放时间
        if (_scheduleTimeChanged) {
            _scheduleTimeChanged(currentTime,currentSecond);
        }
    }
}


/**
 更新视频管理者的播放状态

 @param state 播放状态
 */
- (void) updatePlayerState:(WPlayState)state
{
    self.playState = state;
    if (self.stateChanged){
        self.stateChanged(state);
    }
}


@end
