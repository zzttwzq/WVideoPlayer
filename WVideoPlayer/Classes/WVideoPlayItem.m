//
//  WVideoPlayItem.m
//  FBSnapshotTestCase
//
//  Created by 吴志强 on 2018/7/6.
//

#import "WVideoPlayItem.h"

@implementation WVideoPlayItem

#pragma mark - 工具方法
/**
 获取缓存时间

 @param player 播放器
 @return 已经缓冲的总时间
 */
+ (NSTimeInterval)availableDuration:(AVPlayer *)player;
{
    NSArray *loadedTimeRanges = [[player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}


/**
 转换成显示的时间

 @param second 秒数
 @return 返回转换后的字符串
 */
+ (NSString *)convertTime:(CGFloat)second;
{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}


#pragma mark - 初始化方法
/**
 初始化item

 @param URLString URLString
 @return 返回初始化的item
 */
-(instancetype)initWithURLString:(NSString *)URLString;
{
    self = [super init];
    if(self){

        [self addItemWihtURL:[NSURL URLWithString:URLString]];
    }
    return self;
}


/**
 初始化item

 @param fileName 文件的名字
 @return 返回实例化的item
 */
-(instancetype)initWithfileName:(NSString *)fileName;
{
    self = [super init];
    if(self){

        NSArray *fileInfoArray = [fileName componentsSeparatedByString:@"."];
        NSString *type = @"";
        if (fileInfoArray.count > 1){
            type = fileInfoArray[1];
        }

        NSURL *url =  [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:fileInfoArray[0] ofType:type]];
        [self addItemWihtURL:url];
    }
    return self;
}


/**
 添加播放项目

 @param url URL链接
 */
- (void) addItemWihtURL:(NSURL *)url
{
    _playerItem = [[AVPlayerItem alloc] initWithURL:url];

    if (_playerItem) {
        [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}



/**
 观察者模式 观察item的值
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:
(NSDictionary<NSString *,id> *)change context:(void *)context{

    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {

        if (_itemStatusCallBack) {
            _itemStatusCallBack(playerItem);
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {

        if (_playBufferCallBack){
            _playBufferCallBack(playerItem);
        }
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {

    }
    else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {

    }
}


/**
 显示消息

 @param string 要显示的消息
 */
+ (void) showDebugMessage:(NSString *)string;
{
    #ifdef DEBUG
        NSLog(@"%@",string);
    #endif
}


-(void)dealloc
{
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}
@end
