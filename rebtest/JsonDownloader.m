//
//  JsonDownloader.m
//  RPM
//
//  Created by Steven Xu on 4/02/2015.
//  Copyright (c) 2015 Sterling Publishing. All rights reserved.
//

#import "JsonDownloader.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "Reachability.h"
#import "Article.h"
#import "ArticleCategory.h"





@implementation JsonDownloader


@synthesize delegate;

-(id)init {
    
    self = [super init];
    
    return self;
    
}

-(id)initWithList:(NSMutableArray *) inList
{
    
    self = [self init];
    list = inList;
    return self;
    
}


#pragma mark -
#pragma mark  load article list

-(void)loadArticleList:(NSMutableArray* )categoryList
{
    [list removeAllObjects];

    self.categoryList = categoryList;
    
    [self loadNextCategory];
    
    
    
}
-(void)loadNextCategory
{
    if (self.categoryList.count>0) {
        NSString *catId = [((NSDictionary *)[self.categoryList objectAtIndex:0]) objectForKey:@"id"];
        NSString *catName = [((NSDictionary *)[self.categoryList objectAtIndex:0]) objectForKey:@"name"];
        [self loadArticleList:catId CatName:catName];
        
        [self.categoryList removeObjectAtIndex:0];
    }else
    {
        //send message to delegate
        [delegate onDownloadFinished:list];
    }
}

-(void)loadArticleList:(NSString*) catid CatName:(NSString*) catName
{
    NSString* loadUrl = [NSString stringWithFormat:@"%@%@%@",GET_ARTICLE_URL_PREFIX,catid,@"&limit=8"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:loadUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"JSON: %@", responseObject);
        [self parseItems:responseObject Catid:catid CatName:catName];
        [self saveJsonFile:[operation responseString] CatName:catName];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
      
       
        [self parseItems:[self loadJsonFile:catName] Catid:catid CatName:catName];
    }];
    
    
    
    
}

-(void) saveJsonFile:(NSString*) json CatName:(NSString*) catName
{
    [[NSUserDefaults standardUserDefaults] setValue:json forKey:catName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(id) loadJsonFile:(NSString*) catName
{
    NSString *dataString= [[NSUserDefaults standardUserDefaults]
                           objectForKey:catName];
    
    NSError *jsonError;
    NSData *objectData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    
    return json;
}

- (id) loadLocalCategoryFile:(NSString*) catid CatName:(NSString*) catName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",catName]];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"loadLocalCategoryFile: %@ Error: %@", path,error);
    return json;
}




- (void) downloadCategoryFile:(NSString*) catid CatName:(NSString*) catName
{
    
    NSString* loadUrl = [NSString stringWithFormat:@"%@%@%@",GET_ARTICLE_URL_PREFIX,catid,@"&limit=8"];
//
//    
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",catName]];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    AFHTTPRequestOperation *op = [manager GET:loadUrl
//                                   parameters:nil
//                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                          NSLog(@"=======================================================successful download to %@", path);
//                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                          NSLog(@"Error: %@", error);
//                                      }];
//    op.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
//    [op start];
    
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:loadUrl]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",catName]];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Successfully downloaded file to %@", path);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    
        [operation start];
    
    
    
    //    NSURL *url = [NSURL URLWithString:loadUrl];
    //    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    //
    //    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //
    //    NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[url lastPathComponent]];
    //
    //    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fullPath append:NO]];
    //
    //    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
    //        NSLog(@"bytesRead: %lu, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", (unsigned long)bytesRead, totalBytesRead, totalBytesExpectedToRead);
    //    }];
    //
    //    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    //
    //        NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
    //
    //        NSError *error;
    //        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
    //
    //        if (error) {
    //            NSLog(@"ERR: %@", [error description]);
    //        } else {
    //            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    //            long long fileSize = [fileSizeNumber longLongValue];
    //            NSLog(@"OK");
    //
    //        }
    //
    //
    //    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //        NSLog(@"ERR: %@", [error description]);
    //    }];
}

-(void)parseItems:(id)json Catid:(NSString*) catid CatName:(NSString*) catName
{
    
    
    NSMutableArray* articleList = [[NSMutableArray alloc] init];
    
    
    
    
    
    NSDictionary *jsonDict = (NSDictionary *) json;
    NSArray *array = [jsonDict objectForKey:@"data"];
    [array enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
        NSArray *innerarray = obj;
        [innerarray enumerateObjectsUsingBlock:^(id innerobj,NSUInteger idx, BOOL *stop){
            
            NSString *url = [innerobj objectForKey:@"link"];
            NSString *title = [innerobj objectForKey:@"title"];
            NSString *image = [innerobj objectForKey:@"images"];
            NSString *author = [innerobj objectForKey:@"cat_name"];
            NSString *introtext = [innerobj objectForKey:@"introtext"];
            NSString *time = [innerobj objectForKey:@"publish_up"];
            NSString *articleId = [innerobj objectForKey:@"id"];
            
            
            //            NSLog(@"Loading queue title = %@, url = %@",title,url);
            

            
            Article* article = [Article alloc];
            
            article.link = [NSString stringWithFormat:@"%@/%@",BASE_URL,url];
            article.title = title;
            article.image = [NSString stringWithFormat:@"%@/%@",BASE_URL,image];
            article.author =  author;
            article.introtext = introtext;
            article.time = time;
            article.articleId = articleId;
            
            NSLog(@"article.articleId = %@",articleId);
            
            [articleList addObject:article];
            
            
            //TODO: implement preloading
            
        }];
        
        
        
    }];
    
    ArticleCategory *aCategory = [ArticleCategory alloc];
    aCategory.catName = catName;
    aCategory.catId = catid;
    aCategory.articleList = articleList;
    
    
    [list addObject:aCategory];
    
//    NSLog(@"Llist addObject: %@, id = %@",catName,catid);
    
    //     NSLog(@"[[[GlobalData getInstance] categoryList] count] %lu",(unsigned long)[[[GlobalData getInstance] categoryList] count]);
    
//    NSLog(@"[list count]: %lu",(unsigned long)[list count]);
    
    [self loadNextCategory];

    
    
}


@end
