//
//  RPMSideMenu.m
//  RPM
//
//  Created by Steven Xu on 26/08/2014.
//  Copyright (c) 2014 Sterling Publishing. All rights reserved.
//

#import "SPSideMenu.h"

@interface SPSideMenu ()

@end

@implementation SPSideMenu : RESideMenu

- (id)init
{
    self = [super init];

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];

    return self;
}

- (UIViewController *)getContentViewController{
    return self.contentViewController;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//#pragma mark -
//#pragma mark Pan gesture recognizer (Private)
//
//- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
//{
// 
//    //override the original one
//}

@end
