//
//  ViewController.swift
//  Swift-Concurrent-Downloader
//
//  Created by Domenico Vacchiano on 05/11/15.
//  Copyright © 2015 DomenicoVacchiano. All rights reserved.
//

import UIKit

class ViewController: UIViewController,L3SDKConcurrentDownloaderDelegate {

    //MARK: Local declarations
    
    //IBOutlet
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    
    @IBOutlet weak var labelProgress1: UILabel!
    @IBOutlet weak var labelProgress2: UILabel!
    @IBOutlet weak var labelProgress3: UILabel!
    
    @IBOutlet weak var progressBar1: UIProgressView!
    @IBOutlet weak var progressBar2: UIProgressView!
    @IBOutlet weak var progressBar3: UIProgressView!
    
    let kTagButtonCancel_1 = 1
    let kTagButtonSuspend_1 = 2
    let kTagButtonResumel_1 = 3
    
    let kTagButtonCancel_2 = 4
    let kTagButtonSuspend_2 = 5
    let kTagButtonResumel_2 = 6
    
    let kTagButtonCancel_3 = 7
    let kTagButtonSuspend_3 = 8
    let kTagButtonResumel_3 = 9
    
    // L3SDKConcurrentDownloader instances
    private var image1=L3SDKConcurrentDownloader()
    private var image2=L3SDKConcurrentDownloader()
    private var zipFile=L3SDKConcurrentDownloader()
    
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:IBAction
    @IBAction func downloadImageAsynch(sender:AnyObject){
        
        self.imageView1.image=nil
        self.imageView2.image=nil
        self.labelProgress1.text=""
        self.labelProgress1.text=""
        self.labelProgress3.text=""
        self.progressBar1.progress=0
        self.progressBar2.progress=0
        self.progressBar3.progress=0
        
        //init L3SDKConcurrentDownloader instances with an url
        self.image1=L3SDKConcurrentDownloader(url: "http://imgsrc.hubblesite.org/hu/db/2003/24/images/a/formats/full_jpg.jpg")
        self.image2=L3SDKConcurrentDownloader(url: "http://www.angelfire.com/rnb/weatherpics/telaviv_high_res.jpg")
        self.zipFile=L3SDKConcurrentDownloader(url: "http://download.thinkbroadband.com/50MB.zip")
        
        self.image1.delegate=self
        self.image2.delegate=self
        self.zipFile.delegate=self
        
        //creates an NSOperationQueue with and array of NSOperation
        let operationQueue=NSOperationQueue()
        operationQueue.addOperations([self.image1,self.image2,self.zipFile], waitUntilFinished: false)
        
    }
    @IBAction func doAction(sender:AnyObject){
        
        //do some action:
        // - cancel
        // - suspend
        // - resume
        
        let button=sender as! UIButton
        
        switch (button.tag){
            case kTagButtonCancel_1:
                self.image1.cancel()
                break
            case kTagButtonSuspend_1:
                self.image1.suspend()
                break
            case kTagButtonResumel_1:
                self.image1.resume()
                break
            case kTagButtonCancel_2:
                self.image2.cancel()
                break
            case kTagButtonSuspend_2:
                self.image2.suspend()
                break
            case kTagButtonResumel_2:
                self.image2.resume()
                break
            case kTagButtonCancel_3:
                self.zipFile.cancel()
                break
            case kTagButtonSuspend_3:
                self.zipFile.suspend()
                break
            case kTagButtonResumel_3:
                self.zipFile.resume()
                break
        default:
            break
            
        }
    }
    //MARK:ConcurrentDownloaderDelegate Protocol
    func L3SDKConcurrentDownloader_Completed (data:NSData?, forSender sender:AnyObject){

         //downloaded completed we can show the downloaded data
        
        dispatch_async(dispatch_get_main_queue(),
            {()  in
                if self.image1.isEqual(sender) {
                    self.imageView1.image=UIImage(data: data!)
                    
                }else if self.image2.isEqual(sender) {
                    self.imageView2.image=UIImage(data: data!)
                }
                else if self.zipFile.isEqual(sender) {
                    
                    //uncomment this code if you want to save the file locally
                    /*
                    if let _=data {
                        var paths=NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                        let documentsDirectory=paths[0]
                        
                        let filePath=String(format: "%@/%@", documentsDirectory,"50MB.zip")
                        print(filePath)
                        data?.writeToFile(filePath, atomically: true)
                    }
                    */
                    self.labelProgress3.text="file download completed"
                }
            }
        )

        
    }
    func L3SDKConcurrentDownloader_Downloading (receivedBytes:Int, ofTotalBytes totalBytes:Int, forSender sender:AnyObject){
    
        //download in progress
        
        let progress=(Float(receivedBytes)/Float(totalBytes))
        let label="\(receivedBytes) bytes of \(totalBytes)"
        
        dispatch_async(dispatch_get_main_queue(),
            {()  in
                if self.image1.isEqual(sender) {
                    self.labelProgress1.text=label
                    self.progressBar1.progress=progress
                }else if self.image2.isEqual(sender) {
                    self.labelProgress2.text=label
                    self.progressBar2.progress=progress
                }else if self.zipFile.isEqual(sender) {
                    self.labelProgress3.text=label
                    self.progressBar3.progress=progress
                }

            }
        )
    }
    
    func L3SDKConcurrentDownloader_Error (exception:NSException){
        print(exception.description)
    }
    


}

