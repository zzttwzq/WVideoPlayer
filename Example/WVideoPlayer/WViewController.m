//
//  WViewController.m
//  WVideoPlayer
//
//  Created by zzttwzq on 07/18/2018.
//  Copyright (c) 2018 zzttwzq. All rights reserved.
//

#import "WViewController.h"
#import <WVideoPlayer/WVideoPlayer.h>

@interface WViewController ()

@end

@implementation WViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    WVideoPlayer *player = [WVideoPlayer videoPlayer];
    player.frame = CGRectMake(0, 0, ScreenWidth, 300);
    player.cornerRadius = 10;
    [player playWithUrlString:@""];
    [self.view addSubview:player];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
