//
//  LoadingAricleList.h
//  RPM
//
//  Created by Steven Xu on 28/01/2015.
//  Copyright (c) 2015 Sterling Publishing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadingArticleList : NSObject
{
     NSString *jsonUrl;
    
     NSMutableArray *list;
    
    
}

- (id)init;
-(void)loadArticleList;
@end
