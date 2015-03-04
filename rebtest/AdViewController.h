//
//  AdViewController.h
//  HybridWebView
//
//  Created by Steven Xu on 8/08/2014.
//  Copyright (c) 2014 Sterling Publishing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView* webView;

@end
