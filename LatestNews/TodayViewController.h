//
//  TodayViewController.h
//  BreakingNews
//
//  Created by Steven Xu on 23/09/2014.
//  Copyright (c) 2014 Sterling Publishing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSURLSessionDelegate>
{
    NSMutableArray* m_LoadingQueue;
    NSMutableArray* m_TitleQueue;
    NSMutableString* m_currentLoadUrl;
    NSString *jsonUrl;
}
//@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
