//
//  AppDelegate.m
//  id
//
//  Created by Steven Xu on 27/02/2015.
//  Copyright (c) 2015 Sterling Publishing. All rights reserved.
//

#import "AppDelegate.h"


#import "LeftMenuViewController.h"
#import "RighMenuViewController.h"
#import "BrowserViewController.h"


#import <GooglePlus/GooglePlus.h>
#import "PPViewController.h"







@implementation AppDelegate
{
    NSString *message;
    NSString *newsUrl;
    UINavigationController *navController;
}

@synthesize list;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.list = [[NSMutableArray alloc] init];
    
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                            diskCapacity:0
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    
    //added 04/MAR/2014
    // Let the device know we want to receive push notifications
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    //register to receive notifications
    else
    {
        
        
        
        // use registerForRemoteNotifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    PPViewController * rootController = [[PPViewController alloc] init];
    navController =[[UINavigationController alloc] initWithRootViewController:rootController];
    [navController.navigationBar setBarStyle:UIBarStyleDefault];
    
    
    //
    LeftMenuViewController *leftMenuViewController = [[LeftMenuViewController alloc] init];
    RighMenuViewController *rightMenuViewController = [[RighMenuViewController alloc] init];
    
    
    self.sideMenuViewController = [[SPSideMenu alloc] initWithContentViewController:navController  leftMenuViewController:leftMenuViewController rightMenuViewController:rightMenuViewController ];
    
    self.sideMenuViewController.backgroundImage = [UIImage imageNamed:@"MenuBackground"];
    self.sideMenuViewController.menuPreferredStatusBarStyle = 1; // UIStatusBarStyleLightContent
    self.sideMenuViewController.delegate = self;
    self.sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
    self.sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
    self.sideMenuViewController.contentViewShadowOpacity = 0.6;
    self.sideMenuViewController.contentViewShadowRadius = 12;
    self.sideMenuViewController.contentViewShadowEnabled = YES;
    self.sideMenuViewController.panGestureEnabled = NO;
    
    self.window.rootViewController = self.sideMenuViewController;
    
    
    [self.window makeKeyAndVisible];
    
    
    //make splash screen display longer
    //    sleep(1);
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    
    if (launchOptions != nil)
    {
        NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            NSLog(@"Launched from push notification: %@", dictionary);
            [self showMessageFromRemoteNotification:dictionary application:application updateUI:NO];
        }
    }
    
    
    //     [GMSServices provideAPIKey:@"INSERT_GOOGLE_API_KEY_HERE"];
    
    return YES;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    //    NSLog(@"willShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    //    NSLog(@"didShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    //    NSLog(@"willHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    //    NSLog(@"didHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

#pragma mark -
#pragma mark AlertView Delegate


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        NSLog(@"ok button has been clicked");
        
        if (newsUrl !=nil ) {
            [(PPViewController*)(navController.viewControllers[0]) showUrlInContentView:newsUrl];
            
        }
    }else{
        message = nil;
        newsUrl = nil;
    }
}


-(NSString*)getAppUA
{
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //    NSLog(@"build version = :  %@",version);
    // Modify the user-agent
    NSString* suffixUA = [NSString stringWithFormat:@" mobileapp %@",version];//@" mobileapp";
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* defaultUA = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString* finalUA = [defaultUA stringByAppendingString:suffixUA];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:finalUA, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    return finalUA;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Received notification: %@", userInfo);
    [self showMessageFromRemoteNotification:userInfo application:application updateUI:YES];
}

- (void)showMessageFromRemoteNotification:(NSDictionary*)userInfo application:(UIApplication *)application updateUI:(BOOL)updateUI
{
    
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        NSString *cancelTitle = @"Close";
        NSString *showTitle = @"Show";
        //        NSString *json = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        //        NSLog(@"json =  %@",json);
        //        NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
        //        NSDictionary *jsonDict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: nil];
        //        message = [jsonDict valueForKey:@"title"];
        //        newsUrl = [jsonDict valueForKey:@"url"];
        
        //        NSString *message = [[[userInfo valueForKey:@"aps"] valueForKey:@"alert"] valueForKey:@"title"];
        //        NSString *newsUrl = [[[userInfo valueForKey:@"aps"] valueForKey:@"alert"] valueForKey:@"url"];
        
        NSString *alert = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        NSLog(@"alert = %@",alert);
        message = [[userInfo valueForKey:@"aps"] valueForKey:@"title"];
        newsUrl = [[userInfo valueForKey:@"aps"] valueForKey:@"url"];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Break-News" message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:showTitle, nil];
        [alertView show];
        
    } else {
        NSLog(@"show alert");
        //        NSString *cancelTitle = @"Close";
        //        NSString *showTitle = @"Show";
        
        NSString *alert = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        NSLog(@"alert = %@",alert);
        message = [[userInfo valueForKey:@"aps"] valueForKey:@"title"];
        newsUrl = [[userInfo valueForKey:@"aps"] valueForKey:@"url"];
        
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Break-News" message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:showTitle, nil];
        //        [alertView show];
        
        if (newsUrl !=nil ) {
            [(PPViewController*)(navController.viewControllers[0]) showUrlInContentView:newsUrl];
        }
    }
    
    
}

//added 03/MAR/2014
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"My token is: %@", deviceToken);
    NSString *tokenString = [deviceToken description];
    tokenString = [tokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:@"REBDeviceToken"];
    NSLog(@"My token is: %@", tokenString);
    NSString *uuid=[[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"UUID %@",uuid);
    
    BOOL regdForPush=YES;
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if(types==UIRemoteNotificationTypeNone){
        NSLog(@"Not Registered");
        regdForPush=NO;
    }else{
        regdForPush=YES;
        NSLog(@"Registered for");
    }
    
    
    
    
    
    NSString *loadUrl = [NSString stringWithFormat:@"%@?deviceToken=%@&registeredForPush=%d&UUID=%@&OS=ios",HOMEPAGE_URL,tokenString,regdForPush,uuid];
    
    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                objectForKey:KEY_IF_RECEIVE_NOTIFICATION]]) {
        loadUrl = HOMEPAGE_URL;
    }
    
    
}
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
    if (newsUrl==nil) {
        
    }
}

//added by steven 13/06/2014
- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    
    
    // Check the calling application Bundle ID
    if ([[url scheme] isEqualToString:@"com.sterlingpublishing.id"])
    {
        //        NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
        //        NSLog(@"URL scheme:%@", [url scheme]);
        //        NSLog(@"URL query: %@", [url query]);
        newsUrl =[url query];
        NSLog(@"news url from widget: %@",newsUrl);
        if ([newsUrl containsString:@"&code="]) {
            return [GPPURLHandler handleURL:url
                          sourceApplication:sourceApplication
                                 annotation:annotation];
        }
        
        [(PPViewController*)(navController.viewControllers[0]) showUrlInContentView:newsUrl];
        
        
        
    }
    return YES;
    
    
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    //    NSLog(@"do sth to release memory");
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


@end
