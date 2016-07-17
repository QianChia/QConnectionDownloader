//
//  QConnectionDownloader.m
//  QConnectionDownloader
//
//  Created by JHQ0228 on 16/7/12.
//  Copyright © 2016年 QianQian-Studio. All rights reserved.
//

#import "QConnectionDownloader.h"
#import "QDownloaderOperation.h"

@interface QConnectionDownloader ()

/// 下载操作缓冲池
@property (nonatomic, strong) NSMutableDictionary *downloadCache;

/// 下载操作队列
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@end

@implementation QConnectionDownloader

/// 创建单例类对象

+ (instancetype)defaultDownloader {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

/// 创建下载

- (void)q_downloadWithURL:(NSURL *)url progress:(void (^)(float))progress successed:(void (^)(NSString *))successed failed:(void (^)(NSError *))failed {
    
    if (self.downloadCache[url.absoluteString] != nil) {
        return;
    }
    
    QDownloaderOperation *downloader = [QDownloaderOperation q_downloaderWithURL:url progress:progress successed:^(NSString *targetPath) {
        
        [self.downloadCache removeObjectForKey:url.absoluteString];
    
        if (successed) {
            successed(targetPath);
        }
        
    } failed:^(NSError *error) {
        
        [self.downloadCache removeObjectForKey:url.absoluteString];
        
        if (failed) {
            failed(error);
        }
    }];
    
    [self.downloadCache setObject:downloader forKey:url.absoluteString];
    [self.downloadQueue addOperation:downloader];
}

/// 暂停下载

- (void)q_pauseWithURL:(NSURL *)url {
    
    QDownloaderOperation *downloader = self.downloadCache[url.absoluteString];
    
    if (downloader != nil) {
        
        [downloader q_pauseDownload];
        [downloader cancel];
        
        [self.downloadCache removeObjectForKey:url.absoluteString];
    }
}

/// 取消下载

- (void)q_cancelWithURL:(NSURL *)url {
    
    QDownloaderOperation *downloader = self.downloadCache[url.absoluteString];
    
    if (downloader != nil) {
        
        [downloader q_cancelDownload];
        [downloader cancel];
        
        [self.downloadCache removeObjectForKey:url.absoluteString];
    }
}

/// 懒加载

- (NSMutableDictionary *)downloadCache {
    if (_downloadCache == nil) {
        _downloadCache = [NSMutableDictionary dictionary];
    }
    return _downloadCache;
}

- (NSOperationQueue *)downloadQueue {
    if (_downloadQueue == nil) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        
        _downloadQueue.maxConcurrentOperationCount = 5;
    }
    return _downloadQueue;
}

@end
