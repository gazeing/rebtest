//
//  PPViewController.m
//  PPImageScrollingTableViewControllerDemo
//
//  Created by popochess on 13/8/9.
//  Copyright (c) 2013年 popochess. All rights reserved.
//

#import "PPViewController.h"
#import "PPImageScrollingTableViewCell.h"



#import "AppDelegate.h"
#import "AFNetworking.h"
#import "Reachability.h"
#import "Article.h"
#import "ArticleCategory.h"

#import "RighMenuViewController.h"
#import "LeftMenuViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TopStoryView.h"
#import "WelcomeViewController.h"

@import GoogleMobileAds;



//@class WIPBrowserViewController;
//@class RighMenuViewController;
//@class LeftMenuViewController;



@interface PPViewController()<PPImageScrollingTableViewCellDelegate,JsonDownloaderDelegate>


@property (strong, nonatomic) NSMutableArray* categoryList;
@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) BrowserViewController *wipViewController;
@property (strong, nonatomic) TopStoryView *headerView;

@property (strong, nonatomic) DFPBannerView *bannerView;

@property (strong, nonatomic) Article *firstArticle;



@end

@implementation PPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    list = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).list;
    
    self.title = @"Main";
    [self addTitleBarItems];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    static NSString *CellIdentifier = @"Cell";
    [self.tableView registerClass:[PPImageScrollingTableViewCell class] forCellReuseIdentifier:CellIdentifier];

    
    self.categoryList = [[NSMutableArray alloc] initWithCapacity:6];

    jsonDownloader = [[JsonDownloader alloc] initWithList:list];
    jsonDownloader.delegate = self;
    
    [self loadArticleList];
    
    [self initWebview];
    

    [self initHeadView];
    
    
    [self initAdBannerView];


}


- (void) initAdBannerView
{
//    GADAdSize customAdSize = GADAdSizeFromCGSize(CGSizeMake(728, 90));
    NSLog(@"Google Mobile Ads SDK version: %@", [DFPRequest sdkVersion]);


    self.bannerView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    
    
    
    self.bannerView.adUnitID = @"/50807330/RPM_RECD_Leaderboard_728x90";
    self.bannerView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    
    [self.bannerView loadRequest:request];

    //
//    GADAdSize customAdSize = GADAdSizeFromCGSize(CGSizeMake(728, 90));
//    self.bannerView.adSize = customAdSize;
    
    
    [self reloadAdBannerView : YES];
    
    
}

- (void) reloadAdBannerView : (Boolean)isPortrait
{
    

    self.bannerView.adSize =isPortrait?kGADAdSizeSmartBannerPortrait:kGADAdSizeSmartBannerLandscape;

    
    self.tableView.tableFooterView = self.bannerView;
    
}

- (void) initHeadView
{

    self.headerView = [[TopStoryView alloc] init];
    
   
    self.tableView.tableHeaderView = self.headerView; //test
   
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.headerView addGestureRecognizer:singleFingerTap];
}

- (void)addImageViewIfPortraitIpad
{
    UIInterfaceOrientation orientation=[UIApplication sharedApplication].statusBarOrientation;
    if (IS_IPAD) {
        if (UIInterfaceOrientationIsPortrait(orientation)){

             self.tableView.tableHeaderView = self.headerView;

            [self reloadAdBannerView:YES];
        }
        
        else
        {
            self.tableView.tableHeaderView = nil;
            [self reloadAdBannerView:NO];
        }

    }else
        self.tableView.tableHeaderView = nil;
    
    
    

}


- (void)viewDidAppear:(BOOL)animated
{

    [[[UIApplication sharedApplication] keyWindow] setBackgroundColor:[UIColor whiteColor]];
    [self addImageViewIfPortraitIpad];
}

- (void)viewWillAppear:(BOOL)animated
{


    NSString* currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    //detect if it is the first login, if yes show the welcome screen
    if (![currentVersion isEqualToString:[[NSUserDefaults standardUserDefaults]
                                objectForKey:KEY_IF_FIRST_TIME_LOGIN]]) {
        [[NSUserDefaults standardUserDefaults] setValue:currentVersion forKey:KEY_IF_FIRST_TIME_LOGIN];
        [[NSUserDefaults standardUserDefaults] synchronize];
//    if(1)
//    {
    
        WelcomeViewController *welcomeViews = [[WelcomeViewController alloc] initWithImageCount:4];
    
//    UINavigationController* navigationController =[[UINavigationController alloc] initWithRootViewController:[[WelcomeViewController alloc] initWithImageCount:4]];
    
        CATransition* transition = [CATransition animation];
        transition.duration = .2;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        [self.view.window.layer addAnimation:transition forKey:kCATransition];
        
        
        
        [self presentViewController:welcomeViews animated:NO completion:nil];
        
        
        
    }
    
    [super viewWillAppear:animated];
    

}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
//    [self.tableView reloadData];
    
    [self addImageViewIfPortraitIpad];
    
    
    if (list.count >0) {
        ArticleCategory* category = [list objectAtIndex:0];
        if (category.articleList.count>0) {
        
            if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
                if(self.firstArticle.link == ((Article*)[category.articleList objectAtIndex:0]).link)
                {
                    [category.articleList removeObjectAtIndex:0];
                }
            }else if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft )|| (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight))
            {
                if(self.firstArticle.link != ((Article*)[category.articleList objectAtIndex:0]).link)
                {
                    [category.articleList insertObject:self.firstArticle atIndex:0];
                }

            }
        }
    }
    
    [self.tableView reloadData];
    
    

}

- (void)initWebview
{
    NSString *userAgent = [self getAppUA];
    NSString *userAgentPre = [self getAppUA];
    self.wipViewController = [[BrowserViewController alloc] initWithUserAgent:userAgent prevUserAgent:userAgentPre];
    
    NSString *preload_link = HOMEPAGE_URL;
    if (self.firstArticle != NULL) {
        
        if (self.firstArticle.link != NULL) {
            preload_link = self.firstArticle.link;
        }
    }
    [self.wipViewController navigateTo:[NSURL URLWithString:preload_link]];
    
    
}

- (void) showUrlInContentView : (NSString *) url
{
    if (self.wipViewController != NULL) {
        [self openWebView:url];
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


#pragma mark -
#pragma mark  Load article list

-(void)loadArticleList
{
    [list removeAllObjects];
    [self.categoryList removeAllObjects];
    [self.categoryList addObjectsFromArray: @[@{@"id":@"17",@"name":@"NEWS"},
                                              @{@"id":@"51",@"name":@"FEATURES"},
                                              @{@"id":@"21",@"name":@"BLOGS"},
                                              @{@"id":@"48",@"name":@"VIDEO"}
                                              ]];
    
//    [self loadNextCategory];
    [jsonDownloader loadArticleList:self.categoryList];

    
    
}

- (void)onDownloadFinished:(NSMutableArray* ) outList
{
    NSLog(@"onDownloadFinished:=======================================================");
    list = outList;
    [self fillData];

    
   
    

}

- (void) fillData
{
    
    [self fillHeadView];
    
    [self.tableView reloadData];
}

- (void) fillHeadView
{
    if (list.count >0) {
        ArticleCategory* category = [list objectAtIndex:0];
        if (category.articleList.count>0) {
            Article* article = [category.articleList objectAtIndex:0];
            self.firstArticle = article;
            NSString *firstlink = article.link;
            [self.wipViewController navigateTo:[NSURL URLWithString:firstlink]];
            
            [self.headerView fillWithFirstArticle:article];
            
            
            [self.tableView setTableHeaderView:self.headerView];
            

            
            
            UIInterfaceOrientation orientation=[UIApplication sharedApplication].statusBarOrientation;
            if (IS_IPAD) {
                if (UIInterfaceOrientationIsPortrait(orientation)){
                
                    [category.articleList removeObjectAtIndex:0];
                }else{
                    self.tableView.tableHeaderView = nil;
                }
                
            }else
                self.tableView.tableHeaderView = nil;

            
            
        }
    }
}



//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
//    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    if (self.firstArticle != NULL) {
        
        if (self.firstArticle.link != NULL) {
            
//            NSString *firstlink = self.firstArticle.link;
            [self openWebView:self.firstArticle];
        }
    }
}



#pragma mark -
#pragma mark  UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    return [self.images count];
    
   
    return [list count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
//    NSDictionary *cellData = [self.images objectAtIndex:[indexPath section]];
    ArticleCategory* category = [list objectAtIndex:[indexPath section]];
    PPImageScrollingTableViewCell *customCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [customCell setBackgroundColor:[UIColor whiteColor]];
    [customCell setDelegate:self];
//    [customCell setImageData:cellData];
    [customCell setArticleCategory:category];
//    [customCell setCategoryLabelText:[cellData objectForKey:@"category"] withColor:[UIColor darkGrayColor]];
    [customCell setCategoryLabelText:category.catName withColor:[UIColor darkGrayColor]];
    [customCell setTag:[indexPath section]];
    [customCell setImageTitleTextColor:[UIColor whiteColor] withBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    [customCell setImageTitleLabelWitdh:190 withHeight:45];
    [customCell setCollectionViewBackgroundColor:[UIColor whiteColor]];
 
    return customCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 250;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PPImageScrollingTableViewCellDelegate

- (void)scrollingTableViewCell:(PPImageScrollingTableViewCell *)scrollingTableViewCell didSelectImageAtIndexPath:(NSIndexPath*)indexPathOfImage atCategoryRowIndex:(NSInteger)categoryRowIndex
{


    NSInteger num = [indexPathOfImage row];
    ArticleCategory* ar = (ArticleCategory*)[list objectAtIndex:categoryRowIndex];
    Article* a = [ar.articleList objectAtIndex:num];
//    NSString* link = a.link;
    

    [self openWebView:a];
    


}

- (void) openWebView:(Article *) a
{
//    WIPBrowserViewController* nextController = [[WIPBrowserViewController alloc] init];
//    
//    
//    [nextController navigateToFromClearPage:[NSURL URLWithString:link]];
//     [self.wipViewController navigateToFromClearPage:[NSURL URLWithString:link]];
    
    [self.wipViewController navigationToTestPage:a];
//    CATransition* transition = [CATransition animation];
//    transition.duration = .2;
//    transition.type = kCATransitionPush;
//    transition.subtype = kCATransitionFromRight;
//    [self.view.window.layer addAnimation:transition forKey:kCATransition];
//    NSLog(@"self.navigationController=%@", self.navigationController);
    
     [(UINavigationController*)self.navigationController pushViewController:self.wipViewController  animated:YES];
    
//    [self presentViewController:self.sideMenuViewController animated:NO completion:nil];

}

#pragma mark - Navigation Bar
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void)addTitleBarItems
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    self.title = INITIAL_NAVIGATION_BAR_TITLE;
    UIImage *imgMenu = [UIImage imageNamed:@"IconMenu"];

   UIImage *imgEmpty = [UIImage imageNamed:@"IconEmpty"];
    

    
    UIBarButtonItem *emptyItem = [[UIBarButtonItem alloc] initWithImage:imgEmpty
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self action:nil];
    

    
    
    
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithImage:imgMenu
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(mainMenu:)];
    NSArray *leftactionButtonItems = @[ emptyItem,emptyItem];
    
//    self.navigationItem.leftBarButtonItems = leftactionButtonItems;
    
    NSArray *rightactionButtonItems = @[ emptyItem,emptyItem];
    
//    self.navigationItem.rightBarButtonItems = rightactionButtonItems;
    

    
    
    NSString *logo = IsIPad()?@"Logo-40":@"Logo-40-slim";
    NSString *logosmall = IsIPad()?@"Logo-small":@"Logo-small-slim";
    
    UIButton *titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [titleLabel setImage:[UIImage imageNamed:logo] forState:UIControlStateNormal];
    [titleLabel setImage:[UIImage imageNamed:logosmall] forState:UIControlStateHighlighted];
    

    titleLabel.frame = CGRectMake(100, 0, 200, 80);
    titleLabel.titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    titleLabel.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    
    [titleLabel addTarget:self action:@selector(backToHomePage:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleLabel;
    self.navigationItem.titleView.frame = CGRectMake(100, 0, 200, 80);
    
    
}
#pragma clang diagnostic pop

- (IBAction)backToHomePage:(id)sender
{
    
    [self loadArticleList];
    
}

- (IBAction)mainMenu:(id)sender
{
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    [self.tableView reloadData];
}

@end
