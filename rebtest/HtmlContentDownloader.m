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
#import "Constants.h"

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
    
    
    //try to get prefix from content.html link
    NSString* prefix = BASE_URL;
    
    for (NSString* contentHtmllink in downloadList) {
        NSArray *parts = [contentHtmllink componentsSeparatedByString:@"/"];
        NSString *filename = [parts lastObject];
        NSRange replaceRange = [contentHtmllink rangeOfString:filename];
        if ([filename isEqualToString:@"content.html"]) {
            prefix =  [contentHtmllink stringByReplacingCharactersInRange:replaceRange withString:@""];
        }
    }
    
    
    
    for (NSString* link in downloadList) {
        NSURL *linkUrl = [NSURL URLWithString:link];
        NSURLRequest *request = [NSURLRequest requestWithURL:linkUrl];
        
        NSArray *parts = [link componentsSeparatedByString:@"/"];
        NSString *filename = [parts lastObject];
        
        if ([self string:link hasPrefix:prefix caseInsensitive:NO]) {
            NSRange replaceRangePrefix = [link rangeOfString:prefix];
            filename =  [link stringByReplacingCharactersInRange:replaceRangePrefix withString:@""];
        
  
        }
        

        
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
        
        
        //if path not there create path
        if ([filename containsString:@"/"]) {
            NSArray *fileparts = [filename componentsSeparatedByString:@"/"];
            NSString* realname = [fileparts lastObject];
            NSRange dirrange = [filename rangeOfString:realname];
            NSString* dir = [filename stringByReplacingCharactersInRange:dirrange withString:@""];
            NSString* fulldir = [[paths objectAtIndex:0] stringByAppendingPathComponent:dir];
            
            BOOL isDir;
            BOOL exists = [[NSFileManager defaultManager]  fileExistsAtPath:fulldir isDirectory:&isDir];
            if (exists) {
                /* file exists */
                NSLog(@"%@ is exist",fulldir);
                if (isDir) {
                    /* file is a directory */
                    NSLog(@"%@ is dir",fulldir);
                }
            }
            else{
                
                   NSLog(@"%@ needs created",fulldir);
                
                
                
                
                NSError * error = nil;
                [[NSFileManager defaultManager] createDirectoryAtPath:fulldir
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:&error];
                if (error != nil) {
                    NSLog(@"error creating directory: %@", error);
                    //..
                }
            }
            
        }
        
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        dispatch_group_enter(group);
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Successfully downloaded file to %@", path);
            dispatch_group_leave(group);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"fail to downloaded file to %@", path);
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

- (BOOL) string:(NSString *)string
      hasPrefix:(NSString *)prefix
caseInsensitive:(BOOL)caseInsensitive {
    
    if (!caseInsensitive)
        return [string hasPrefix:prefix];
    
    const NSStringCompareOptions options = NSAnchoredSearch|NSCaseInsensitiveSearch;
    NSRange prefixRange = [string rangeOfString:prefix
                                        options:options];
    return prefixRange.location == 0 && prefixRange.length > 0;
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
    
    
    Boolean isUsingAngular = NO;

    
    if (isUsingAngular) {
        NSString *absoluteURLwithQueryString = [fullFilepath stringByAppendingString: [NSString stringWithFormat:@"?id=%@",articleID]];
        
        NSURL *finalURL = [NSURL URLWithString: absoluteURLwithQueryString];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:finalURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:(NSTimeInterval)10.0 ];
        
        [webview loadRequest:request];
    }else{
        
            // get full text from api and swap it in template
        
        NSString *apiLink =[NSString stringWithFormat:@"http://test.rebonline.com.au?option=com_ajax&format=json&plugin=getcontentcategoryuser&model=content&limit=1&art_id=%@",articleID];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//        [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [manager GET:apiLink parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            NSString* fulltext = [self parseFullText:responseObject];
            

            [self loadfulltext:fulltext Webview:webview TemplatePath:fullFilepath];
            

            [self saveArticleJsonFile:fulltext ArticleID:articleID];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"load fulltext json Error: %@", error);
            
             NSString* fulltext = [self loadArticleJsonFile:articleID];
            if (fulltext != nil) {
                [self loadfulltext:fulltext Webview:webview TemplatePath:fullFilepath];
            }
            
            
                    }];

        
  
        
        
        

    }
    

}

-(void) loadfulltext:(NSString*) fulltext Webview:(UIWebView*) webview TemplatePath:(NSString* )fullFilepath
{
    NSError *err;
    
    NSString *templatehtml = [NSString stringWithContentsOfFile:fullFilepath encoding:NSUTF8StringEncoding error:&err];
    
    NSRange replaceRange = [templatehtml rangeOfString:@"{{articles[0].fulltext}}"];
    
    NSString *html =  [templatehtml stringByReplacingCharactersInRange:replaceRange withString:fulltext];
    
    
    
    // Load the html string into the web view with the base url
    //            [webview loadHTMLString:html baseURL:[NSURL URLWithString:fullFilepath]];
    [webview loadHTMLString:html baseURL:nil];
}

-(NSString*) parseFullText:(id)json
{
    
    
    NSDictionary *jsonDict = (NSDictionary *) json;
    NSArray *array = [jsonDict objectForKey:@"data"];
    
    if (array.count <1) {
    
        return @"";
    }
    NSArray *innerarray = [array lastObject];
    NSDictionary *innerobj = [innerarray lastObject];

    NSString* text  = [innerobj objectForKey:@"fulltext"];
            

    
    
    return text;
}

-(void) saveArticleJsonFile:(NSString*) json ArticleID:(NSString*) articleid
{
    [[NSUserDefaults standardUserDefaults] setValue:json forKey:articleid];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*) loadArticleJsonFile:(NSString*) articleid
{
    NSString *dataString= [[NSUserDefaults standardUserDefaults]
                           objectForKey:articleid];
    
//    NSError *jsonError;
//    NSData *objectData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
//                                                         options:NSJSONReadingMutableContainers
//                                                           error:&jsonError];
    
    return dataString;
}

@end
