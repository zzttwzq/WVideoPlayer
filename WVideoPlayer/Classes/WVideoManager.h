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

@class WVideoManager;
@protocol WPlayManagerDelegate <NSObject>

- (void) playStateChanged:(WPlayState)playState manager:(WVideoManager *)manager;

- (void) totalTimeChanged:(NSString *)totalTimeString totalTime:(NSTimeInterval)totalTime playItem:(WVideoPlayItem *)playItem;

- (void) scheduleTimeChanged:(NSString *)scheduleTimeString currentTime:(NSTimeInterval)currentTime playItem:(WVideoPlayItem *)playItem;

- (void) bufferTimeChanged:(NSTimeInterval)bufferTime playItem:(WVideoPlayItem *)playItem;

@end

@interface WVideoManager : NSObject
@property (nonatomic,weak) id<WPlayManagerDelegate> delegate;

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
 播放到当前时间

 @param timeinterval  播放时间
 */
- (void) playWithTimeInterval:(NSTimeInterval)timeinterval;

@end
