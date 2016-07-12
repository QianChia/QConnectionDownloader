//
//  ViewController.m
//  QConnectionDownloaderExample
//
//  Created by JHQ0228 on 16/7/12.
//  Copyright © 2016年 QianQian-Studio. All rights reserved.
//

#import "ViewController.h"

#import "QDownloaderManager.h"

@interface ViewController ()

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIButton *btn;

@end

@implementation ViewController

- (void)downloadFile:(UIButton *)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];
    self.url = url;
    
    [[QDownloaderManager sharedManager] q_downloadWithURL:url progress:^(float progress) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [sender q_setButtonWithProgress:progress lineWidth:5 lineColor:nil backgroundColor:[UIColor yellowColor]];
        });
        
    } successed:^(NSString *targetPath) {
        
        NSLog(@"文件下载成功：%@", targetPath);
        
    } failed:^(NSError *error) {
        
        NSLog(@"文件下载失败：%@", error);
    }];
}

- (IBAction)startDownloadFile:(UIButton *)sender {
    
    self.btn = sender;
    [self downloadFile:sender];
}

- (IBAction)goonDownloadFile:(UIButton *)sender {
    
    [self downloadFile:self.btn];
}

- (IBAction)pauseDownloadFile:(UIButton *)sender {
    
    [[QDownloaderManager sharedManager] q_pauseWithURL:self.url];
}

- (IBAction)cancelDownloadFile:(UIButton *)sender {
    
    [[QDownloaderManager sharedManager] q_cancelWithURL:self.url];
}

@end
