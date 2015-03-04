//
//  RebBrowserViewController.m
//  HybridWebView
//
//  Created by Steven Xu on 9/07/2014.
//  Copyright (c) 2014 Sterling Publishing. All rights reserved.
//


//#define    kInAppBrowserToolbarBarPositionBottom @"bottom"
//#define    kInAppBrowserToolbarBarPositionTop @"top"


//

#import "Constants.h"
#import "BrowserViewController.h"
#import <Social/Social.h>
#import <MobileCoreServices/MobileCoreServices.h>
//#import "WebViewJavascriptBridge.h" //source can be found @ https://github.com/gazeing/WebViewJavascriptBridge
#import <Foundation/NSException.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MobileCoreServices/MobileCoreServices.h>
//#import "MISLinkedinShare.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "GSIndeterminateProgressView.h"






@interface BrowserViewController ()
{
    int load_count;
    
     GSIndeterminateProgressView *_progressView;
}

@end

@implementation BrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@synthesize currentURL;

- (id)initWithUserAgent:(NSString*)userAgent prevUserAgent:(NSString*)prevUserAgent
{
    self = [super init];
    if (self != nil) {
        _userAgent = userAgent;
        _prevUserAgent = prevUserAgent;

        [self createViews];
        [self showLocationBar:hasLocation];
        [self showToolBar:hasToolbar :toolbarposition];
        
        
        self.timeCalculation = [[LoadingTimeCalculation alloc] initCalculation];
        baseUrl =HOMEPAGE_URL;
        
        
//        [self navigateTo:[NSURL URLWithString:@"http://www.rebonline.com.au/app"]];
        
//        [self.webView setScalesPageToFit:YES];
//        [self loadRequestFromString:@"http://www.google.com.au"];
        
//        isCurrentViewFresh = YES;
    }
    
    return self;
}

- (void)loadRequestFromString:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
}


- (void)createViews
{
    // We create the views in code for primarily for ease of upgrades and not requiring an external .xib to be included
    
    CGRect webViewBounds = self.view.bounds;
//    BOOL toolbarIsAtBottom = true;
    toolbarposition = kInAppBrowserToolbarBarPositionBottom;
    hasLocation = false;
    hasToolbar = false;
    
    
    
    
    BOOL toolbarIsAtBottom = ![toolbarposition isEqualToString:kInAppBrowserToolbarBarPositionTop];
    webViewBounds.size.height -= hasLocation ? FOOTER_HEIGHT : TOOLBAR_HEIGHT;
    self.webView = [[UIWebView alloc] initWithFrame:webViewBounds];
    
    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [self.view addSubview:self.webView];
    [self.view sendSubviewToBack:self.webView];
    
//    NSLog(@"self.webView.delegate = _webViewDelegate;");
//    self.webView.delegate = _webViewDelegate;
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    
    self.webView.clearsContextBeforeDrawing = YES;
    self.webView.clipsToBounds = YES;
    self.webView.contentMode = UIViewContentModeScaleToFill;
    self.webView.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    self.webView.multipleTouchEnabled = YES;
    self.webView.opaque = YES;
    self.webView.scalesPageToFit = NO;
    self.webView.userInteractionEnabled = YES;
    self.webView.suppressesIncrementalRendering = YES;
    
    // overwrite the 'window.open' to be a 'open://' URL (see above)
    NSError *error = nil;
    NSString *jsFromFile = [NSString stringWithContentsOfURL:[[NSBundle mainBundle]
                                                              URLForResource:@"JS1" withExtension:@"txt"]
                                                    encoding:NSUTF8StringEncoding error:&error];
    __unused NSString *jsOverrides = [self.webView
                                      stringByEvaluatingJavaScriptFromString:jsFromFile];
    
    
//    NSLog(@"self.webView   createViews");
    
    [self createSpinner];
    
    
    self.closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
    self.closeButton.enabled = YES;
    
    
    flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    fixedSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpaceButton.width = 20;
    
    float toolbarY = toolbarIsAtBottom ? self.view.bounds.size.height - TOOLBAR_HEIGHT : 0.0;
    CGRect toolbarFrame = CGRectMake(0.0, toolbarY, self.view.bounds.size.width, TOOLBAR_HEIGHT);
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
    self.toolbar.alpha = 1.000;
    self.toolbar.autoresizesSubviews = YES;
    self.toolbar.autoresizingMask = toolbarIsAtBottom ? (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin) : UIViewAutoresizingFlexibleWidth;
    self.toolbar.barStyle = UIBarStyleBlackOpaque;
    self.toolbar.clearsContextBeforeDrawing = NO;
    self.toolbar.clipsToBounds = NO;
    self.toolbar.contentMode = UIViewContentModeScaleToFill;
    self.toolbar.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    self.toolbar.hidden = NO;
    self.toolbar.multipleTouchEnabled = NO;
    self.toolbar.opaque = NO;
    self.toolbar.userInteractionEnabled = YES;
    
    CGFloat labelInset = 5.0;
    float locationBarY = toolbarIsAtBottom ? self.view.bounds.size.height - FOOTER_HEIGHT : self.view.bounds.size.height - LOCATIONBAR_HEIGHT;
    
    self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelInset, locationBarY, self.view.bounds.size.width - labelInset, LOCATIONBAR_HEIGHT)];
    self.addressLabel.adjustsFontSizeToFitWidth = NO;
    self.addressLabel.alpha = 1.000;
    self.addressLabel.autoresizesSubviews = YES;
    self.addressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    self.addressLabel.backgroundColor = [UIColor clearColor];
    self.addressLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.addressLabel.clearsContextBeforeDrawing = YES;
    self.addressLabel.clipsToBounds = YES;
    self.addressLabel.contentMode = UIViewContentModeScaleToFill;
    self.addressLabel.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    self.addressLabel.enabled = YES;
    self.addressLabel.hidden = NO;
    self.addressLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    if ([self.addressLabel respondsToSelector:NSSelectorFromString(@"setMinimumScaleFactor:")]) {
        [self.addressLabel setValue:@(10.0/[UIFont labelFontSize]) forKey:@"minimumScaleFactor"];
    } else if ([self.addressLabel respondsToSelector:NSSelectorFromString(@"setMinimumFontSize:")]) {
        [self.addressLabel setValue:@(10.0) forKey:@"minimumFontSize"];
    }
    
    self.addressLabel.multipleTouchEnabled = NO;
    self.addressLabel.numberOfLines = 1;
    self.addressLabel.opaque = NO;
    self.addressLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    self.addressLabel.text = NSLocalizedString(@""/*@"Loading..."*/, nil);
    self.addressLabel.textAlignment = NSTextAlignmentLeft;
    self.addressLabel.textColor = [UIColor colorWithWhite:1.000 alpha:1.000];
    self.addressLabel.userInteractionEnabled = NO;
    
    NSString* frontArrowString = NSLocalizedString(@"►", nil); // create arrow from Unicode char
    self.forwardButton = [[UIBarButtonItem alloc] initWithTitle:frontArrowString style:UIBarButtonItemStylePlain target:self action:@selector(goForward:)];
    self.forwardButton.enabled = YES;
    self.forwardButton.imageInsets = UIEdgeInsetsZero;
    
    NSString* backArrowString = NSLocalizedString(@"◄", nil); // create arrow from Unicode char
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:backArrowString style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    self.backButton.enabled = YES;
    self.backButton.imageInsets = UIEdgeInsetsZero;
    
   
//    [self.toolbar setItems:@[self.closeButton, flexibleSpaceButton, self.backButton, fixedSpaceButton, self.forwardButton]];
       [self.toolbar setItems:@[self.closeButton,  flexibleSpaceButton]];
     //added by steven 20-06-2014 to remove closebutton
    //    [self.toolbar setItems:@[ flexibleSpaceButton, self.backButton, fixedSpaceButton, self.forwardButton]];
    
    self.view.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.toolbar];
    [self.view addSubview:self.addressLabel];
    //    [self.view addSubview:self.spinner];
    
    
    
    //added by steven for js bridge 13-06-2014
    
    //    WebScriptObject *wso = self.webView.windowScriptObject;
    //    [wso setValue:[WebScriptBridge getWebScriptBridge] forKey:@"yourBridge"];
    
//    [self createJavaScriptBridge];
    
    
    
    
    //add pickerView
    
    [self createPickerView];
    
    
    
    
    
    //add end
    
    //add loadingview
    [self createLoadingView];
}




- (void) createSpinner{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinner.alpha = 1.000;
    self.spinner.autoresizesSubviews = YES;
    self.spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.spinner.clearsContextBeforeDrawing = NO;
    self.spinner.clipsToBounds = NO;
    self.spinner.contentMode = UIViewContentModeScaleToFill;
    self.spinner.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    self.spinner.frame = CGRectMake(454.0, 231.0, 20.0, 20.0);
    self.spinner.hidden = YES;
    self.spinner.hidesWhenStopped = YES;
    self.spinner.multipleTouchEnabled = NO;
    self.spinner.opaque = NO;
    self.spinner.userInteractionEnabled = NO;
    [self.spinner stopAnimating];
}

//- (void) createJavaScriptBridge{
//    if(_bridge){
//        NSLog(@"bridge is exist");
//        
//    }else{
//        [WebViewJavascriptBridge enableLogging];
//        _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView webViewDelegate:self.webView.delegate handler:^(id data, WVJBResponseCallback responseCallback) {
//            NSLog(@"Received message from javascript: %@", data);
//            responseCallback(@"Right back atcha");
//            [self shareLink:data];
//        }];
//    }
//}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (void) shareLink : (NSString *) data{
    
    
    NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
    NSString *action = [dict valueForKey:@"shareAction"];
    shareUrl = [dict valueForKey:@"shareURL"];
    shareTitle  = [dict valueForKey:@"shareTitle"];
    
    NSLog(@"the action = %@",action);
    NSLog(@"the url = %@",shareUrl);
    NSLog(@"the title = %@",shareTitle);
    
    if ([action isEqual:@"openExternal"]){
        
        if(![shareUrl hasPrefix:@"http"]){
            shareUrl = [@"http://" stringByAppendingString:shareUrl];
        }
        
        NSURL *urlToOpen = [NSURL URLWithString:shareUrl];
        NSLog(@"urlToOpen = %@",urlToOpen);
        if ([[UIApplication sharedApplication] canOpenURL:urlToOpen]) {
            [[UIApplication sharedApplication] openURL:urlToOpen];
        }
    }else{
        
        if (![shareUrl length]==0) {

            
            //open the share menu instead
            [self performSelector: @selector(presentRightMenuViewController:) withObject:self afterDelay: 0.0];
            

            
        }
        
    }
    

    
}

#pragma clang diagnostic pop

- (void) shareLinkVia : (NSString *) action TitleToDisplay:(NSString*)title UrlToShare:(NSString*)urlString{
    if(urlString==NULL){return;}
    if ([action isEqual:@"facebook"]) {
        
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [composeViewController setInitialText:title];
        if (urlString != (id)[NSNull null]) {
            //            [composeViewController addURL:[NSURL URLWithString:urlString]];
            [composeViewController addURL:[NSURL URLWithString:urlString]];
        }
        [self presentViewController:composeViewController animated:YES completion:nil];
        [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
            // now check for availability of the app and invoke the correct callback
            
            
            NSLog(@"composeViewController finish: %d",result);
        }];
        
    }else if ([action isEqual:@"twitter"]){
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeViewController setInitialText:title];
        if (urlString != (id)[NSNull null]) {
            //            [composeViewController addURL:[NSURL URLWithString:urlString]];
            [composeViewController addURL:[NSURL URLWithString:urlString]];
        }
        [self presentViewController:composeViewController animated:YES completion:nil];
        [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
            // now check for availability of the app and invoke the correct callback
            
            
            NSLog(@"composeViewController finish: %d",result);
        }];
        
        
    }else if ([action isEqual:@"whatsapp"]){
        
        [self shareViaWhatsApp:title UrlToShare:urlString];
    }else if ([action isEqual:@"mail"]){
        
        [self shareViaEmail:title UrlToShare:urlString];
    }
    else if ([action isEqual:@"google+"]){
        
        [self shareViaGooglePlus:title UrlToShare:urlString];
    }
    else if ([action isEqual:@"linkedin"]){
        
        [self shareViaLinkedIn:title UrlToShare:urlString];
    }
}



- (void) shareViaLinkedIn:(NSString*)title UrlToShare:(NSString*)urlString{
    
    
    NSString *linkedinLink = @"http://www.linkedin.com/shareArticle?mini=true&url=";
    linkedinLink = [linkedinLink stringByAppendingString:urlString];
    linkedinLink = [linkedinLink stringByAppendingString:@"&title="];
    linkedinLink = [linkedinLink stringByAppendingString:title];
    
    NSLog(@"linkedinLink =  %@",linkedinLink);
    NSString* webStringURL = [linkedinLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"webStringURL =  %@",webStringURL);
    NSURL *url = [NSURL URLWithString:webStringURL];
    NSLog(@"url =  %@",url);
    
    if (![[UIApplication sharedApplication] openURL:url]){
        
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
        [self showAlert :@"Failed to share url:"];
    }
}



-(void)googlePlusSignIn{
    signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    //signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
   
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = GOOGLE_KCLIENT_ID;

    // Uncomment one of these two statements for the scope you chose in the previous step
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
    //    signIn.scopes = @[ @"profile" ];            // "profile" scope
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    [signIn authenticate];
}
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    if (error) {
        NSLog(@"Received error %@ and auth object %@",error, auth);
        NSLog(@"Current identifier: %@", [[NSBundle mainBundle] bundleIdentifier]);
        NSLog(@"Current clientID: %@", GOOGLE_KCLIENT_ID);

        [self showAlert :GOOGLE_PLUS_NOT_WORKING_ALERT];
        
        
        
    }else{
        NSLog(@"login success %@", auth);
        [self shareViaGooglePlus:shareTitle UrlToShare:shareUrl];
        
    }
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    // This is an example of how you can implement it if your app is navigation-based.
    [[self navigationController] pushViewController:viewController animated:YES];
}

-(void)shareViaGooglePlus:(NSString*)title UrlToShare:(NSString*)urlString{
    
    if (!signIn.authentication) {
        [self googlePlusSignIn];
    }
    else{
        //        [signIn trySilentAuthentication];
        
        id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
        
        // This line will fill out the title, description, and thumbnail from
        // the URL that you are sharing and includes a link to that URL.
        [shareBuilder setURLToShare:[NSURL URLWithString:urlString]];
        
        [shareBuilder open];
    }
    
}


- (bool)isEmailAvailable {
    Class messageClass = (NSClassFromString(@"MFMailComposeViewController"));
    return messageClass != nil && [messageClass canSendMail];
}
- (void)shareViaEmail:(NSString*)title UrlToShare:(NSString*)urlString {
    if ([self isEmailAvailable]) {
        MFMailComposeViewController* draft = [[MFMailComposeViewController alloc] init];
        draft.mailComposeDelegate = self;
        
        if (urlString != (id)[NSNull null]) {
            NSString *message =urlString;
            BOOL isHTML = [message rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch].location != NSNotFound;
            [draft setMessageBody:message isHTML:isHTML];
        }
        
        if (title != (id)[NSNull null]) {
            [draft setSubject: title];
        }
        
        
        
        if (draft) [self presentModalViewController:draft animated:YES];
        
        
    } else {
        [self showAlert :MAIL_NOT_WORKING_ALERT];
    }
    
    
}

/**
 * Delegate will be called after the mail composer did finish an action
 * to dismiss the view.
 */
- (void) mailComposeController:(MFMailComposeViewController*)controller
           didFinishWithResult:(MFMailComposeResult)result
                         error:(NSError*)error {
    //    bool ok = result == MFMailComposeResultSent;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (bool)canShareViaWhatsApp {
    return [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"whatsapp://app"]];
}

- (void)shareViaWhatsApp:(NSString*)title UrlToShare:(NSString*)urlString {
    if ([self canShareViaWhatsApp]) {
        NSString *message   = title;
        
        {
            // append an url to a message, if both are passed
            NSString * shareString = @"";
            if (message != (id)[NSNull null]) {
                shareString = message;
            }
            if (urlString != (id)[NSNull null]) {
                if ([shareString isEqual: @""]) {
                    shareString = urlString;
                } else {
                    shareString = [NSString stringWithFormat:@"%@ %@", shareString, urlString];
                }
            }
            NSString * encodedShareString = [shareString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // also encode the '=' character
            encodedShareString = [encodedShareString stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
            NSString * encodedShareStringForWhatsApp = [NSString stringWithFormat:@"whatsapp://send?text=%@", encodedShareString];
            
            NSURL *whatsappURL = [NSURL URLWithString:encodedShareStringForWhatsApp];
            [[UIApplication sharedApplication] openURL: whatsappURL];
        }
        
        
    } else {
        
        [self showAlert :WHATSAPP_NOT_WORKING_ALERT];
        
    }
}

-(void) showAlert:(NSString *) alertMsg{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                    message:alertMsg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



-(void)shareFromSideMenu:(NSString *)socialMediaName
{
    //TODO: this  method only works when js enabled. find a better solution
    shareTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    shareUrl = self.webView.request.URL.absoluteString;
    
    [self shareLinkVia:[socialMediaName lowercaseString] TitleToDisplay:shareTitle UrlToShare:shareUrl];
}



- (void)createPickerView{

    
    
    shareApps = [NSArray arrayWithObjects:
                 @"Facebook",
                 @"Twitter",
                 @"Mail",
                 @"Google+",
                 @"Whatsapp",
                 @"LinkedIn",
                 nil];
}


- (void) setWebViewFrame : (CGRect) frame {
    //    NSLog(@"Setting the WebView's frame to %@", NSStringFromCGRect(frame));
    [self.webView setFrame:frame];
}

- (void)setCloseButtonTitle:(NSString*)title
{
    // the advantage of using UIBarButtonSystemItemDone is the system will localize it for you automatically
    // but, if you want to set this yourself, knock yourself out (we can't set the title for a system Done button, so we have to create a new one)
    self.closeButton = nil;
    self.closeButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
    self.closeButton.enabled = YES;
    self.closeButton.tintColor = [UIColor colorWithRed:60.0 / 255.0 green:136.0 / 255.0 blue:230.0 / 255.0 alpha:1];
    
    NSMutableArray* items = [self.toolbar.items mutableCopy];
    [items replaceObjectAtIndex:0 withObject:self.closeButton];
    [self.toolbar setItems:items];
}

- (void)showLocationBar:(BOOL)show
{
    CGRect locationbarFrame = self.addressLabel.frame;
    
    BOOL toolbarVisible = !self.toolbar.hidden;
    
    // prevent double show/hide
    if (show == !(self.addressLabel.hidden)) {
        return;
    }
    
    if (show) {
        self.addressLabel.hidden = NO;
        
        if (toolbarVisible) {
            // toolBar at the bottom, leave as is
            // put locationBar on top of the toolBar
            
            CGRect webViewBounds = self.view.bounds;
            webViewBounds.size.height -= FOOTER_HEIGHT;
            [self setWebViewFrame:webViewBounds];
            
            locationbarFrame.origin.y = webViewBounds.size.height;
            self.addressLabel.frame = locationbarFrame;
        } else {
            // no toolBar, so put locationBar at the bottom
            
            CGRect webViewBounds = self.view.bounds;
            webViewBounds.size.height -= LOCATIONBAR_HEIGHT;
            [self setWebViewFrame:webViewBounds];
            
            locationbarFrame.origin.y = webViewBounds.size.height;
            self.addressLabel.frame = locationbarFrame;
        }
    } else {
        self.addressLabel.hidden = YES;
        
        if (toolbarVisible) {
            // locationBar is on top of toolBar, hide locationBar
            
            // webView take up whole height less toolBar height
            CGRect webViewBounds = self.view.bounds;
            webViewBounds.size.height -= TOOLBAR_HEIGHT;
            [self setWebViewFrame:webViewBounds];
        } else {
            // no toolBar, expand webView to screen dimensions
            [self setWebViewFrame:self.view.bounds];
        }
    }
}

- (void)showToolBar:(BOOL)show : (NSString *) toolbarPosition
{
    
    NSLog(@"showToolBar=====%hhd",show);
    
    CGRect toolbarFrame = self.toolbar.frame;
    CGRect locationbarFrame = self.addressLabel.frame;
    
    BOOL locationbarVisible = !self.addressLabel.hidden;
    
    // prevent double show/hide
    if (show == !(self.toolbar.hidden)) {
        return;
    }
    
    if (show) {
        self.toolbar.hidden = NO;
        CGRect webViewBounds = self.view.bounds;
        
        if (locationbarVisible) {
            // locationBar at the bottom, move locationBar up
            // put toolBar at the bottom
            webViewBounds.size.height -= FOOTER_HEIGHT;
            locationbarFrame.origin.y = webViewBounds.size.height;
            self.addressLabel.frame = locationbarFrame;
            self.toolbar.frame = toolbarFrame;
        } else {
            // no locationBar, so put toolBar at the bottom
            CGRect webViewBounds = self.view.bounds;
            webViewBounds.size.height -= TOOLBAR_HEIGHT;
            self.toolbar.frame = toolbarFrame;
        }
        
        if ([toolbarPosition isEqualToString:kInAppBrowserToolbarBarPositionTop]) {
            toolbarFrame.origin.y = 0;
            webViewBounds.origin.y += toolbarFrame.size.height;
            [self setWebViewFrame:webViewBounds];
        } else {
            toolbarFrame.origin.y = (webViewBounds.size.height + LOCATIONBAR_HEIGHT);
        }
        [self setWebViewFrame:webViewBounds];
        
    } else {
        self.toolbar.hidden = YES;
        
        if (locationbarVisible) {
            // locationBar is on top of toolBar, hide toolBar
            // put locationBar at the bottom
            
            // webView take up whole height less locationBar height
            CGRect webViewBounds = self.view.bounds;
            webViewBounds.size.height -= LOCATIONBAR_HEIGHT;
            [self setWebViewFrame:webViewBounds];
            
            // move locationBar down
            locationbarFrame.origin.y = webViewBounds.size.height;
            self.addressLabel.frame = locationbarFrame;
        } else {
            // no locationBar, expand webView to screen dimensions
            [self setWebViewFrame:self.view.bounds];
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    
  
    [self addTitleBarItems];
    

    load_count =0;
    
    
    //added by steven to try accelate page displaying
    if (0.0f == self.webView.alpha) {
        [UIView animateWithDuration:0.4f
                         animations:^{
                             self.webView.alpha = 1.0f;
                         }];
    }
    
    

}





- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{

    
    [self resizeLoadingView];

}


- (void) resizeLoadingView
{
    
    int titleHeight =self.navigationController.navigationBar.frame.size.height;
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    UIInterfaceOrientation orientation=[UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)){
        
        CGFloat swap = screenWidth;
        screenWidth=screenHeight;
        screenHeight =swap;
        
    }else{
        
    }
    
    CGRect viewBounds = self.view.bounds;
    NSLog(@"orientation change to %f, %f",viewBounds.size.width,viewBounds.size.height);
    
    // Normal Animation
//    self.animationImageView.frame =CGRectMake(screenWidth/2 - 58/2, screenHeight/2-40, 58, 40);

    
//    //TODO: to figure out the number "30" comes from..
//    self.animationImageView.frame = CGRectMake(viewBounds.size.width/2 - 58/2, (viewBounds.size.height+titleHeight)/2-40+30, 58, 40);
    
    // [self.navigationItem.titleView = self.animationImageView];
    
//    CGRect loadingViewBounds = CGRectMake(0,0,screenWidth,screenHeight);
    CGRect loadingViewBounds = viewBounds;
    self.translucentView.frame = loadingViewBounds;
    
}





-(BOOL)iPhone6Plus{
    if ([UIScreen mainScreen].scale > 2.1) return YES;   // Scale is only 3 when not in scaled mode for iPhone 6 Plus
    return NO;
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void)addTitleBarItems
{
    self.title = INITIAL_NAVIGATION_BAR_TITLE;
    UIImage *imgMenu = [UIImage imageNamed:@"IconMenu"];
    UIImage *imgShare = [UIImage imageNamed:@"IconShare"];
    UIImage *imgBack = [UIImage imageNamed:@"IconBack"];
    UIImage *imgEmpty = [UIImage imageNamed:@"IconEmpty"];
    
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithImage:imgShare
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self action:@selector(presentRightMenuViewController:)];
    
    UIBarButtonItem *emptyItem = [[UIBarButtonItem alloc] initWithImage:imgEmpty
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self action:nil];
    
    self.backItem = [[UIBarButtonItem alloc] initWithImage:imgBack
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(menuGoBack:)];
    [self.backItem setEnabled:NO];
    

    
    NSArray *actionButtonItems = @[ shareItem,self.backItem];

    
    
    
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithImage:imgMenu
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
    
    NSArray *leftactionButtonItems = @[menuItem,emptyItem];
    UIBarButtonItem* originItem   = self.navigationItem.leftBarButtonItem;
    if (originItem != nil) {
        leftactionButtonItems = @[originItem,menuItem];
    }
    

    
//   self.navigationItem.leftBarButtonItems = leftactionButtonItems;
    
    
    self.navigationItem.rightBarButtonItems = actionButtonItems;

    
    NSString *logo = IsIPad()?@"Logo-40":@"Logo-40-slim";
    NSString *logosmall = IsIPad()?@"Logo-small":@"Logo-small-slim";
    
    UIButton *titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [titleLabel setImage:[UIImage imageNamed:logo] forState:UIControlStateNormal];
    [titleLabel setImage:[UIImage imageNamed:logosmall] forState:UIControlStateHighlighted];
    titleLabel.frame = CGRectMake(100, 0, 200, 80);
    titleLabel.titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    titleLabel.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    
//    [titleLabel addTarget:self action:@selector(backToHomePage:) forControlEvents:UIControlEventTouchUpInside];
    [titleLabel addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleLabel;
    self.navigationItem.titleView.frame = CGRectMake(100, 0, 200, 80);
    
    
}
#pragma clang diagnostic pop

- (IBAction)menuGoBack:(id)sender
{
    [self goBack:sender];
}

- (IBAction)backToHomePage:(id)sender
{

    [(UINavigationController* )self.navigationController popToRootViewControllerAnimated:TRUE];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack
        NSLog(@"New view controller was pushed");
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
        NSLog(@"View controller was popped");
        
        [_progressView stopAnimating];
        
    }
}

- (void)viewDidUnload
{
//    [self.webView loadHTMLString:nil baseURL:nil];

    [super viewDidUnload];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)closePopUp{
    [wvPopUp removeFromSuperview];
    wvPopUp = nil;
    //restore the default setting of toolbar
    [self showToolBar:hasToolbar :toolbarposition];
    [self showLocationBar:hasLocation];
}

- (void)close
{
    //added by steven, if the popup window exist, then close it.
    if (wvPopUp) {
        
        [self closePopUp];
    }else{
        
        
//        [CDVUserAgentUtil releaseLock:&_userAgentLockToken];
        self.currentURL = nil;
    
        //TODO: check if has to change it
//        if ((self.navigationDelegate != nil) && [self.navigationDelegate respondsToSelector:@selector(browserExit)])    {
//            [self.navigationDelegate browserExit];
//        }
        
        // Run later to avoid the "took a long time" log message.
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self respondsToSelector:@selector(presentingViewController)]) {
                [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
            } else {
                [[self parentViewController] dismissModalViewControllerAnimated:YES];
            }
        });
    }
}

-(void)navigateTo:(NSURL*)url
{
    
    if (baseSiteUrl==nil) {
        baseSiteUrl = url;
    }
    NSLog(@"navigateTo ===%@",url);
    

    
    
    //added by steven to add timeout value
    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:20];
    [self.webView loadRequest:request];
   

}


-(void)navigateToFromClearPage:(NSURL *)url
{
    if (![url.absoluteString isEqualToString:preURl]) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
        [self navigateTo:url];
    }
    
}

#pragma mark - Local HTML testing

-(void)navigationToTestPage:(NSString* )articleId
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
    
    
    
    HtmlContentDownloader *downloader = [[HtmlContentDownloader alloc] init];
    downloader.delegate = self;
    [downloader startDownload];
    self.articleid = articleId;
    
}



- (void)onDownloadFinished:(id)downloader
{
    NSLog(@"it comes to webview");
    [((HtmlContentDownloader *)downloader) loadLocalHtml:self.webView HtmlPath:@"content.html" ArticleID:self.articleid];
}

- (void)onNoNeedToUpdate:(id)downloader
{
    NSLog(@"it onNoNeedToUpdate");
    [((HtmlContentDownloader *)downloader) loadLocalHtml:self.webView HtmlPath:@"content.html" ArticleID:self.articleid];

}

#pragma mark -


- (void)goBack:(id)sender
{
    [self.webView goBack];
}

- (void)goForward:(id)sender
{
    [self.webView goForward];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (IsAtLeastiOSVersion(@"7.0")) {
        [[UIApplication sharedApplication] setStatusBarStyle:[self preferredStatusBarStyle]];
    }
    [self rePositionViews];
    
    [self createProgressView];
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChangeNotification:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    
    //detect if it is the first login, if yes show the welcome screen
//    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
//                                objectForKey:KEY_IF_FIRST_TIME_LOGIN]]) {
//        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:KEY_IF_FIRST_TIME_LOGIN];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        [self.navigationController setNavigationBarHidden:YES animated:animated];
//        
//        
//        
//        [self showWelcomePage];
//        
//       
//        
//        
//    }else {
    
        
        

            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
       
    
//    [self showAdView];
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
//    }
    
    [super viewWillAppear:animated];
    
//    UITabBarItem* tabBarItem =  [[UITabBarItem alloc] initWithTitle:@"Reb" image:[UIImage imageNamed:@"IconFacebook"] tag:9];
//    self.tabBarItem = tabBarItem;
}

- (void) showAdView
{
    
    
    CGRect webViewBounds = self.view.bounds;
    self.webView_ad = [[UIWebView alloc] initWithFrame:webViewBounds];
    
//    self.webView_ad.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
//    self.webView_ad.contentMode = UIViewContentModeScaleAspectFit;

    
//    CGSize contentSize = self.webView_ad.scrollView.contentSize;
//    CGSize viewSize = self.view.bounds.size;
//    
//    float rw = viewSize.width / contentSize.width;
//    
//    self.webView_ad.scrollView.minimumZoomScale = rw;
//    self.webView_ad.scrollView.maximumZoomScale = rw;
//    self.webView_ad.scrollView.zoomScale = rw;
    
    [self.view addSubview:self.webView_ad];
    self.webView_ad.delegate = self;
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"ad" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
//    htmlString = @"test";
    [self.webView_ad loadHTMLString:htmlString baseURL:nil];
    
    
//    NSURL *url = [NSURL URLWithString:@"http://www.google.com.au"];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
//    [self.webView_ad loadRequest:urlRequest];
    
//    CGSize contentSize = self.webView_ad.scrollView.contentSize;
//    CGSize viewSize = self.view.bounds.size;
//    
//    float rw = viewSize.width / contentSize.width;
//    
////    self.webView_ad.scrollView.minimumZoomScale = rw;
////    self.webView_ad.scrollView.maximumZoomScale = rw;
//    self.webView_ad.scrollView.zoomScale = rw;
    self.webView_ad.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
    self.webView_ad.contentMode = UIViewContentModeScaleAspectFit;
    self.webView_ad.scalesPageToFit = YES;
    self.webView_ad.frame=self.view.bounds;
}

-(void)zoomToFit:(UIWebView *)theWebView
{
    
    if ([theWebView respondsToSelector:@selector(scrollView)])
    {
        UIScrollView *scroll=[theWebView scrollView];
        
        float zoom=theWebView.bounds.size.width/scroll.contentSize.width;
        scroll.zoomScale = zoom;
        [scroll setZoomScale:zoom animated:YES];
        
        self.webView_ad.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
        self.webView_ad.contentMode = UIViewContentModeScaleAspectFit;
        self.webView_ad.scalesPageToFit = YES;
    }
}

- (void) closeAdView
{
//    [self.webView_ad removeFromSuperview];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [UIView transitionWithView:self.view duration:1.0f
                       options:UIViewAnimationOptionTransitionNone animations:^(void)
     {
         [self.navigationController setNavigationBarHidden:NO animated:NO];
         self.webView_ad.alpha=0.0f;
     }
                    completion:^(BOOL finished)
     {
         [self.webView_ad removeFromSuperview];
     }];
}

- (void) createLoadingView
{
    // Load images
//    NSArray *imageNames = @[@"Logo-40-19",@"Logo-40-18",@"Logo-40-17",@"Logo-40-16", @"Logo-40-15",
//                            @"Logo-40-14",          @"Logo-40-13",
//                            @"Logo-40-12", @"Logo-40-11", @"Logo-40-10", @"Logo-40-9",
//                            @"Logo-40-8", @"Logo-40-7", @"Logo-40-6", @"Logo-40-5",
//                            @"Logo-40-4", @"Logo-40-3", @"Logo-40-2", @"Logo-40-1",@"Logo-40-0",@"Logo-40-0",@"Logo-40-0"];
    
//    NSMutableArray *images = [[NSMutableArray alloc] init];
//    for (int i = 0; i < imageNames.count; i++) {
//        [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
//    }
    
//    CGRect viewBounds = self.view.bounds;
//    
//    int titleHeight =self.navigationController.navigationBar.frame.size.height;
//    
//    // Normal Animation
//    self.animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(viewBounds.size.width/2 - 58/2, (viewBounds.size.height+titleHeight)/2-40+30, 58, 40)];
//    self.animationImageView.animationImages = images;
//    self.animationImageView.animationDuration = 3.5;
    
   // [self.navigationItem.titleView = self.animationImageView];
//    
//    CGRect loadingViewBounds = self.view.bounds;
//    
//    self.translucentView = [[ILTranslucentView alloc] initWithFrame:loadingViewBounds];
//    self.translucentView.translucentAlpha = 0.98;
//    self.translucentView.translucentStyle = UIBarStyleDefault;
//    self.translucentView.translucentTintColor = [UIColor clearColor];
//    self.translucentView.backgroundColor = [UIColor clearColor];
    

}

-(void) createProgressView
{
    if (_progressView==nil) {
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        
        
        GSIndeterminateProgressView *progressView = [[GSIndeterminateProgressView alloc] initWithFrame:CGRectMake(0, navigationBar.frame.size.height - 2,
                                                                                                                  navigationBar.frame.size.width, 2)];
        NSLog(@"navigationBar.frame : %f,%f,%f,%f",navigationBar.frame.origin.x,navigationBar.frame.origin.y,navigationBar.frame.size.width, navigationBar.frame.size.height);
        
        UIColor *selectedColor =[UIColor colorWithRed:101.0/255.0 green:167.8/255.0 blue:217.3/255.0 alpha:1];
        
        progressView.progressTintColor = selectedColor;//[UIColor blueColor];//navigationBar.barTintColor;
        progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [navigationBar addSubview:progressView];
        _progressView = progressView;
    }
}

- (void) startLoadingView
{
//    if (self.animationImageView!=NULL) {


//        [self.view addSubview:self.translucentView];
        
//        [self.view addSubview:self.animationImageView];
//        [self.animationImageView startAnimating];
        
        isLoadingStart = YES;
         [_progressView startAnimating];
//    }

}

- (void) stopLoadingView
{
    if (isLoadingStart == YES) {
//        if (self.translucentView!=NULL) {
//            
//            [self.translucentView removeFromSuperview];
//        }
//        if (self.animationImageView!=NULL) {
//            
//            
//            [self.animationImageView removeFromSuperview];
//            [self.animationImageView stopAnimating];
//        }
        isLoadingStart = NO;
        
        [_progressView stopAnimating];
    }

}

//
// On iOS 7 the status bar is part of the view's dimensions, therefore it's height has to be taken into account.
// The height of it could be hardcoded as 20 pixels, but that would assume that the upcoming releases of iOS won't
// change that value.
//
- (float) getStatusBarOffset {
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    float statusBarOffset = IsAtLeastiOSVersion(@"7.0") ? MIN(statusBarFrame.size.width, statusBarFrame.size.height) : 0.0;
    return statusBarOffset;
}

- (void) rePositionViews {
    if ([toolbarposition isEqualToString:kInAppBrowserToolbarBarPositionTop]) {
        [self.webView setFrame:CGRectMake(self.webView.frame.origin.x, TOOLBAR_HEIGHT, self.webView.frame.size.width, self.webView.frame.size.height)];
        [self.toolbar setFrame:CGRectMake(self.toolbar.frame.origin.x, [self getStatusBarOffset], self.toolbar.frame.size.width, self.toolbar.frame.size.height)];
    }
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView*)theWebView
{
    // loading url, start spinner, update back/forward
    
//    NSLog(@"webViewDidStartLoad: %@  %d",(theWebView.loading?@"loading":@"finish"), load_count++);
//    [self showLocationBar:YES];
//    [self showToolBar:YES :toolbarposition];
    
    [self.backItem setEnabled:NO];
    
    
    self.addressLabel.text = NSLocalizedString(@""/*@"Loading..."*/, nil);
    self.backButton.enabled = theWebView.canGoBack;
    self.forwardButton.enabled = theWebView.canGoForward;
    
    if ([self.webView_ad superview]==nil) {
        if (load_count==0) {
//            NSLog(@"currentUrl= %@",currentURL.absoluteString);
//            NSLog(@"preURl= %@",preURl);
            if (![currentURL.absoluteString isEqualToString:preURl]
                || [currentURL.absoluteString isEqualToString:baseUrl]) {
                [self startLoadingView];
                
                [self.timeCalculation LoadingStart];
            }

        }
        
    }
    
    load_count++;
    preURl = [theWebView.request.URL.absoluteString copy];
    
    
    //    [self.spinner startAnimating];
    
    //TODO: check if has to change it
//    return [self.navigationDelegate webViewDidStartLoad:theWebView];
}


- (void)injectJavascript:(NSString *)resource {
    NSString *jsPath = [[NSBundle mainBundle] pathForResource:resource ofType:@"js"];
    NSString *js = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:NULL];
    
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}


- (BOOL)webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    
   
    BOOL isTopLevelNavigation = [request.URL isEqual:[request mainDocumentURL]];
    
    if (isTopLevelNavigation) {
        self.currentURL = request.URL;
    }
    
    
    
    //added by steven for popup window
    NSString *realUrl = request.URL.absoluteString;
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
         NSLog(@"webViewDidStartLoad UIWebViewNavigationType = %ld link= %@" ,navigationType,realUrl);
    }
    
    
    if([realUrl rangeOfString:GOOGLE_AD_PREFIX].location != NSNotFound){
        [theWebView stopLoading];
        if (theWebView.canGoBack) {
            if (!isErrorReported) {
                [theWebView goBack];
                [theWebView goForward];
            }
            
        } else {
            //load the base page
            if (baseSiteUrl!=nil) {
                [theWebView loadRequest:[NSURLRequest requestWithURL:baseSiteUrl ]];
            }
            
        }
        if (![[UIApplication sharedApplication] openURL:request.URL]){
            
            NSLog(@"%@%@",@"Failed to open url:",[realUrl description]);
            [self showAlert :@"Failed to share url:"];
        }
        return NO;
    }
//    NSLog(@"realUrl: %@", realUrl);
    BOOL isLinkForLogin =
//    [realUrl hasPrefix:DISQUS_PREFIX]
    //            ||[realUrl hasPrefix:@"https://www.facebook.com"]
//    ||
    [realUrl hasPrefix:TWITTER_AUTH_PREFIX]
    ||[realUrl hasPrefix:DISQUS_AUTH_PREFIX]
//    ||[realUrl hasPrefix:@"https://accounts.google.com/ServiceLogin?"]
    ||[realUrl hasPrefix:FACEBOOK_SHARE_PREFIX]
    ||[realUrl hasPrefix:TWITTER_INTENT_PREFIX]
    ||[realUrl hasPrefix:LINKIN_SIGN_PREFIX]
    ||[realUrl hasPrefix:GOOGLE_PLUS_PREFIX]
    ||[realUrl hasPrefix:FACEBOOK_MOBILE_PREFIX];
    
    //  https://www.facebook.com/sharer/sharer.php
    //  https://twitter.com/intent/tweet
    //  platform.linkedin.com
    //  https://plus.google.com/_/+1/
    //  https://accounts.google.com/ServiceLogin?
    
    // 3. time has been selected - close the pop-up window
    if ([realUrl rangeOfString:@"back"].location == 0)
    {
        [self closePopUp];
        return NO;
    }

    
    if (isLinkForLogin) {
        
        
        // 2. we're loading it and have already created it, etc. so just let it load
        if (wvPopUp)
            return YES;
        
        // 1. we have a 'popup' request - create the new view and display it
        UIWebView *wv = [self popUpWebview];
        [wv loadRequest:request];
        return NO;
    }
    

    
    
//    if ([[[request URL] scheme] isEqualToString:@"callback"]) {
//        WIPBrowserViewController* nextController = [[WIPBrowserViewController alloc] initWithUserAgent:_userAgent prevUserAgent:_prevUserAgent];
//        NSString* jumpUrl = [[[request URL] scheme] stringByReplacingOccurrencesOfString:@"callback://" withString:@""];
//        [nextController navigateTo:[NSURL URLWithString:jumpUrl] ];
//        [self.navigationController pushViewController:nextController animated:TRUE];
//        return  NO;
//    }


    return YES;

}


//added by steven for popup window and close it

- (UIWebView *) popUpWebview
{
    CGRect webViewBounds = self.view.bounds;
    //    BOOL toolbarIsAtBottom = ![_browserOptions.toolbarposition isEqualToString:kInAppBrowserToolbarBarPositionTop];
    webViewBounds.size.height -= true ? FOOTER_HEIGHT : TOOLBAR_HEIGHT;
    //    self.webView = [[UIWebView alloc] initWithFrame:webViewBounds];
    // Create a web view that fills the entire window, minus the toolbar height
    UIWebView *webView = [[UIWebView alloc]
                          initWithFrame:webViewBounds];
    //                          CGRectMake(0, 0, (float)self.view.bounds.size.width,
    //                                                   (float)self.view.bounds.size.height)];
    webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    // Add to windows array and make active window
    wvPopUp = webView;
    
    
    [self.view addSubview:webView];
    //    [self.view sendSubviewToBack:webView];
    //    [self.toolbar setItems:@[self.closeButton, flexibleSpaceButton, self.backButton, fixedSpaceButton, self.forwardButton]];
    //    [self.toolbar setItems:@[ flexibleSpaceButton, self.backButton, fixedSpaceButton, self.forwardButton]];
    
    self.view.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.toolbar];
    [self.view addSubview:self.addressLabel];
    //    [self.view addSubview:self.spinner];
    
    [self setCloseButtonTitle:@"Done"];
    //    [self.spinner startAnimating];
    [self showLocationBar:true];
    [self showToolBar:true :toolbarposition];
    
    return webView;
}

- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    // update url, stop spinner, update back/forward
    load_count--;
    
    if ([self.webView_ad superview]==nil) {
        if (load_count==0) {
            if (isLoadingStart == YES) {
                
//                [self injectJavascript:@"detect"];
                [self stopLoadingView];
                
                [self.timeCalculation LoadingFinsish:theWebView.request.URL.absoluteString];
            }
        }
        
    }
    
//    NSLog(@"webViewDidFinishLoad :%@  %d",(theWebView.loading?@"loading":@"finish"),load_count--);
//    [self showLocationBar:NO];
//    [self showToolBar:NO :toolbarposition];
    if (theWebView==self.webView_ad) {
        [self zoomToFit:theWebView];
        [self performSelector:@selector(closeAdView) withObject:self afterDelay:15.0 ];
    }
    
    if (theWebView== self.webView) {
        if (m_PreCachingWebView==NULL) {
            m_PreCachingWebView = [[PreCachingWebView alloc] init];
            [m_PreCachingWebView startPreloading];
        }
    }
    
    
    if ([self.webView canGoBack]) {
        [self.backItem setEnabled:YES];
    }
    
    
    isErrorReported = false;
    
    //    //add by steven 23-06-14
    //    //if the link go to other website for login then show toolbar
    //    //if stay in our website, keep the origin setting of toolbar
    //    NSString *realUrl =[self.currentURL absoluteString];
    ////    if ([realUrl hasPrefix:@"http://www.rebonline.com.au"]) {
    ////        self.lastUrlBeforeLogin = realUrl;
    ////         NSLog(@"self.lastUrlBeforeLogin = %@",self.lastUrlBeforeLogin);
    ////    }
    //    BOOL isLinkForLogin = [realUrl hasPrefix:@"https://disqus.com"]
    //    ||[realUrl hasPrefix:@"https://www.facebook.com"]
    //    ||[realUrl hasPrefix:@"https://twitter.com"]
    //    ||[realUrl hasPrefix:@"https://accounts.google.com"]
    //    ||[realUrl hasPrefix:@"https://m.facebook.com/"];
    ////    NSLog(@"request.URL = %@",self.currentURL);
    //    NSLog(@"NSString *realUrl = %@",realUrl);
    //    if (isLinkForLogin) {
    //        [self showToolBar:true  :self.defaultBrowserOptions.toolbarposition];
    //    }else{
    //        [self showToolBar:self.defaultBrowserOptions.toolbar  :self.defaultBrowserOptions.toolbarposition];
    //    }
    //
    //    BOOL isLinkLoginSuccess = [realUrl hasPrefix:@"http://disqus.com/next/login-success/"];
    //    if (isLinkLoginSuccess) {
    ////        [self navigateTo:[NSURL URLWithString:self.lastUrlBeforeLogin]];
    //
    //
    //            [self.webView goBack];
    //            [self.webView goBack];
    //
    //    }
    
    // this is a pop-up window
    if (wvPopUp)
    {
        // overwrite the 'window.close' to be a 'back://' URL (see above)
        NSError *error = nil;
        NSString *jsFromFile = [NSString stringWithContentsOfURL:[[NSBundle mainBundle]
                                                                  URLForResource:@"JS2" withExtension:@"txt"]
                                                        encoding:NSUTF8StringEncoding error:&error];
        __unused NSString *jsOverrides = [wvPopUp
                                          stringByEvaluatingJavaScriptFromString:jsFromFile];
    }
    
    
    
    
    self.addressLabel.text = [self.currentURL absoluteString];
    self.backButton.enabled = theWebView.canGoBack;
    self.forwardButton.enabled = theWebView.canGoForward;
    
    //    [self.spinner stopAnimating];
    
    // Work around a bug where the first time a PDF is opened, all UIWebViews
    // reload their User-Agent from NSUserDefaults.
    // This work-around makes the following assumptions:
    // 1. The app has only a single Cordova Webview. If not, then the app should
    //    take it upon themselves to load a PDF in the background as a part of
    //    their start-up flow.
    // 2. That the PDF does not require any additional network requests. We change
    //    the user-agent here back to that of the CDVViewController, so requests
    //    from it must pass through its white-list. This *does* break PDFs that
    //    contain links to other remote PDF/websites.
    // More info at https://issues.apache.org/jira/browse/CB-2225
    
    
    //TODO: check if has to change it
//    BOOL isPDF = [@"true" isEqualToString :[theWebView stringByEvaluatingJavaScriptFromString:@"document.body==null"]];
//    if (isPDF) {
//        [CDVUserAgentUtil setUserAgent:_prevUserAgent lockToken:_userAgentLockToken];
//    }
//    
//    [self.navigationDelegate webViewDidFinishLoad:theWebView];
}



- (void)webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
{
//     NSLog(@"webView:didFailLoadWithError - %ld: %@   %d", (long)error.code, [error localizedDescription],load_count--);
        NSLog(@"webView:didFailLoadWithError - %ld: %@ %@", (long)error.code, [error localizedDescription],[theWebView request].URL.absoluteString);
   
    load_count--;
    if ([self.webView_ad superview]==nil) {
        if (load_count==0) {
            if (isLoadingStart == YES) {
                [self stopLoadingView];
                
                [self.timeCalculation LoadingFinsish:theWebView.request.URL.absoluteString];
            }
            
        }
    }
    
    if (theWebView==self.webView_ad) {
        [self performSelector:@selector(closeAdView) withObject:self afterDelay:0.0 ];
    }

    if(error.code == -999 || error.code == -1009)
        return;

    if(error.code == -1004){
        if (theWebView.canGoBack) {
            if (!isErrorReported) {
                [theWebView goBack];
                [theWebView goForward];
                [self showAlert:[[error localizedDescription] stringByAppendingString:NAVIGATE_USER_BACK]];
                isErrorReported = true;
            }
            
        } else {
            //load the base page
            if (baseSiteUrl!=nil) {
                [theWebView loadRequest:[NSURLRequest requestWithURL:baseSiteUrl ]];
                [self showAlert:[[error localizedDescription] stringByAppendingString:NAVIGATE_USER_HOME]];
            }
            
        }
    }
    if(error.code == -1001){
        [self showAlert:[[error localizedDescription] stringByAppendingString:PLEASE_CHECK_INTERNET]];
    }
    

}



@end
