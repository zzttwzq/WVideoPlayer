//
//  WVideoPlayControlView.h
//  FBSnapshotTestCase
//
//  Created by 吴志强 on 2018/7/6.
//  处理用户事件 传递给 控制器
//

#import <UIKit/UIKit.h>
#import "WVideoManager.h"
#import "UIView+WZQView.h"

#define AVPLAYER_BAR_HEIGHT 50


typedef NS_ENUM(NSInteger,WPlayViewState) {
    WPlayViewState_Normalize,
    WPlayViewState_FullScreen,
};

@class WVideoPlayControlView;
@protocol WPlayControlDelegate <NSObject>

- (void) playStateChanged:(WPlayState)playState control:(WVideoPlayControlView *)control;

- (void) viewStateChanged:(WPlayViewState)viewState control:(WVideoPlayControlView *)control;

- (void) playTimeChanged:(NSTimeInterval)timeInterval;

- (void) slidingChanged:(BOOL)isSliding;

- (void) backBtnClicked;

@end

@interface WVideoPlayControlView : UIView
@property (nonatomic,assign) WPlayState playState;
@property (nonatomic,assign) WPlayViewState viewState;
@property (nonatomic,strong) UILabel *title;
@property (nonatomic,assign) BOOL showBackBtn;
@property (nonatomic,weak) id <WPlayControlDelegate> delegate;

#pragma mark - 设置播放器时间，进度等
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


/**
 更新缓冲进度

 @param currentInterval 缓冲进度
 */
- (void) updateBuffer:(NSTimeInterval)currentInterval;
@end
