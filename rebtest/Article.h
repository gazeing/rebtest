//
//  Article.h
//  RPM
//
//  Created by Steven Xu on 28/01/2015.
//  Copyright (c) 2015 Sterling Publishing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject

@property (strong, nonatomic) NSString* link;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* image;
@property (strong, nonatomic) NSString* articleId;
@property (strong, nonatomic) NSString* time;
@property (strong, nonatomic) NSString* author;
@property (strong, nonatomic) NSString* introtext;

@end
