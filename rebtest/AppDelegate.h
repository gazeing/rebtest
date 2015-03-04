//
//  AppDelegate.h
//  id
//
//  Created by Steven Xu on 27/02/2015.
//  Copyright (c) 2015 Sterling Publishing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPSideMenu.h"
#import "Constants.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,RESideMenuDelegate,UIAlertViewDelegate>
{
    NSMutableArray* list;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableArray* list;
@property (strong, nonatomic) SPSideMenu *sideMenuViewController;

-(NSString*)getAppUA;


@end

