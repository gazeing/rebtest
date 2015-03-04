//
//  PreCachingWebView.h
//  HybridWebView
//
//  Created by Steven Xu on 15/08/2014.
//  Copyright (c) 2014 Sterling Publishing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreCachingWebView : UIWebView <UIWebViewDelegate>
{
    NSMutableArray* m_LoadingQueue;
    NSMutableString* m_currentLoadUrl;
    
    NSString *jsonUrl;
}


- (id)init;

- (void)startPreloading;

@end
