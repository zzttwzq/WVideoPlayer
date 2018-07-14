//
//  WVideoPlayer.h
//  FBSnapshotTestCase
//
//  Created by 吴志强 on 2018/7/6.
//

#import <UIKit/UIKit.h>
#import "WVideoPlayControlView.h"
#import "WVideoControl.h"

typedef void(^stateBlock)(BOOL state);
//@

@interface WVideoPlayer : UIView
/**
 播放控制器
 */
@property (nonatomic,strong) WVideoPlayControlView *controlView;


/**
 要显示的view (nil 则是显示在window上)
 */
@property (nonatomic,strong) UIView *showInView;


/**
 返回按钮点击回调
 */
@property (nonatomic,copy) stateBlock backBtnClick;


/**
 获取实例化的对象

 @param frame 尺寸
 @return 返回实例化的对象
 */
+(WVideoPlayer *)instenceWithFrame:(CGRect)frame;


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


/**
 停止播放
 */
-(void)stopPlay;
@end
