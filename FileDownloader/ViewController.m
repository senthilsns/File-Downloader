//
//  ViewController.m
//  FileDownloader
//
//  Created by appledeveloper on 25/03/19.
//  Copyright © 2019 Senthilkumar K. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLSessionDelegate,NSFileManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    // Approach 1
    [self readAndDownloadFileFromURL:@"< Paste Your URL >" format:@"<Extension>"];  // Ex: "www.google.com"   ".txt"
    
    // Approach 2
    [self downloadFiles:@"< Paste Your URL >"]; // Ex: "www.google.com"
   
 
}

#pragma mark - Approach 1
-(void) readAndDownloadFileFromURL:(NSString*)txtURL format:(NSString*)format {
    
    
        NSLog(@"1. Download File to Cache Directory");
        
        dispatch_group_t group = dispatch_group_create();
        
        NSLog(@"1. Download File From URL ");
        // URL Session Download Task
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        if (@available(tvOS 11.0, *)) {
            configuration.waitsForConnectivity = true;
        } else {
            // Fallback on earlier versions
        }
        
        NSURLSession *session=[NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue currentQueue]];
        
        NSString*documentsPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager setDelegate:self];
        
        
        dispatch_group_enter(group);
        NSURL *url = [NSURL URLWithString:txtURL];// Provide URL Here
        NSURLSessionTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            
            if (error != nil){
                // Error
                NSLog(@"File Download Error = %@",error.description);
            }
            
            NSString * filename = [[txtURL lastPathComponent] stringByDeletingPathExtension];
            NSString * finalName = [NSString stringWithFormat:@"/Home/%@.%@",filename,format];
            NSString * finalPath = [documentsPath stringByAppendingPathComponent:finalName];// Provide  File here
            
            BOOL success;
            @try {
                NSError *fileManagerError;
                if ([fileManager fileExistsAtPath:finalPath]) {
                    
                    //  success = [fileManager removeItemAtPath:finalPath error:&fileManagerError];
                    // NSAssert(success, @"removeItemAtPath error: %@", fileManagerError); // Remove Item at Path
                    
                }else {
                    success = [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:finalPath] error:&fileManagerError];
                    NSAssert(success, @"moveItemAtURL error: %@", fileManagerError); // Remove Item at URL
                }
                
            } @catch (NSException *exception) {
                
                NSLog(@"Download Error = %@",exception);
                
                
            } @finally {
                
                if ( success == NO) {
              
                    // Show Download Error
                    
                }else {
                    NSLog(@"File Download Complete!!!");
                }
                NSLog(@"File Downloader!!!");
            }
            
            dispatch_group_leave(group);
            
        }];
    
        
        [downloadTask resume];
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    
}


#pragma mark - Approach 2
-(void) downloadFiles:(NSString *)Url  {
    
    //download the file in a seperate thread.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"Downloading Started...");
        NSString *urlToDownload = Url;;
        NSURL  *url = [NSURL URLWithString:urlToDownload];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData )
        {
            NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString  *documentsDirectory = [paths objectAtIndex:0];
            
            
            NSString *fileName = [Url lastPathComponent];
            NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,fileName];
            NSLog(@"File path = %@",filePath);
            //saving is done on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [urlData writeToFile:filePath atomically:YES];
                NSLog(@"**File Saved !!");
            });
        }
        
    });
}




@end
