//
//  QDownloaderOperation.h
//  QConnectionDownloader
//
//  Created by JHQ0228 on 16/7/11.
//  Copyright © 2016年 QianQian-Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDownloaderOperation : NSOperation

/**
 *  创建下载操作
 *
 *  @param url          下载地址
 *  @param progress     下载进度回调，子线程回调
 *  @param successed    下载成功回调，主线程回调
 *  @param failed       下载失败回调，子线程回调
 *
 *  @return 文件下载操作
*/
+ (instancetype)q_downloaderWithURL:(NSURL *)url progress:(void (^)(float progress))progress successed:(void (^)(NSString *targetPath))successed failed:(void (^)(NSError *error))failed;

/**
 *  暂停下载操作
 *
 *  停止下载
 *
 *  @param url  下载地址
 */
- (void)q_pauseDownload;

/**
 *  取消下载操作
 *
 *  停止下载，并删除已经下载的文件
 *
 *  @param url  下载地址
 */
- (void)q_cancelDownload;

@end
