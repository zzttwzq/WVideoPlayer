//
//  WVideoManager.h
//  Pods
//
//  Created by 吴志强 on 2018/7/18.
//

#import <Foundation/Foundation.h>
#import "WVideoPlayItem.h"

typedef NS_ENUM(NSInteger,WPlayState) {
    WPlayState_PrepareToPlay,
    WPlayState_isPlaying,
    WPlayState_Paused,
    WPlayState_Stoped,
    WPlayState_Finished,
    WPlayState_Seeking,
    WPlayState_Failed,
    WPlayState_UnKown,
};

//视频播放状态改变回调
typedef void(^WPlayStateChanged)(WPlayState state);
//视频总时间改变回调
typedef void(^WPlayTotalTimeChanged)(NSString * _Nullable totalTime,NSTimeInterval totalSecond);
//视频定时器改变时间回调
typedef void(^WPlayScheduleTimeChanged)(NSString * _Nullable currentTime,NSTimeInterval currentSecond);
//视频缓冲进度回调
typedef void(^WPlayBufferTimeChanged)(NSTimeInterval currentSecond);

@interface WVideoManager : NSObject

/**
 播放图层
 */
@property (nonatomic,strong) AVPlayerLayer *layer;



/**
 设置播放源
 */
@property (nonatomic,strong) WVideoPlayItem *item;

/**
 播放状态
 */
@property (nonatomic,assign) WPlayState playState;

/**
 进度条正在被拖拽
 */
@property (nonatomic,assign) BOOL isSliding;



/**
 播放状态改变
 */
@property (nonatomic,copy) WPlayStateChanged stateChanged;

/**
 总时间的改变
 */
@property (nonatomic,copy) WPlayTotalTimeChanged totalTimeChanged;

/**
 更新时间
 */
@property (nonatomic,copy) WPlayScheduleTimeChanged scheduleTimeChanged;

/**
 更新时间
 */
@property (nonatomic,copy) WPlayBufferTimeChanged bufferTimeChanged;


/**
 播放到当前时间

 @param timeinterval  播放时间
 */
- (void) playWithTimeInterval:(NSTimeInterval)timeinterval;

@end
