//
//  QDownloaderOperation.m
//  QConnectionDownloader
//
//  Created by JHQ0228 on 16/7/11.
//  Copyright © 2016年 QianQian-Studio. All rights reserved.
//

#import "QDownloaderOperation.h"

@interface QDownloaderOperation () <NSURLConnectionDataDelegate>

/// 下载文件总长度
@property (nonatomic, assign) long long expectedContentLength;

/// 已下载文件大小
@property (nonatomic, assign) long long recvedfileLength;

/// 下载目标目录
@property (nonatomic, copy) NSString *targetPath;

/// 下载文件输出数据流
@property (nonatomic, strong) NSOutputStream *fileStream;

/// block 属性
@property (nonatomic, copy) void (^progressBlock)(float);
@property (nonatomic, copy) void (^successedBlock)(NSString *);
@property (nonatomic, copy) void (^failedBlock)(NSError *);

/// 网络连接属性
@property (nonatomic, strong) NSURLConnection *conn;
@property (nonatomic, strong) NSURL *downloadURL;

@end

@implementation QDownloaderOperation

/// 创建下载操作

+ (instancetype)q_downloaderWithURL:(NSURL *)url progress:(void (^)(float))progress successed:(void (^)(NSString *))successed failed:(void (^)(NSError *))failed {
    
    QDownloaderOperation *downloader = [[self alloc] init];
    
    downloader.progressBlock = progress;
    downloader.successedBlock = successed;
    downloader.failedBlock = failed;
    
    downloader.downloadURL = url;
    
    return downloader;
}

/// 暂停下载操作

- (void)q_pauseDownload {
    
    [self.conn cancel];
}

/// 取消下载操作

- (void)q_cancelDownload {
    
    [self.conn cancel];
    [[NSFileManager defaultManager] removeItemAtPath:self.targetPath error:NULL];
}

/// 执行操作

- (void)main {
    @autoreleasepool {
        
        [self checkServerFileInfoWithURL:self.downloadURL];
        
        if (self.isCancelled) return;
        
        [self checkLocalFileInfo];
        
        if (self.recvedfileLength == self.expectedContentLength) {
            if (self.successedBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.successedBlock(self.targetPath);
                });
                
                if (self.progressBlock) {
                    self.progressBlock(1.0);
                }
            }
            return;
        }
        
        [self downloadWithURL:self.downloadURL offset:self.recvedfileLength];
    }
}

/**
 *  检查服务器上的文件信息
 *
 *  @param url  下载地址
 */
- (void)checkServerFileInfoWithURL:(NSURL *)url {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"HEAD";
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error == nil && response != nil) {
        self.expectedContentLength = response.expectedContentLength;
        self.targetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename];
    }
}

/**
 *  检查本地文件信息
 *
 *  @return 本地文件长度
 */
- (void)checkLocalFileInfo {
    
    long long fileSize = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.targetPath]) {
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:self.targetPath error:NULL];
        fileSize = [dict fileSize];
    }
    
    if (fileSize > self.expectedContentLength) {
        [[NSFileManager defaultManager] removeItemAtPath:self.targetPath error:NULL];
        self.recvedfileLength = 0;
    } else {
        self.recvedfileLength = fileSize;
    }
}

/**
 *  从断点处开始下载
 *
 *  @param url      下载地址
 *  @param offset   本地文件大小
 */
- (void)downloadWithURL:(NSURL *)url offset:(long long)offset {
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:15];
    [urlRequest setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    self.conn = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    [self.conn start];
    
    CFRunLoopRun();
}

/// 协议方法

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    self.fileStream = [[NSOutputStream alloc] initToFileAtPath:self.targetPath append:YES];
    [self.fileStream open];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    [self.fileStream write:data.bytes maxLength:data.length];

    self.recvedfileLength += data.length;
    float progress = (float)self.recvedfileLength / self.expectedContentLength;

    if (self.progressBlock) {
        self.progressBlock(progress);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    [self.fileStream close];
    
    if (self.successedBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.successedBlock(self.targetPath);
        });
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    [self.fileStream close];
    
    if (self.failedBlock) {
        self.failedBlock(error);
    }
}

@end
