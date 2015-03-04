//
//  WIPConstants.h
//  WIP
//
//  Created by Steven Xu on 26/08/2014.
//  Copyright (c) 2014 Sterling Publishing. All rights reserved.
//

#ifndef WIP_WIPConstants_h
#define WIP_WIPConstants_h


#ifdef DEBUG
#define kBaseURL @"http://www.rebonline.com.au/"
#else
#define kBaseURL @"http://myproductionserver.com/"
#endif



//strings

#define     MENU_JSON_URL @"http:/www.rebonline.com.au/steven/json/id_side_menu.json"
#define     BASE_URL @"http://www.rebonline.com.au"
#define     HOMEPAGE_URL @"http://www.rebonline.com.au/"
#define     PRELOADING_JSON_URL @"http://test.rebonline.com.au/?option=com_ajax&format=json&plugin=latestajaxarticlesfromcategory&cat_id=26"
#define     GET_ARTICLE_URL_PREFIX @"http://test.rebonline.com.au/?option=com_ajax&format=json&plugin=latestajaxarticlesfromcategory&cat_id="

#define     GOOGLE_KCLIENT_ID @"81309430898-iimp6s5jpe4rnbeccdfnk5mdo3t9mgbo.apps.googleusercontent.com"

#define     GOOGLE_AD_PREFIX @"g.doubleclick.net/aclk"
#define     DISQUS_PREFIX @"https://disqus.com"
#define     DISQUS_AUTH_PREFIX @"http://disqus.com/_ax"
#define     TWITTER_AUTH_PREFIX @"https://twitter.com/oauth/"
#define     FACEBOOK_SHARE_PREFIX @"http://www.facebook.com/sharer/sharer.php"
#define     TWITTER_INTENT_PREFIX @"https://twitter.com/intent/tweet"
#define     LINKIN_SIGN_PREFIX @"https://www.linkedin.com/uas/connect/user-signin"
#define     GOOGLE_PLUS_PREFIX @"https://plus.google.com/_/"
#define     FACEBOOK_MOBILE_PREFIX @"https://m.facebook.com/"




#define     TEXT_NEWS_ALERT @"News alerts"
#define     GOOGLE_PLUS_NOT_WORKING_ALERT @"Google+ is not working on your phone, please check it."
#define     MAIL_NOT_WORKING_ALERT @"Mail is not working on your phone, please check it."
#define     WHATSAPP_NOT_WORKING_ALERT @"WhatsApp is not working on your device, please check it."
#define     NAVIGATE_USER_BACK @" We have navigated you to your orginal page."
#define     NAVIGATE_USER_HOME @" We have navigated you to the base page."
#define     PLEASE_CHECK_INTERNET @" Please check your Internet access."

#define     INITIAL_NAVIGATION_BAR_TITLE @"MAIN"


//functions
#define    IsAtLeastiOSVersion(X) ([[[UIDevice currentDevice] systemVersion] compare:X options:NSNumericSearch] !=NSOrderedAscending)

#define    IsIPad() ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad))

#define    IsIPhone5() ([[UIScreen mainScreen] bounds].size.height == 568 && [[UIScreen mainScreen] bounds].size.width == 320)
#define     SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6PLUS (IS_IPHONE && [[UIScreen mainScreen] nativeScale] == 3.0f)
#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0)




#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


//key names
#define    kInAppBrowserToolbarBarPositionBottom @"bottom"
#define    kInAppBrowserToolbarBarPositionTop @"top"

#define     KEY_IF_RECEIVE_NOTIFICATION @"aNotification"
#define     KEY_IF_FIRST_TIME_LOGIN @"aValue"

#define    BACK_TO_MAIN 999

//view dimensions
#define    TOOLBAR_HEIGHT 44.0
#define    LOCATIONBAR_HEIGHT 21.0
#define    FOOTER_HEIGHT ((TOOLBAR_HEIGHT) + (LOCATIONBAR_HEIGHT))
//#define    TABLE_WIDTH_SCALE 2.0f/3.0f
//#define    TABLE_ROW_HEIGHT 70

#define PORTRAIT_IPAD_WIDTH 768
#define TOP_STORY_IMAGE_SIZE 250
#define TOP_STORY_PADDING_TOP 20
#define TOP_STORY_PADDING_LEFT 10





#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#define IF_IOS7_OR_GREATER(...) \
if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1) \
{ \
__VA_ARGS__ \
}
#else
#define IF_IOS7_OR_GREATER(...)
#endif



#endif
