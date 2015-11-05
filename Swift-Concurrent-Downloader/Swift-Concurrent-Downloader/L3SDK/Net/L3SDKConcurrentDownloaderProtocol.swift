//
//  ConcurrentDownloaderProtocol.swift
//  Swift-Concurrent-Downloader
//
//  Created by Domenico Vacchiano on 05/11/15.
//  Copyright © 2015 DomenicoVacchiano. All rights reserved.
//

import Foundation

//protocol to describe the download events
@objc protocol L3SDKConcurrentDownloaderDelegate {
    //raised when the download is completed
    func L3SDKConcurrentDownloader_Completed (data:NSData?, forSender sender:AnyObject)
    //raised during the downaload process
    func L3SDKConcurrentDownloader_Downloading (receivedBytes:Int, ofTotalBytes totalBytes:Int, forSender sender:AnyObject)
    //raised if occur an error
    optional func L3SDKConcurrentDownloader_Error (exception:NSException)
}

