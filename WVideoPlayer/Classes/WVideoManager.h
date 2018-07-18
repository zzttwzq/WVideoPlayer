//
//  WVideoManager.h
//  Pods
//
//  Created by 吴志强 on 2018/7/18.
//

#import <Foundation/Foundation.h>

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

@interface WVideoManager : NSObject

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

@end
