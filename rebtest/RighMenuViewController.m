//
//  RighMenuViewController.m
//  HybridWebView
//
//  Created by Steven Xu on 15/07/2014.
//  Copyright (c) 2014 Sterling Publishing. All rights reserved.
//

//#define IsIPad() ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad))


#define TABLE_WIDTH_SCALE 2.0f/3.0f
#define TABLE_ROW_HEIGHT 70

#import "Constants.h"
#import "RighMenuViewController.h"
#import "SocialShareCell.h"
#import "BrowserViewController.h"

@interface RighMenuViewController (){
    NSMutableArray *TitleArray;
    NSMutableArray *IconArray;
    int tableCount;
}


@property (strong, readwrite, nonatomic) UITableView *tableView;




@end

@implementation RighMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.title = @"Share";
    
    
    if(!TitleArray){
        if (IsIPad()) {
            TitleArray = [[NSMutableArray alloc] initWithArray:@[@"Facebook",  @"Twitter", @"Mail", @"Google+", @"Linkedin"]];
        } else {
            TitleArray = [[NSMutableArray alloc] initWithArray:@[@"Facebook",  @"Twitter", @"Mail", @"Google+", @"WhatsApp", @"Linkedin"]];
        }
//        TitleArray = [[NSMutableArray alloc] initWithArray:@[@"Facebook",  @"Twitter", @"Mail", @"Google+", @"WhatsApp", @"Linkedin"]];
    }
    
    if(!IconArray){
        if (IsIPad()) {
            IconArray = [[NSMutableArray alloc] initWithArray:@[@"IconFacebook",  @"IconTwitter", @"IconMail", @"IconGooglePlus", @"IconLinkedIn"]];
            
        } else{
            IconArray = [[NSMutableArray alloc] initWithArray:@[@"IconFacebook",  @"IconTwitter", @"IconMail", @"IconGooglePlus", @"IconWhatApp", @"IconLinkedIn"]];
            
        }
        
        tableCount = IconArray.count;
        
//        IconArray = [[NSMutableArray alloc] initWithArray:@[@"IconFacebook",  @"IconTwitter", @"IconMail", @"IconGooglePlus", @"IconWhatApp", @"IconLinkedIn"]];
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
}

-(CGRect)getTableViewRect
{
    
    return CGRectMake(0, (self.view.frame.size.height - TABLE_ROW_HEIGHT * tableCount) / 2.0f, self.view.frame.size.width, TABLE_ROW_HEIGHT * tableCount);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *navController = self.sideMenuViewController.contentViewController;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (navController.viewControllers.count >=2 ) {
        UIViewController *root = navController.viewControllers[1];
        [((BrowserViewController*)root) shareFromSideMenu:[TitleArray objectAtIndex:indexPath.row]];
    }
    [self.sideMenuViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_ROW_HEIGHT;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{

    return tableCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    NSLog(@"begin: %@",@"(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath");
    
    
    static NSString *cellIdentifier = @"SocialShareCell";
    
    SocialShareCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[SocialShareCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:IsIPad()?21:18];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    

        cell.textLabel.text = [TitleArray objectAtIndex:indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentRight;
        cell.imageView.image =[UIImage imageNamed:[IconArray objectAtIndex:indexPath.row]];
        
 
    
    
    
    return cell;
}

@end
