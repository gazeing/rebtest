//
//  PreCachingWebView.m
//  HybridWebView
//
//  Created by Steven Xu on 15/08/2014.
//  Copyright (c) 2014 Sterling Publishing. All rights reserved.
//

#import "Constants.h"
#import "PreCachingWebView.h"
#import "AFNetworking.h"
#import "Reachability.h"

@implementation PreCachingWebView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//constractor without frame

- (id)init
{
    self = [super init];
    self.delegate = self;
    if (self) {
        m_LoadingQueue = [[NSMutableArray alloc] init];
        jsonUrl = PRELOADING_JSON_URL;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) AddToQueue:(NSString *)urlString
{
    
    [m_LoadingQueue addObject:urlString];
}

- (NSString *) GetFromQueue
{
    if (m_LoadingQueue.count >0) {
        NSString* temp = [m_LoadingQueue objectAtIndex:0];
        [m_LoadingQueue removeObjectAtIndex:0];
        return temp;
    }
    return nil;
}

- (void)startPreloading{
    if (m_LoadingQueue!=NULL) {
        [self BuildCachePageQueue];
    }
}


- (void) BuildCachePageQueue
{
    //json url: http://www.rebonline.com.au/steven/json/LoadingQueue.json
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:jsonUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"JSON: %@", responseObject);
        [self parseItems:responseObject];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

-(void)parseItems:(id)json
{
    
//    NSDictionary *jsonDict = (NSDictionary *) json;
//    NSArray *array = [jsonDict objectForKey:@"queue"];
//    [array enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
//        NSString *title = [obj objectForKey:@"title"];
//        NSString *url = [obj objectForKey:@"url"];
//        
////        NSLog(@"Loading queue title = %@, url = %@",title,url);
//        
//        [self AddToQueue:url];
//        
//    }];
    
    NSDictionary *jsonDict = (NSDictionary *) json;
    NSArray *array = [jsonDict objectForKey:@"data"];
    [array enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
        NSArray *innerarray = obj;
        [innerarray enumerateObjectsUsingBlock:^(id innerobj,NSUInteger idx, BOOL *stop){
//            NSString *title = [innerobj objectForKey:@"title"];
            NSString *url = [innerobj objectForKey:@"link"];
            
            //            NSLog(@"Loading queue title = %@, url = %@",title,url);
            
            [self AddToQueue:[NSString stringWithFormat:@"%@/%@",BASE_URL,url]];
            
        }];
        
        
        
    }];
    
    [self LoadNextCachePage];
    
}



- (NSURL *)GetNextCachePageUrl
{
    
    if (m_LoadingQueue.count >0) {
        return [NSURL URLWithString:[self GetFromQueue]];
    }
    return nil;


}

- (void) LoadNextCachePage
{
    if ([self isNetworkConnected]) {
        
        if (m_LoadingQueue.count >0) {
            
            [self loadRequest:[NSURLRequest requestWithURL:[self GetNextCachePageUrl]]];
        }
    }
    
}


- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    NSString *loadingUrl = theWebView.request.URL.absoluteString;
    
    
    if (![loadingUrl isEqualToString:m_currentLoadUrl]) {
        m_currentLoadUrl = loadingUrl.copy;
//        NSLog(@"successfully caching url: %@",loadingUrl);
        [self performSelector:@selector(LoadNextCachePage) withObject:self afterDelay:2.0 ];
    }
    
    
//    [self LoadNextCachePage];
}


- (void)webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
{
//    NSString *loadingUrl = theWebView.request.URL.absoluteString;
//     NSLog(@"fail on caching url: %@ \n error:%@",loadingUrl,error.description);
//     [self LoadNextCachePage];
}

- (Boolean) isNetworkConnected
{
    BOOL reachable = (BOOL) [[Reachability reachabilityWithHostName:[[NSURL URLWithString:jsonUrl] host]] currentReachabilityStatus] != NotReachable;
    return reachable;
}


@end
