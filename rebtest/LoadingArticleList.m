//
//  LoadingAricleList.m
//  RPM
//
//  Created by Steven Xu on 28/01/2015.
//  Copyright (c) 2015 Sterling Publishing. All rights reserved.
//

#import "LoadingArticleList.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "Reachability.h"
#import "Article.h"
#import "ArticleCategory.h"



@implementation LoadingArticleList
{
   
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        jsonUrl = PRELOADING_JSON_URL;
        
        list = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).list;
        
        
    }
    return self;

}

-(NSArray*)getCategoryIdArray
{
    return @[@26,@25,@8,@13];
}

-(void)loadArticleList
{
    [list removeAllObjects];
    [self loadArticleList:@"26" CatName:@"News"];
    [self loadArticleList:@"25" CatName:@"Features"];
    [self loadArticleList:@"8" CatName:@"Blogs"];
    [self loadArticleList:@"13" CatName:@"Videos"];

}

-(void)loadArticleList:(NSString*) catid CatName:(NSString*) catName
{
    NSString* loadUrl = [NSString stringWithFormat:@"%@%@",GET_ARTICLE_URL_PREFIX,catid];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:loadUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"JSON: %@", responseObject);
        [self parseItems:responseObject Catid:catid CatName:catName];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}


-(void)parseItems:(id)json Catid:(NSString*) catid CatName:(NSString*) catName
{
    

    NSMutableArray* articleList = [[NSMutableArray alloc] init];
    
    
    
    
    
    NSDictionary *jsonDict = (NSDictionary *) json;
    NSArray *array = [jsonDict objectForKey:@"data"];
    [array enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
        NSArray *innerarray = obj;
        [innerarray enumerateObjectsUsingBlock:^(id innerobj,NSUInteger idx, BOOL *stop){
            //            NSString *title = [innerobj objectForKey:@"title"];
            NSString *url = [innerobj objectForKey:@"link"];
            NSString *title = [innerobj objectForKey:@"title"];
            NSString *image = [innerobj objectForKey:@"images"];
            NSString *author = [innerobj objectForKey:@"cat_name"];
            NSString *introtext = [innerobj objectForKey:@"introtext"];
            NSString *time = [innerobj objectForKey:@"publish_up"];
            NSString *articleId = [innerobj objectForKey:@"id"];
            
            
            //            NSLog(@"Loading queue title = %@, url = %@",title,url);
            
//            [self AddToQueue:[NSString stringWithFormat:@"%@/%@",BASE_URL,url] Title:title Image:image Author:author Introtext:introtext Time:time ArticleId:articleId];
            
            Article* article = [Article alloc];
            
            article.link = url;
            article.title = title;
            article.image = image;
            article.author =  author;
            article.introtext = introtext;
            article.time = time;
            article.articleId = articleId;
            
            [articleList addObject:article];
        }];
        
        
        
    }];
    
    ArticleCategory *aCategory = [ArticleCategory alloc];
    aCategory.catName = catName;
    aCategory.catId = catid;
    aCategory.articleList = articleList;
    
    
    [list addObject:aCategory];
    
    NSLog(@"Llist addObject: %@, id = %@",catName,catid);
    
   
    
}

//- (void) AddToQueue:(NSString *)urlString Title:(NSString *)title Image:(NSString *)image Author:(NSString *)author Introtext:(NSString *)introtext Time:(NSString *)time ArticleId:(NSString *)articleId
//{
//    Article* article = [Article alloc];
//    
//    article.link = urlString;
//    article.title = title;
//    article.image = image;
//    article.author =  author;
//    article.introtext = introtext;
//    article.time = time;
//    article.articleId = articleId;
//    
//    [articleList addObject:article];
//}


@end

