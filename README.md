# iOS-Concurrent-Downloader
An NSOperation subclass that implements (ObjC and Swift) a concurrent file downloader.


#What is this?

It implements, as an NSOperation subclass, a concurrent file downloader.
<br/>
As NSOperation subclass you can use it through an instance of a NSOperationQueue by adding N instances of L3SDKConcurrentDownloader class.
<br/>
Whitin this project you will find both implementation for objc and swift.
<br/>
For further information about Concurrent Programming and Operation Queues referr to the Apple documentation here:
<br/>
https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html

<br/>
![ScreenShot](https://raw.github.com/alchimya/iOS-Concurrent-Downloader/master/screenshots/iOS-Concurrent-Downloader.gif)

#How to use

<b>1)</b> define one or more instances of L3SDKConcurrentDownloader and init them with the url (initWithURLString and init(_url) for swift).
<br/>
<b>2)</b> define an instance of NSOperationQueue ad add your L3SDKConcurrentDownloader instances (addOperations method).
<br/>
<b>3)</b> to receive the L3SDKConcurrentDownloader callbacks implement into your code the L3SDKConcurrentDownloaderDelegate and set your class delegate
<br/>
Here as example a code snippet

```objectivec
@property (nonatomic,strong)L3SDKConcurrentDownloader*image1;
@property (nonatomic,strong)L3SDKConcurrentDownloader*image2;
@property (nonatomic,strong)L3SDKConcurrentDownloader*zipFile;
....
....
....
//init L3SDKConcurrentDownloader instances with an url
self.image1=[[L3SDKConcurrentDownloader alloc]initWithURLString:@"http://my_url_1"];
self.image2=[[L3SDKConcurrentDownloader alloc]initWithURLString:@"http://my_url_2"];
self.zipFile=[[L3SDKConcurrentDownloader alloc]initWithURLString:@"http://my_url_3"];

//creates an NSOperationQueue with an array of NSOperation
NSOperationQueue*operationQueue=[[NSOperationQueue alloc]init];
[operationQueue addOperations:@[self.image1,self.image2,self.zipFile] waitUntilFinished:NO];
....
....
....
-(void) L3SDKConcurrentDownloader_Completed:(NSData*)data forSender:(id)sender isCancelled:(BOOL)isCancelled{
	//put here your code
}

-(void)  L3SDKConcurrentDownloader_Downloading:(NSUInteger)receivedBytes ofTotalBytes:(NSUInteger)totalBytes forSender:(id)sender{
	//put here your code
}

-(void) L3SDKConcurrentDownloader_Error:(NSException*)exception{
	//put here your code
}

```

<h5>properties</h5>

  name                        |     type                                |   description    
------------------------------| ----------------------------------------|--------------------------------------------------------
delegate                      | id<L3SDKConcurrentDownloaderDelegate>   | gets/sets the class delegate


<h5>methods</h5>
  name                    |     type        |   description    
--------------------------| ----------------|-------------------------------------------------------------------
initWithURLString         | instancetype    | allows to init the class with the url of the download file
suspend        			  | void            | allows to suspend the download
resume                    | void            | allows to resume the downlaod
cancel                    | void            | inherited method, allows to cancel the downlaod


<h5>protocols</h5>

```objectivec
@protocol L3SDKConcurrentDownloaderDelegate<NSObject>
//raised when the download is completed
-(void) L3SDKConcurrentDownloader_Completed:(NSData*)data forSender:(id)sender isCancelled:(BOOL)isCancelled;
//raised during the downaload process
-(void) CL3SDKoncurrentDownloader_Downloading:(NSUInteger)receivedBytes ofTotalBytes:(NSUInteger)totalBytes forSender:(id)sender;
@optional
//raised if occur an error
-(void) L3SDKConcurrentDownloader_Error:(NSException*)exception;
@end
```
