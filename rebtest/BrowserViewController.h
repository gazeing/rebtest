//
//  RebBrowserViewController.h
//  HybridWebView
//
//  Created by Steven Xu on 9/07/2014.
//  Copyright (c) 2014 Sterling Publishing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <GooglePlus/GooglePlus.h>
//#import "WebViewJavascriptBridge.h" //source can be found @ https://github.com/gazeing/WebViewJavascriptBridge

#import "ILTranslucentView.h"

#import "LoadingTimeCalculation.h"
#import "PreCachingWebView.h"
#import "HtmlContentDownloader.h"


#define    TOOLBAR_HEIGHT 44.0
#define    LOCATIONBAR_HEIGHT 21.0



@interface BrowserViewController : UIViewController <UIWebViewDelegate,MFMailComposeViewControllerDelegate,GPPSignInDelegate,UIScrollViewDelegate,HtmlContentDownloaderDelegate>
{
@private
    NSString* _userAgent;
    NSString* _prevUserAgent;
    NSInteger _userAgentLockToken;

    
    NSString *shareUrl ;
    NSString *shareTitle ;
    
    BOOL hasLocation;
    NSString *toolbarposition;
    BOOL hasToolbar;
    
    NSArray *shareApps;
    GPPSignIn *signIn;
    
    //add by steven 23-06-14 for popup window
    UIWebView *wvPopUp;
    
    UIBarButtonItem* flexibleSpaceButton;
    UIBarButtonItem* fixedSpaceButton;
    
    //added by steven 30-06-2014 for cache
    
    NSURL *baseSiteUrl;
    BOOL *isErrorReported;
    
    //to record the previous loaded url
    NSMutableString* preURl;
    Boolean isLoadingStart;
    
    //indicate if this webview has loaded content
//    Boolean isCurrentViewFresh;
    
    
    //the base url of website;
    NSString *baseUrl;
    
    //the invisible webview to do pre-loading
    PreCachingWebView* m_PreCachingWebView;
}

//added by steven 18-07-14 for welcome pages


@property (nonatomic, retain) ILTranslucentView *translucentView;

@property (nonatomic, retain) UIBarButtonItem *backItem;
@property (nonatomic, retain) LoadingTimeCalculation *timeCalculation;


@property (nonatomic, assign) NSInteger selectedIndex;
//add by steven 23-06-14  to store default browser option for showtoolbar
//@property (retain, nonatomic) CDVInAppBrowserOptions* defaultBrowserOptions;
//@property (retain, nonatomic) NSString* lastUrlBeforeLogin;
//@property (retain, nonatomic) WebViewJavascriptBridge* bridge;
@property (retain, nonatomic) NSMutableArray *dataArray;

@property (nonatomic, strong) IBOutlet UIWebView* webView;
@property (nonatomic, strong) IBOutlet NSString* articleid;
@property (nonatomic, strong) IBOutlet UIWebView* webView_ad;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* closeButton;
@property (nonatomic, strong) IBOutlet UILabel* addressLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* backButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* forwardButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* spinner;
@property (nonatomic, strong) IBOutlet UIToolbar* toolbar;


//@property (nonatomic, weak) id <CDVScreenOrientationDelegate> orientationDelegate;
//@property (nonatomic, weak) CDVInAppBrowser* navigationDelegate;
@property (nonatomic) NSURL* currentURL;

- (void)close;
- (void)navigateTo:(NSURL*)url;
- (void)navigateToFromClearPage:(NSURL *)url;
-(void)navigationToTestPage:(NSString* )articleId;
- (void)showLocationBar:(BOOL)show;
- (void)showToolBar:(BOOL)show : (NSString *) toolbarPosition;
- (void)setCloseButtonTitle:(NSString*)title;
-(void)shareFromSideMenu:(NSString *)index;


- (id)initWithUserAgent:(NSString*)userAgent prevUserAgent:(NSString*)prevUserAgent;

@end
