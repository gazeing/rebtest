//
//  TopStoryView.h
//  RPM
//
//  Created by Steven Xu on 12/02/2015.
//  Copyright (c) 2015 Sterling Publishing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Article;
@interface TopStoryView : UIView


- (id)  init;

- (void)resizeView;
- (void)fillWithFirstArticle:(Article *)article;

@end
