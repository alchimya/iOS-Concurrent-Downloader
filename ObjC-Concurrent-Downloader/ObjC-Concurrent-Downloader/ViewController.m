//
//  ViewController.m
//  ObjC-Concurrent-Downloader
//
//  Created by Domenico Vacchiano on 05/11/15.
//  Copyright © 2015 DomenicoVacchiano. All rights reserved.
//

#import "ViewController.h"

#define kTagButtonCancel_1  1
#define kTagButtonSuspend_1  2
#define kTagButtonResumel_1  3

#define kTagButtonCancel_2  4
#define kTagButtonSuspend_2  5
#define kTagButtonResumel_2  6

#define kTagButtonCancel_3  7
#define kTagButtonSuspend_3  8
#define kTagButtonResumel_3  9

@interface ViewController ()

//IBOutlet
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@property (weak, nonatomic) IBOutlet UILabel *labelProgress1;
@property (weak, nonatomic) IBOutlet UILabel *labelProgress2;
@property (weak, nonatomic) IBOutlet UILabel *labelProgress3;

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar1;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar2;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar3;

// L3SDKConcurrentDownloader instances
@property (nonatomic,strong)L3SDKConcurrentDownloader*image1;
@property (nonatomic,strong)L3SDKConcurrentDownloader*image2;
@property (nonatomic,strong)L3SDKConcurrentDownloader*zipFile;

-(IBAction)doAction:(id)sender;

@end

@implementation ViewController

#pragma mark View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ConcurrentDownloaderDelegate Protocol
-(void) L3SDKConcurrentDownloader_Completed:(NSData*)data forSender:(id)sender isCancelled:(BOOL)isCancelled{
    
    //downloaded completed we can show the downloaded data
    
    if (isCancelled) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([sender isEqual:self.image1]) {
            self.imageView1.image=[UIImage imageWithData:data];
        }else if ([sender isEqual:self.image2]) {
            self.imageView2.image=[UIImage imageWithData:data];
        }else if ([sender isEqual:self.zipFile]) {
            //uncomment this code if you want to save the file locally
            /*
            if ( data ){
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                
                NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"50MB.zip"];
                //NSLog(@"%@",filePath);
                [data writeToFile:filePath atomically:YES];
            }
            */
            self.labelProgress3.text=@"file download completed";
        }
    });
    
}
-(void)  L3SDKConcurrentDownloader_Downloading:(NSUInteger)receivedBytes ofTotalBytes:(NSUInteger)totalBytes forSender:(id)sender{
    
    //download in progress
    NSString*label=[NSString stringWithFormat:@"%lu bytes of %lu",receivedBytes,totalBytes];
    CGFloat progress=(CGFloat)receivedBytes/(CGFloat)totalBytes;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([sender isEqual:self.image1]) {
            self.labelProgress1.text=label;
            self.progressBar1.progress=progress;
        }else if ([sender isEqual:self.image2]) {
            self.labelProgress2.text=label;
            self.progressBar2.progress=progress;
        }else if ([sender isEqual:self.zipFile]) {
            self.labelProgress3.text=label;
            self.progressBar3.progress=progress;
        }
    });
}
#pragma mark IBAction
-(IBAction)doAction:(id)sender{
    
    //do some action:
    // - cancel
    // - suspend
    // - resume
    
    UIButton*button=(UIButton*)sender;
    
    switch (button.tag) {
        case kTagButtonCancel_1:
            [self.image1 cancel];
            break;
        case kTagButtonResumel_1:
            [self.image1 resume];
            break;
        case kTagButtonSuspend_1:
            [self.image1 suspend];
            break;
        case kTagButtonCancel_2:
            [self.image2 cancel];
            break;
        case kTagButtonResumel_2:
            [self.image2 resume];
            break;
        case kTagButtonSuspend_2:
            [self.image2 suspend];
            break;
        case kTagButtonCancel_3:
            [self.zipFile cancel];
            break;
        case kTagButtonResumel_3:
            [self.zipFile resume];
            break;
        case kTagButtonSuspend_3:
            [self.zipFile suspend];
            break;
        default:
            break;
    }
    
}

-(IBAction)downloadImageAsynch:(id)sender{
    
    //init L3SDKConcurrentDownloader instances with an url
    self.image1=[[L3SDKConcurrentDownloader alloc]initWithURLString:@"http://imgsrc.hubblesite.org/hu/db/2003/24/images/a/formats/full_jpg.jpg"];
    self.image2=[[L3SDKConcurrentDownloader alloc]initWithURLString:@"http://www.angelfire.com/rnb/weatherpics/telaviv_high_res.jpg"];
    self.zipFile=[[L3SDKConcurrentDownloader alloc]initWithURLString:@"http://download.thinkbroadband.com/50MB.zip"];
    self.image1.delegate=self;
    self.image2.delegate=self;
    self.zipFile.delegate=self;
    
    //creates an NSOperationQueue with an array of NSOperation
    NSOperationQueue*operationQueue=[[NSOperationQueue alloc]init];
    [operationQueue addOperations:@[self.image1,self.image2,self.zipFile] waitUntilFinished:NO];
    
}




@end
