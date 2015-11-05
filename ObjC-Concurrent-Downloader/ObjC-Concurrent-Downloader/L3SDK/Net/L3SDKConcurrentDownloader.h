//
//  ConcurrentDownloader.h
//  ObjC-Concurrent-Downloader
//
//  Created by Domenico Vacchiano on 05/11/15.
//  Copyright © 2015 DomenicoVacchiano. All rights reserved.
//

#import <Foundation/Foundation.h>

//protocol to describe the download events
@protocol L3SDKConcurrentDownloaderDelegate <NSObject>
//raised when the download is completed
-(void) L3SDKConcurrentDownloader_Completed:(NSData*)data forSender:(id)sender isCancelled:(BOOL)isCancelled;
//raised during the downaload process
-(void) L3SDKConcurrentDownloader_Downloading:(NSUInteger)receivedBytes ofTotalBytes:(NSUInteger)totalBytes forSender:(id)sender;
@optional
//raised if occur an error
-(void) L3SDKConcurrentDownloader_Error:(NSException*)exception;
@end


@interface L3SDKConcurrentDownloader : NSOperation <NSURLSessionTaskDelegate,NSURLSessionDataDelegate>
//custom factory initialization with the url of the download file
-(instancetype)initWithURLString:(NSString*)url;
//allows to suspend the download
-(void) suspend;
//allows to resume the downlaod
-(void)resume;

//gets/sets the delegate to respond to the ConcurrentDownloaderDelegate protocol
@property (nonatomic,strong)id<L3SDKConcurrentDownloaderDelegate> delegate;
@end
