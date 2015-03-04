//
//  PPViewController.h
//  PPImageScrollingTableViewControllerDemo
//
//  Created by popochess on 13/8/9.
//  Copyright (c) 2013年 popochess. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowserViewController.h"
#import "SPSideMenu.h"
#import "PreCachingWebView.h"
#import "JsonDownloader.h"

//@class WIPBrowserViewController;
@interface PPViewController : UITableViewController <RESideMenuDelegate,JsonDownloaderDelegate>
{
    NSMutableArray *list;
    
    //the invisible webview to do pre-loading
    PreCachingWebView *m_PreCachingWebView;
    
    JsonDownloader *jsonDownloader;
}

- (void) showUrlInContentView : (NSString *) url;

@end
