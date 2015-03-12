//
//  HtmlContentDownloader.h
//  RPM
//
//  Created by Steven Xu on 16/02/2015.
//  Copyright (c) 2015 Sterling Publishing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "Article.h"

// declare our class
@class HtmlContentDownloader;

// define the protocol for the delegate
@protocol HtmlContentDownloaderDelegate

// define protocol functions that can be used in any class using this delegate
//-(void)sayHello:(JsonDownloader *)customClass;

@required
- (void)onDownloadFinished:(id)downloader;
- (void)onNoNeedToUpdate:(id)downloader;


@end

@interface HtmlContentDownloader : NSObject
{
    NSMutableArray *downloadList;
    NSString *loadUrl;
}

@property (nonatomic, assign) id  delegate;



- (id)   initWithLoadUrl:(NSString *) loadListJsonUrl;

- (void) startDownload;
- (void) loadLocalHtml:(UIWebView *)webview HtmlPath:(NSString* )htmlpath Article:(Article*)article;

@end
