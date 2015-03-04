//
//  HtmlContentDownloader.m
//  RPM
//
//  Created by Steven Xu on 16/02/2015.
//  Copyright (c) 2015 Sterling Publishing. All rights reserved.
//

#import "HtmlContentDownloader.h"
#import "AFNetworking.h"
#import "Reachability.h"

@implementation HtmlContentDownloader


@synthesize delegate;

-(id)init {
    
    self = [super init];
    
    downloadList = [[NSMutableArray alloc] initWithCapacity:15];
    
    return self;
    
}

-(id)initWithLoadUrl:(NSString *) loadListJsonUrl
{
    
    self = [self init];
    loadUrl = loadListJsonUrl;
    return self;
    
}


- (void) startDownload
{
    NSString* downloadUrl = @"http://www.rebonline.com.au/steven/json/downloadlist.json";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [manager GET:downloadUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"JSON: %@", responseObject);
        [self parseItems:responseObject];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        
        [self parseItems:[self loadJsonFile] ];
    }];
}

-(id)loadJsonFile{
    
    


    return nil;
}


    
    
-(void)parseItems:(id)json
{
    NSDictionary *jsonDict = (NSDictionary *) json;
    NSInteger version = [[jsonDict objectForKey:@"version"] intValue];
    

    
    NSArray *array = [jsonDict objectForKey:@"links"];
    if ((array!=nil)&&( array.count > 0)) {
        [downloadList removeAllObjects];
    
        [array enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
        
//            NSDictionary *item = (NSDictionary *) obj;
//            NSString* link = [item objectForKey:@"link"];
            NSString* link = ( NSString* )obj;
            if (link.length >0) {
                
                [downloadList addObject:link];
            }
            
        
        }];
    }
    
    NSInteger previous_version = [[[NSUserDefaults standardUserDefaults]
                                  objectForKey:@"download_list_version"] intValue];
    
    if(version > previous_version){
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",version] forKey:@"download_list_version"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
        [self downloadAllHTMLFiles];
    }
    else
    {
        [delegate onNoNeedToUpdate:self];
    }
}

- (void) downloadAllHTMLFiles
{
    
    dispatch_group_t  group = dispatch_group_create();
    
    
    
    for (NSString* link in downloadList) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
        
        NSArray *parts = [link componentsSeparatedByString:@"/"];
        NSString *filename = [parts lastObject];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        dispatch_group_enter(group);
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Successfully downloaded file to %@", path);
            dispatch_group_leave(group);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            dispatch_group_leave(group);
        }];
        
        [operation start];
    }
    
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"Horray everything has completed");
        
        NSLog(@"Done");
        
        [delegate onDownloadFinished:self];
        
    });
}


- (void) loadLocalHtml:(UIWebView *)webview HtmlPath:(NSString* )htmlpath ArticleID:(NSString*)articleID
{
    // Get the app Documents path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSLog(@"basePath =  %@",basePath);
    // Add index.html to the basepath
    NSString *fullFilepath = [basePath stringByAppendingPathComponent:htmlpath];
    
    NSLog(@"fullFilepath =  %@",fullFilepath);
    
//    // Load the file, assuming it exists
//    NSError *err;
//    NSString *html = [NSString stringWithContentsOfFile:fullFilepath encoding:NSUTF8StringEncoding error:&err];
//    
//    // Load the html string into the web view with the base url
//    [webview loadHTMLString:html baseURL:[NSURL URLWithString:fullFilepath]];
    
    NSString *absoluteURLwithQueryString = [fullFilepath stringByAppendingString: [NSString stringWithFormat:@"?id=%@",articleID]];
    
    NSURL *finalURL = [NSURL URLWithString: absoluteURLwithQueryString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:finalURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:(NSTimeInterval)10.0 ];
    
    [webview loadRequest:request];
}

@end
