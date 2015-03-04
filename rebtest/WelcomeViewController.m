//
//  WelcomeViewController.m
//  RPM
//
//  Created by Steven Xu on 12/02/2015.
//  Copyright (c) 2015 Sterling Publishing. All rights reserved.
//

#import "WelcomeViewController.h"
#import "Constants.h"

@interface WelcomeViewController ()
{
    NSInteger imagesCount;;
}


@property (strong, nonatomic) NSMutableArray    *m_ImageArray;
@property (nonatomic, retain) UIScrollView      *scrollView;
@property (nonatomic, retain) UIPageControl     *pageControl;
@property (nonatomic, retain) UIButton          *finshButton;
@property (nonatomic, retain) UILabel           *versionLabel;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    self.m_ImageArray = [[NSMutableArray alloc] init];
    for (int i = 0; i<imagesCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth * i, 0, screenWidth, screenHeight)];
        UIImage *showImage = [self getWelcomeImage:i+1];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.image = (showImage!=NULL)?showImage:[UIImage imageNamed:@"MenuBackground"];
        
        [self.m_ImageArray addObject:imageView];
    }
    
    [self showWelcomeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithImageCount:(NSInteger )count
{
    self = [super init];
    if (self != nil) {
        
        imagesCount = count;
     
    }
    
    return self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    if (IsAtLeastiOSVersion(@"7.0")) {
        [[UIApplication sharedApplication] setStatusBarStyle:[self preferredStatusBarStyle]];
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChangeNotification:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    [super viewWillAppear:animated];
    
    
}


- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{
    
    [self resizeWelcomePage];
    
    
}

#pragma mark - WelcomeView Logic

- (void) showWelcomeView
{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
//    UIScreen *mainScreen = [UIScreen mainScreen];
    
    NSUInteger count =  self.m_ImageArray.count;
    
    
    CGRect scrollViewFrame = CGRectMake(0, 0, screenWidth, screenHeight);
    self.scrollView= [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    CGSize scrollViewContentSize = CGSizeMake(screenWidth * count, screenHeight);
    [self.scrollView setContentSize:scrollViewContentSize];
    
    


    
    self.finshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.finshButton setTitle:@"Get started" forState:UIControlStateNormal];
    self.finshButton.backgroundColor = [UIColor whiteColor];
   
    self.finshButton.frame = CGRectMake(screenWidth/2-70, (screenHeight*2)/3, 140, 60);
    self.finshButton.layer.cornerRadius = 10; // this value vary as per your desire
    self.finshButton.clipsToBounds = YES;
    
    self.finshButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    
    
    [self.finshButton addTarget:self action:@selector(finishWelcomePage:) forControlEvents:UIControlEventTouchUpInside];
    
    
     NSString* currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2-50, (screenHeight*2)/3+80, 100, 40)];
    self.versionLabel.text = currentVersion;
    self.versionLabel.font = [UIFont boldSystemFontOfSize:12.0];
    self.versionLabel.numberOfLines = 1;
    self.versionLabel.baselineAdjustment = YES;
    self.versionLabel.adjustsFontSizeToFitWidth = YES;
    

    
    self.versionLabel.clipsToBounds = YES;
    self.versionLabel.backgroundColor = [UIColor clearColor];
    self.versionLabel.textColor = [UIColor whiteColor];
    self.versionLabel.textAlignment = NSTextAlignmentCenter;
    
    
    int j = 0;
    
    for (UIImageView *imageView in self.m_ImageArray) {
        imageView.frame = CGRectMake(screenWidth * j++, 0, screenWidth, screenHeight);
        [self.scrollView addSubview:imageView];
        
        if (j == count ) {
            [imageView addSubview:self.finshButton];
            [imageView setUserInteractionEnabled:YES];
            [imageView addSubview:self.versionLabel];
        }
    }
    
 
    
    
    
    [self.scrollView setPagingEnabled:YES];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.canCancelContentTouches = NO;
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.frame = CGRectMake(0, screenHeight-32, screenWidth, 32);
    self.pageControl.numberOfPages = count;
    self.pageControl.currentPage = 0;
    [self.view addSubview:self.pageControl];
    self.pageControl.backgroundColor = [UIColor clearColor];
    
    
}


-(void)resizeWelcomePage
{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    

    
    
    
    NSUInteger count =self.m_ImageArray.count;
    
    CGRect scrollViewFrame = CGRectMake(0, 0, screenWidth, screenHeight);
    [self.scrollView setFrame:scrollViewFrame];
    CGSize scrollViewContentSize = CGSizeMake(screenWidth * count, screenHeight);
    [self.scrollView setContentSize:scrollViewContentSize];
    
    for (int i = 0; i<self.m_ImageArray.count; i++) {
        UIImageView* imageView = (UIImageView*)[self.m_ImageArray objectAtIndex:i];
        UIImage* showImage = [self getWelcomeImage:i+1];
        imageView.image = (showImage!=NULL)?showImage:[UIImage imageNamed:@"MenuBackground"];
        imageView.frame = CGRectMake(screenWidth * i, 0, screenWidth, screenHeight);
    }
    
    
    
    

    

    self.finshButton.frame = CGRectMake(screenWidth/2-70, (screenHeight*2)/3, 140, 60);
    
    self.versionLabel.frame = CGRectMake(screenWidth/2-50, (screenHeight*2)/3+80, 100, 40);

    self.pageControl.frame = CGRectMake(0, screenHeight-32, screenWidth, 32);
    
    
//    [self scrollViewDidScroll:self.scrollView];
    
}

-(UIImage *)getWelcomeImage: (NSInteger)index
{
    NSString *prefix = @"ipad_retina_";
    UIInterfaceOrientation orientation=[UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)){
        
        prefix = @"ipad_landscape_retina_";
        
    }else
    {
        if (IS_IPAD) {
            prefix = @"ipad_retina_";
        } else if (IS_IPHONE_5){
            prefix = @"iphone5_";
        }
        else if (IS_IPHONE_6){
            prefix = @"iphone6_";
        }
        else if (IS_IPHONE_6_PLUS){
            prefix = @"iphone6Plus_";
        }
        else {
            prefix = @"iphone_portrait_";
        }
        
        
    }
    
    
    
    
    NSString *subfix = @"menu";
    switch (index) {
        case 1:
            subfix = @"menu";
            break;
        case 2:
            subfix = @"toggle";
            break;
        case 3:
            subfix = @"share";
            break;
        case 4:
            subfix = @"logo";
            break;
            
        default:
            break;
    }
    return [UIImage imageNamed:[[prefix stringByAppendingString:subfix] stringByAppendingString:@".jpg"]];
}


- (void)finishWelcomePage:(id)sender
{
    NSLog(@"- (IBAction)finishWelcomePage:(id)sender");
    [UIView transitionWithView:self.view duration:2.0f
                       options:UIViewAnimationOptionTransitionNone animations:^(void)
     {
         [self.navigationController setNavigationBarHidden:NO animated:NO];
         [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
         self.scrollView.alpha=0.0f;
         self.pageControl.alpha=0.0f;
         
     }
                    completion:^(BOOL finished)
     {
         [self.scrollView removeFromSuperview];
         [self.pageControl removeFromSuperview];
         
         CATransition* transition = [CATransition animation];
         transition.duration = .2;
         transition.type = kCATransitionFade;
         transition.subtype = kCATransitionFade;
         [self.view.window.layer addAnimation:transition forKey:kCATransition];
         
         [self dismissViewControllerAnimated:NO completion:nil];
         
     }];
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
