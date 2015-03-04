//
//  NavItem.h
//  HybridWebView
//
//  Created by Steven Xu on 11/07/2014.
//  Copyright (c) 2014 Sterling Publishing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavItem : NSObject

@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* iconPath;
@property (assign, nonatomic) NSUInteger itemId;

@end
