//
//  ConcurrentDownloader.m
//  ObjC-Concurrent-Downloader
//
//  Created by Domenico Vacchiano on 05/11/15.
//  Copyright © 2015 DomenicoVacchiano. All rights reserved.
//

#import "L3SDKConcurrentDownloader.h"

@interface L3SDKConcurrentDownloader ()
//downloaded data
@property (nonatomic) NSMutableData *fileData;
//total bytes received
@property (nonatomic) NSUInteger totalBytes;
//current bytes received
@property (nonatomic) NSUInteger receivedBytes;
//downlaod file url
@property (nonatomic,strong) NSURL*url;
//session task used to perfon the download process
@property (nonatomic,strong) NSURLSessionDataTask*task;
- (void)start;
- (void)completeOperation;

@end

@implementation L3SDKConcurrentDownloader
//intherited properties
@synthesize finished;
@synthesize executing;
@synthesize concurrent;
@synthesize cancelled;
//local propery
@synthesize delegate;


-(instancetype)initWithURLString:(NSString*)url{
    //init class with the url file
    self=[super init];
    if (self) {
        self.url=[NSURL URLWithString:url];
        concurrent=YES;
        
    }
    return self;
    
}
- (void)start {
    // Always check for cancellation before launching the task.
    if ([self isCancelled]){
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
}
-(void) main{
    
    @try {
        //configure and start a task
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
        NSURLSessionConfiguration *sessionConfig =[NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session=[NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        self.task = [session dataTaskWithRequest:request];
        [self.task resume];
        
        [self completeOperation];
        
    }
    @catch (NSException *exception) {
        if (self.delegate!=NULL && [self.delegate respondsToSelector:@selector(L3SDKConcurrentDownloader_Error:)]) {
            [self.delegate L3SDKConcurrentDownloader_Error:exception];
        }
    }
    
}
- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    
    //raised when download will be completed
    if (error) {
        if (self.delegate!=NULL && [self.delegate respondsToSelector:@selector(L3SDKConcurrentDownloader_Error:)]) {
            [self.delegate L3SDKConcurrentDownloader_Error:[NSException exceptionWithName:[error localizedDescription] reason:nil userInfo:[error userInfo]]];
            return;
        }
    }

    if (self.delegate!=NULL && [self.delegate respondsToSelector:@selector(L3SDKConcurrentDownloader_Completed:forSender:isCancelled:)]) {
        [self.delegate L3SDKConcurrentDownloader_Completed:self.fileData forSender:self isCancelled:self.cancelled];
    }
    
    
}
-(void)cancel {
    [self.task cancel];
    [self willChangeValueForKey:@"isCancelled"];
    cancelled = YES;
    [self didChangeValueForKey:@"isCancelled"];
}
-(void)suspend{
    [self.task suspend];
}
-(void)resume {
    [self.task resume];
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    //raised during the dwownload process
    if ([self isCancelled]) {
        return;
    }
    
    [self.fileData appendData:data];
    self.receivedBytes += data.length;
    
    if (self.totalBytes>0) {
        if (self.delegate!=NULL && [self.delegate respondsToSelector:@selector(L3SDKConcurrentDownloader_Downloading:ofTotalBytes:forSender:)]) {
            [self.delegate L3SDKConcurrentDownloader_Downloading:self.receivedBytes ofTotalBytes:self.totalBytes forSender:self];
        }
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    
    //raised when a connection was established
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSDictionary *dict = httpResponse.allHeaderFields;
    NSString *lengthString = [dict valueForKey:@"Content-Length"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *length = [formatter numberFromString:lengthString];
    self.totalBytes = length.unsignedIntegerValue;
    self.fileData = [[NSMutableData alloc] initWithCapacity:self.totalBytes];
    
    completionHandler(NSURLSessionResponseAllow);
    
}


@end
