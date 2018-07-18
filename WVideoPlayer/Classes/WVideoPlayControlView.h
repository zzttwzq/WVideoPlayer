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

#define AVPLAYER_BAR_HEIGHT 60

//视频界面状态改变回调
typedef void(^WPlayViewChanged)(WPlayViewState state);

@interface WVideoPlayControlView : UIView

@property (nonatomic,assign) WPlayState playState;
@property (nonatomic,assign) WPlayViewState viewState;

@property (nonatomic,copy) WPlayViewChanged viewChanged;
@property (nonatomic,copy) WPlayStateChanged stateChanged;

@end
