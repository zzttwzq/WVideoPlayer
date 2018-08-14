//
//  WVideoPlayItem.h
//  FBSnapshotTestCase
//
//  Created by 吴志强 on 2018/7/6.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define WBundle_Name @"WVideoPlayer.bundle"
#define WBundle_Path [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:WBundle_Name]
#define WBundle [NSBundle bundleWithPath:WBundle_Path]

//返回id对象 数据
typedef void(^IDDataBlock)(id objc);
//返回状态
typedef void (^StateBlock)(BOOL state);
//返回int 数据
typedef void (^CountBlock)(int count);
//返回float 数据
typedef void (^floatCallBack)(float update);

@interface WVideoPlayItem : NSObject
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,copy) IDDataBlock itemStatusCallBack;
@property (nonatomic,copy) IDDataBlock playBufferCallBack;

#pragma mark - 工具方法
/**
 获取缓存时间

 @param player 播放器
 @return 已经缓冲的总时间
 */
+ (NSTimeInterval)availableDuration:(AVPlayer *)player;


/**
 转换成显示的时间

 @param second 秒数
 @return 返回转换后的字符串
 */
+ (NSString *)convertTime:(CGFloat)second;


#pragma mark - 初始化方法
/**
 初始化item

 @param URLString URLString
 @return 返回初始化的item
 */
-(instancetype)initWithURLString:(NSString *)URLString;



/**
 初始化item

 @param url url
 @return 返回初始化的item
 */
-(instancetype)initWithURL:(NSURL *)url;


/**
 初始化item

 @param fileName 文件的名字
 @return 返回实例化的item
 */
-(instancetype)initWithfileName:(NSString *)fileName;


/**
 显示消息

 @param string 要显示的消息
 */
+ (void) showDebugMessage:(NSString *)string;

@end
