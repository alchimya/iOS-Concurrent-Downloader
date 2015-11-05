//
//  ConcurrentDownloader.swift
//  Swift-Concurrent-Downloader
//
//  Created by Domenico Vacchiano on 05/11/15.
//  Copyright © 2015 DomenicoVacchiano. All rights reserved.
//

import UIKit




class L3SDKConcurrentDownloader: NSOperation,NSURLSessionTaskDelegate,NSURLSessionDataDelegate {

    //downloaded data
    lazy private var fileData:NSMutableData=NSMutableData()
    //total bytes received
    private var totalBytes:Int=0
    //current bytes received
    private var receivedBytes:Int=0
    //downlaod file url
    lazy private var url:NSURL=NSURL()
    //session task used to perfon the download process
    lazy private var task:NSURLSessionDataTask=NSURLSessionDataTask()
    
    //gets/sets the delegate to respond to the ConcurrentDownloaderDelegate protocol
    var delegate:L3SDKConcurrentDownloaderDelegate?
   
    private var _finished:Bool=false
    private var _executing:Bool=false
       
    override var concurrent: Bool {
        return true
    }
    override var finished:Bool {
        return _finished
    }
    override var executing:Bool {
        return _executing
    }

    override init() {}
    //custom factory initialization with the url of the download file
    init(url:String) {
        super.init()
        self.url=NSURL(string: url)!
    }
    //allows to suspend the download
    func suspend(){
        self.task.suspend()
    }
    //allows to resume the downlaod
    func resume() {
        self.task.resume()
    }
    //allows ro calncel the operation
    override func cancel() {
        self.task.cancel()
    }
    
    override func start() {
        
         // Always check for cancellation before launching the task.
        if self.cancelled{
            // Must move the operation to the finished state if it is canceled.
            self.willChangeValueForKey("finished")
            _finished=true
            self.willChangeValueForKey("finished")
            return
        }
        // If the operation is not canceled, begin executing the task.
        self.willChangeValueForKey("executing")
        NSThread.detachNewThreadSelector(Selector("main"), toTarget: self, withObject: nil)
        _executing=true
        self.willChangeValueForKey("executing")
    }
    
    override func main() {
        
        //configure and start a task
        let request=NSURLRequest(URL: self.url)
        let sessionConfig=NSURLSessionConfiguration.defaultSessionConfiguration()
        let session=NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        self.task=session.dataTaskWithRequest(request)
        self.task.resume()
        self.completeOperation()
        
    }
    
    private func completeOperation(){
        self.willChangeValueForKey("executing")
        self.willChangeValueForKey("finished")
        _executing=false
        _finished=true
        self.willChangeValueForKey("executing")
        self.willChangeValueForKey("finished")
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        //raised when download will be completed
        if (error != nil) {
            self.delegate?.L3SDKConcurrentDownloader_Error!(NSException(name: (error?.localizedDescription)!, reason: nil, userInfo: error?.userInfo))
            return
        }
        
        self.delegate?.L3SDKConcurrentDownloader_Completed(self.fileData, forSender: self)
    
        
    }
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        //raised during the dwownload process
        if self.cancelled{
            return
        }
        
        self.fileData.appendData(data)
        self.receivedBytes += data.length;
        
        if self.totalBytes>0 {
            self.delegate?.L3SDKConcurrentDownloader_Downloading(self.receivedBytes, ofTotalBytes: self.totalBytes, forSender: self)
        }
        
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        //raised when a connection was established
        let httpResponse = response as! NSHTTPURLResponse
        let dict=httpResponse.allHeaderFields
        let lengthString=dict["Content-Length"] as! String
        let formatter=NSNumberFormatter()
        let length=formatter.numberFromString(lengthString)
        self.totalBytes=(length?.integerValue)!
        self.fileData=NSMutableData(capacity: self.totalBytes)!

        completionHandler(NSURLSessionResponseDisposition.Allow)
        
    }
    
}
