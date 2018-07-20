//
//  WVideoPlayControlView.h
//  FBSnapshotTestCase
//
//  Created by 吴志强 on 2018/7/6.
//

#import <UIKit/UIKit.h>
#import "WVideoManager.h"

//处理用户事件 传递给 控制器
//改变状态

typedef NS_ENUM(NSInteger,WPlayViewState) {
    WPlayViewState_Normalize,
    WPlayViewState_FullScreen,
};

#define AVPLAYER_BAR_HEIGHT 50

//视频界面状态改变回调
typedef void(^WPlayViewChanged)(WPlayViewState state);
//视频时间改变
typedef void(^WPlayTimeChanged)(NSTimeInterval playTime);
//视频拖拽改变
typedef void(^WPlaySlideChanged)(BOOL state);

@interface WVideoPlayControlView : UIView
@property (nonatomic,assign) WPlayState playState;
@property (nonatomic,assign) WPlayViewState viewState;

/**
 视频界面改变
 */
@property (nonatomic,copy) WPlayViewChanged viewChanged;

/**
 视频状态改变
 */
@property (nonatomic,copy) WPlayStateChanged playStateChanged;

/**
 视频播放时间改变
 */
@property (nonatomic,copy) WPlayTimeChanged playTimeChanged;

/**
 视频拖拽状态改变
 */
@property (nonatomic,copy) WPlaySlideChanged slideChanged;

/**
 视频返回按钮点击
 */
@property (nonatomic,copy) WPlaySlideChanged backBtnClick;


/**
 设置总时间

 @param totalTime 总的时间字符串
 @param totalInterval 总的时间
 */
- (void) setTotalTime:(NSString *)totalTime
        totalInterval:(NSTimeInterval)totalInterval;


/**
 更新时间

 @param currentTime 当前时间字符串
 @param currentInterval 当前时间
 */
- (void) updateTime:(NSString *)currentTime
    currentInterval:(NSTimeInterval)currentInterval;
@end
