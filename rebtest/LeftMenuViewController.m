//
//  DEMOMenuViewController.m
//  RESideMenuExample
//
//  Created by Roman Efimov on 10/10/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "Constants.h"
#import "LeftMenuViewController.h"
#import "BrowserViewController.h"
#import "AFNetworking.h"
#import "NavItem.h"
#import "NavGroupItem.h"


//#define BACK_TO_MAIN 999
//#define TABLE_WIDTH_SCALE 1.0f/2.0f
//#define TABLE_ROW_HEIGHT 60


@interface LeftMenuViewController (){

    NSMutableArray *NavItemArray;
    NSMutableArray *NavChildItemArray;
    id defaulJson;
    CGFloat TABLE_WIDTH_SCALE;
    CGFloat TABLE_ROW_HEIGHT;
    CGFloat TABLE_SECTION_HEIGHT;
    BOOL isIpad;
    
    NSUInteger mTableViewItemCount;
    NSUInteger mChildTableViewItemCount;
}
@property (strong, readwrite, nonatomic) UITableView *tableView;
@property (strong, readwrite, nonatomic) UITableView *childTableView;
@property (strong, readwrite, nonatomic) UISwitch *switchview;


@end



@implementation LeftMenuViewController


-(void) initConstrants
{
    
    isIpad = IsIPad();
    TABLE_WIDTH_SCALE =isIpad?1.0f/2.0f:2.0f/3;
    TABLE_ROW_HEIGHT = isIpad?60:40;
    TABLE_SECTION_HEIGHT = isIpad?TABLE_ROW_HEIGHT/2:TABLE_ROW_HEIGHT;
    
    mTableViewItemCount = 3;
    mChildTableViewItemCount = 2;;
    
}

-(void) RecalculateTableViewItemCount
{
    mTableViewItemCount = NavItemArray.count + 2;
    for (int i =0; i<NavItemArray.count; i++) {
        if (((NavGroupItem* )[NavItemArray objectAtIndex:i]).childItems.count+2>mChildTableViewItemCount) {
            mChildTableViewItemCount = ((NavGroupItem* )[NavItemArray objectAtIndex:i]).childItems.count+2;
        }
    }
//    mChildTableViewItemCount += 2;
    
}

-(void)loadJsonFromNetwork
{
    
    
    
    NSLog(@"loadJsonFromNetwork: %@",@"[self parseNavItems:defaulJson];");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:MENU_JSON_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);

    [self parseAndRefreshTable:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [self loadLocalJson];
    }];
}
-(void)loadLocalJson
{
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"side_menu" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    [self parseAndRefreshTable:json];

}

-(void)parseAndRefreshTable:(id)json
{
    [self parseNavItems:json];
    [self RecalculateTableViewItemCount];
    [self.tableView reloadData];
    [self ResizeTableViews];
}

-(void)loadDefaultJson
{
    NavGroupItem* item = [NavGroupItem new];
    item.itemId = 0;
    item.title = @"Home";
    item.url = @"/app";
    item.iconPath=@"IconHome";
    
    [NavItemArray addObject:item];
}

-(void)parseNavItems:(id)json
{
    
    [NavItemArray removeAllObjects];
    
    NSDictionary *jsonDict = (NSDictionary *) json;
    NSArray *array = [jsonDict objectForKey:@"array"];
    [array enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
        NSString *title = [obj objectForKey:@"Title"];
        NSString *url = [obj objectForKey:@"Url"];
        NSInteger itemid = [[obj objectForKey:@"id"] integerValue];
        
//        NSLog(@"title: %@ url: %@ itemid: %ld", title,url,(long)itemid);
        
        NavGroupItem* item = [NavGroupItem new];
        item.itemId = itemid;
        item.title = title;
        item.url = url;
        if ([title isEqual:@"Home"]) {
            item.iconPath=@"IconHome";
        }else
            item.iconPath=@"IconEmpty";
        
        NSArray *responseKeys = [obj allKeys];
        
        if ([responseKeys containsObject:@"child"]) {
            NSMutableArray *NavChildItemArray;
            NavChildItemArray = [[NSMutableArray alloc] initWithCapacity:15];
            NSArray *child = [obj objectForKey:@"child"];
            
            [child enumerateObjectsUsingBlock:^(id childobj,NSUInteger childidx, BOOL *childstop){
                NSString *childtitle = [childobj objectForKey:@"Title"];
                NSString *childurl = [childobj objectForKey:@"Url"];
                NSInteger childitemid = [[childobj objectForKey:@"id"] integerValue];
                
                //        NSLog(@"title: %@ url: %@ itemid: %ld", title,url,(long)itemid);
                
                NavItem* childitem = [NavItem new];
                childitem.itemId = childitemid;
                childitem.title = childtitle;
                childitem.url = childurl;
                if ([childtitle isEqual:@"Home"]) {
                    childitem.iconPath=@"IconHome";
                }else
                    childitem.iconPath=@"IconEmpty";
                [NavChildItemArray addObject:childitem];
            }];
            
            item.childItems =NavChildItemArray;
        }
        
        [NavItemArray addObject:item];
        

    }];
    
}


- (void)viewDidLoad
{
//    NSLog(@"title from array: %@",@"viewDidLoad");
    
    [self initConstrants];
    
    [super viewDidLoad];
    if (NavItemArray==NULL) {
        NSLog(@"title from array: %@",@"loadJsonFromNetwork");
        NavItemArray = [[NSMutableArray alloc] initWithCapacity:40];
        //        //get Default
        [self loadDefaultJson];
        [self loadJsonFromNetwork];
    }
    if (NavChildItemArray==NULL) {
        NavChildItemArray = [[NSMutableArray alloc] initWithCapacity:20];
    }
    
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:[self getTableViewRect] style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
         tableView.scrollEnabled = YES;
        tableView;
    });
    [self.view addSubview:self.tableView];

    //create a blank child tab view for sub menu
    self.childTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:[self getChildTableViewHideRect] style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView.scrollEnabled = YES;
        tableView;
    });
//    [self.view addSubview:self.childTableView];
//    NSLog(@"childTableView.center (w,h) = (%f,%f)",self.childTableView.center.x,self.childTableView.center.y);
}

-(CGRect)getTableViewRect
{

    CGFloat screenWidth = [self getScreenWidthOfOrientation];
    CGFloat screenHeight = [self getScreenHeightOfOrientation];
//    BOOL isTableHigherThanScreen = (TABLE_ROW_HEIGHT * 10>screenHeight-TABLE_ROW_HEIGHT);
    
//    NSLog(@"getTableViewRect.width = %f",screenWidth*TABLE_WIDTH_SCALE);
     CGRect tvRect = CGRectMake(0, (!isIpad)?TABLE_ROW_HEIGHT/2.0f:(screenHeight - TABLE_ROW_HEIGHT * mTableViewItemCount) / 2.0f, screenWidth*TABLE_WIDTH_SCALE, (!isIpad)?screenHeight-TABLE_ROW_HEIGHT:TABLE_ROW_HEIGHT * mTableViewItemCount);
//    NSLog(@"screen width = %f, height = %f",screenWidth,screenHeight);
//    NSLog(@"table view = %f,%f,%f,%f",tvRect.origin.x,tvRect.origin.y,tvRect.size.width,tvRect.size.height);
    return tvRect;
}
-(CGRect)getChildTableViewHideRect
{
    
    CGFloat screenWidth = [self getScreenWidthOfOrientation];
    CGFloat screenHeight = [self getScreenHeightOfOrientation];
    BOOL isTableHigherThanScreen = (TABLE_ROW_HEIGHT*mTableViewItemCount>screenHeight-TABLE_ROW_HEIGHT);
    return CGRectMake(0, screenHeight + TABLE_ROW_HEIGHT, screenWidth*TABLE_WIDTH_SCALE, isTableHigherThanScreen?screenHeight-TABLE_ROW_HEIGHT:TABLE_ROW_HEIGHT * mChildTableViewItemCount);
}
-(CGRect)getChildTableViewRect
{
    CGFloat screenWidth = [self getScreenWidthOfOrientation];
    CGFloat screenHeight = [self getScreenHeightOfOrientation];
    BOOL isTableHigherThanScreen = (TABLE_ROW_HEIGHT*mTableViewItemCount>screenHeight-TABLE_ROW_HEIGHT);
    return CGRectMake(0, isTableHigherThanScreen?TABLE_ROW_HEIGHT/2.0f:(screenHeight - TABLE_ROW_HEIGHT * mChildTableViewItemCount) / 2.0f, screenWidth*TABLE_WIDTH_SCALE, isTableHigherThanScreen?screenHeight-TABLE_ROW_HEIGHT:TABLE_ROW_HEIGHT * mChildTableViewItemCount);
}


-(CGFloat) getScreenWidthOfOrientation
{
  
//    return 1024.0f;
    return self.view.frame.size.width;
//    return screenRect.size.height;
//      CGRect screenRect = [[UIScreen mainScreen] bounds];
//    return UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation) ? screenRect.size.height:screenRect.size.width;
}

-(CGFloat) getScreenHeightOfOrientation
{
        //    return 1024.0f;
    return self.view.frame.size.height;
    //    return screenRect.size.height;
//    CGRect screenRect = [[UIScreen mainScreen] bounds];

//    return UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation) ? screenRect.size.width:screenRect.size.height;
}



//animation that tabview fly out, childview fly in
-(void) childViewTransform :(NSUInteger)index
{
    NavChildItemArray = [NSMutableArray arrayWithArray:((NavGroupItem*)[NavItemArray objectAtIndex:index]).childItems];
    
    //add the parent item to top and change icon to settings
    [NavChildItemArray insertObject:[NavItemArray objectAtIndex:index] atIndex:0];
    ((NavItem*)[NavChildItemArray objectAtIndex:0]).iconPath = @"IconStar";
    
    //add close item to bottom and change icon to home
    NavItem* item = [NavItem new];
    item.itemId = BACK_TO_MAIN;
    item.title = @"Main Menu";
    item.url = @"";
    item.iconPath=@"IconBack-white";
    [NavChildItemArray addObject:item];
        
    [self.childTableView reloadData];
    
    // set offscreen position same way as above
    CGFloat windowWidth = self.view.frame.size.width*TABLE_WIDTH_SCALE;
//    CGFloat windowWidth = self.view.frame.size.width;
    CGFloat windowHeight = self.view.frame.size.height;
  
    CGPoint offScreenBelow = CGPointMake(windowWidth/2, 0 - (windowHeight/2)-TABLE_ROW_HEIGHT);
//    CGPoint onScreen = CGPointMake(windowWidth/2,windowHeight/2);
//    CGPoint onScreen = CGPointMake(256,512);

    
//    NSLog(@"frame=%@ transform=%@", NSStringFromCGRect(self.view.frame), NSStringFromCGAffineTransform(self.view.transform));

    float duration = 0.5;
    
    // myCustomSubview is on screen already. time to animate it off screen
    [UIView animateWithDuration:duration // remember you can change this for animation speed
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.view addSubview:self.childTableView];
//                         self.childTableView.center = onScreen;
                         [self.childTableView setFrame:[self getChildTableViewRect]];
//                         NSLog(@"childTableView onScreen (w,h) = (%f,%f)",onScreen.x,onScreen.y);
                         self.tableView.center = offScreenBelow;
                         
                         
                     }
                     completion:^(BOOL finished){
                         [self.tableView removeFromSuperview];
                     }];
//    [self.tableView removeFromSuperview];
}
//animation that bring back the main tabview
-(void) childViewTransformBack
{
    // set offscreen position same way as above
    CGFloat windowWidth = self.view.frame.size.width*TABLE_WIDTH_SCALE;
//    CGFloat windowWidth = self.view.frame.size.width;
    CGFloat windowHeight = self.view.frame.size.height;
    CGPoint offScreenBelow = CGPointMake(windowWidth/2, windowHeight + (windowHeight/2)+TABLE_ROW_HEIGHT);
//    CGPoint onScreen = CGPointMake(windowWidth/2,windowHeight/2);
//    CGPoint onScreen = CGPointMake(256,512);
    float duration = 0.5;
    
    // myCustomSubview is on screen already. time to animate it off screen
    [UIView animateWithDuration:duration // remember you can change this for animation speed
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.view addSubview:self.tableView];
//                         self.tableView.center = onScreen;
                         [self.tableView setFrame:[self getTableViewRect]];
//                         NSLog(@"tableView onScreen (w,h) = (%f,%f)",onScreen.x,onScreen.y);
                         self.childTableView.center = offScreenBelow;
                         
                        
                     }
                     completion:^(BOOL finished){
                         [self.childTableView removeFromSuperview];

                     }];
}


#pragma mark -
#pragma mark View Controller Rotation handler

- (BOOL)shouldAutorotate
{
    return self.shouldAutorotate;
}

- (void)ResizeTableViews
{
    if (self.tableView.center.y > 0) {
        [self.tableView setFrame:[self getTableViewRect]];
    }
    if (self.childTableView.center.y < self.view.frame.size.height) {
        [self.childTableView setFrame:[self getChildTableViewRect]];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

//    if ([self.sideMenuViewController getleftMenuVisible]) {

    [self ResizeTableViews];
//    }

    
    
    
}


#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
//unselect the item
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  // if it belongs to notification section, do nothing.
    if ((indexPath.section ==0) && (tableView == self.tableView)){
        return;
    }
    
    UINavigationController *navController = ((SPSideMenu* )(self.sideMenuViewController)).getContentViewController;

    
    
    NSString* fullUrl = BASE_URL;
    
    //if it is a main table item, and it has child   ===> show the child memu
    if ((tableView == self.tableView)
        &&(((NavGroupItem*)[NavItemArray objectAtIndex:indexPath.row]).childItems.count>0) ){
        [self childViewTransform : indexPath.row];

    } else {
        
        // else go to the page, close left menu
        
        if (tableView==self.childTableView) {
            if(((NavItem*)[NavChildItemArray objectAtIndex:indexPath.row]).itemId == BACK_TO_MAIN)
            {
                [self childViewTransformBack];
                return;
                
            }else{
                fullUrl = [fullUrl stringByAppendingString:((NavItem*)[NavChildItemArray objectAtIndex:indexPath.row]).url];
                [self childViewTransformBack];
            }
            
        }else{
            fullUrl = [fullUrl stringByAppendingString:((NavItem*)[NavItemArray objectAtIndex:indexPath.row]).url];
        }
        
        
        if (navController.viewControllers.count >=2 ) {
            UIViewController *root = navController.viewControllers[1];
            [((BrowserViewController*)root) navigateTo:[NSURL URLWithString:fullUrl]];
        }
        
       
        
        [self.sideMenuViewController hideMenuViewController];
    }
    

    
   
    
    
    
//    switch (indexPath.row) {
//        case 0:
////            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[RebBrowserViewController alloc] initWithUserAgent:userAgent prevUserAgent:userAgentPre]] animated:YES];
////            [self.sideMenuViewController get]
//            
//            
//            [((RebBrowserViewController*)root) navigateTo:[NSURL URLWithString:@"http://www.rebonline.com.au/app"]];
//            
//            [self.sideMenuViewController hideMenuViewController];
//            break;
//        case 1:
////            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[RebViewController alloc] init]]
////                                                         animated:YES];
//            [self.sideMenuViewController hideMenuViewController];
//            break;
//        default:
//            break;
//    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_ROW_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.childTableView) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (tableView == self.childTableView) {
        return NavChildItemArray.count;
    }
//    NSLog(@"begin: %@ = %lu",@"return NavItemArray.count;",(unsigned long)NavItemArray.count);
    return (sectionIndex==1)?NavItemArray.count:1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.childTableView) {
        return 0.01f; //0 cannot work
    }
    
    return TABLE_SECTION_HEIGHT;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.childTableView) {
        return Nil;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(5, 0,  tableView.bounds.size.width-5, 30)];
    
    UILabel *labelHeader = [[UILabel alloc] initWithFrame:CGRectMake (5,0,320,30)];
    labelHeader.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    labelHeader.textColor = [UIColor whiteColor];
    [headerView addSubview:labelHeader];
    
    CALayer *bottomBorder = [CALayer layer];
    
    bottomBorder.frame = CGRectMake(2.0f, 31.0f, tableView.frame.size.width>tableView.frame.size.height?tableView.frame.size.width:tableView.frame.size.height, 1.0f);
    
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                     alpha:1.0f].CGColor;
    [headerView.layer addSublayer:bottomBorder];
                            
    if (section == 0)
    {
        [headerView setBackgroundColor:[UIColor clearColor]];
        labelHeader.text = @"Settings";
    }
    else if (section == 1)
    {
                                
        [headerView setBackgroundColor:[UIColor clearColor]];
        labelHeader.text = @"Sections";
    }
    
    
    return headerView;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

//    NSLog(@"begin: %@",@"(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath");
    
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:isIpad?21:16];
  
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];


    }
    
    if (tableView==self.childTableView) {
        cell.textLabel.text = ((NavItem*)[NavChildItemArray objectAtIndex:indexPath.row]).title;
        cell.imageView.image =[UIImage imageNamed:((NavItem*)[NavChildItemArray objectAtIndex:indexPath.row]).iconPath];
        cell.accessoryView = nil;
    } else if (tableView==self.tableView){
        if (indexPath.section == 1) {

                cell.textLabel.text = ((NavGroupItem*)[NavItemArray objectAtIndex:indexPath.row]).title;
//             NSLog(@"%@,%d",cell.textLabel.text ,indexPath.row);
                cell.imageView.image =[UIImage imageNamed:((NavGroupItem*)[NavItemArray objectAtIndex:indexPath.row]).iconPath];
                cell.accessoryView = nil;
        
        } else if(indexPath.section == 0){
           
            cell.textLabel.text = TEXT_NEWS_ALERT;
            cell.imageView.image = [UIImage imageNamed:@"IconNews"];
// NSLog(@"%@,%d,%d",cell.textLabel.text ,indexPath.section,indexPath.row);
            //add a switch
            
                
                self.switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
                cell.accessoryView = self.switchview;
                
                [self.switchview addTarget:self action:@selector(updateSwitch) forControlEvents:UIControlEventTouchUpInside];
            
            if ([@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                       objectForKey:KEY_IF_RECEIVE_NOTIFICATION]])
            {
                [self.switchview setOn:YES];
            }
            

        
        }
    }

    
    return cell;
}

- (void)updateSwitch
{
    NSLog(@"switch be click %d",self.switchview.isOn);
    [[NSUserDefaults standardUserDefaults] setValue:self.switchview.isOn?@"1":@"0" forKey:KEY_IF_RECEIVE_NOTIFICATION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
