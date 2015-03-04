//
//  ArticleCategory.h
//  RPM
//
//  Created by Steven Xu on 28/01/2015.
//  Copyright (c) 2015 Sterling Publishing. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Article;

@interface ArticleCategory : NSObject

@property (strong, nonatomic) NSString* catId;
@property (strong, nonatomic) NSString* catName;
@property (strong, nonatomic) NSMutableArray* articleList;


@end
