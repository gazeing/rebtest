//
//  TodayViewController.m
//  BreakingNews
//
//  Created by Steven Xu on 23/09/2014.
//  Copyright (c) 2014 Sterling Publishing. All rights reserved.
//

#define HUE_API_USER    @"newdeveloper"

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "AFNetworking.h"
#import "Reachability.h"


@interface TodayViewController () <NCWidgetProviding>{
    NSMutableArray *dataSource;
    NSString *ipAddress;
    
//    NSURLSessionDataTask *ipAddressTask;
//    NSURLSessionDataTask *lightsTask;
    
    NSMutableDictionary *lightStates;
}


@end

@implementation TodayViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view from its nib.
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
//    // Perform any setup necessary in order to update the view.
//    
//    // If an error is encountered, use NCUpdateResultFailed
//    // If there's no update required, use NCUpdateResultNoData
//    // If there's an update, use NCUpdateResultNewData
//
//    completionHandler(NCUpdateResultNewData);
//}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    ipAddress = @"";
    dataSource = [NSMutableArray array];
    lightStates = [NSMutableDictionary dictionary];
    
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:nil
//                                                          delegate:self
//                                                     delegateQueue:nil];
    
    NSString *getApiPath = @"http://www.whichinvestmentproperty.com.au/?option=com_ajax&format=json&plugin=latestajaxarticlesfromcategory&cat_id=26";
//    NSString *getUrlString = getApiPath;
    jsonUrl = getApiPath;
    
    if (m_LoadingQueue==nil) {
        m_LoadingQueue = [[NSMutableArray alloc] init];
        m_TitleQueue =[[NSMutableArray alloc] init];
        
        NSLog(@"extension start");
        
        [self BuildCachePageQueue];
    }
    

    
//    ipAddressTask = [session dataTaskWithURL:[NSURL URLWithString:getUrlString] completionHandler:nil];
//    
//    [ipAddressTask resume];
}

- (void) AddUrlToQueue:(NSString *)urlString Title:(NSString *)titleString
{
    
    [m_LoadingQueue addObject:urlString];
    [m_TitleQueue addObject:titleString];
}

- (void) BuildCachePageQueue
{
    //json url: http://www.rebonline.com.au/steven/json/LoadingQueue.json
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:jsonUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //                NSLog(@"JSON: %@", responseObject);
        [self parseItems:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

-(void)parseItems:(id)json
{

    
    NSDictionary *jsonDict = (NSDictionary *) json;
    NSArray *array = [jsonDict objectForKey:@"data"];
    [array enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
        NSArray *innerarray = obj;
        [innerarray enumerateObjectsUsingBlock:^(id innerobj,NSUInteger idx, BOOL *stop){
            NSString *title = [innerobj objectForKey:@"title"];
            NSString *url = [innerobj objectForKey:@"link"];
            
            //            NSLog(@"Loading queue title = %@, url = %@",title,url);
            
            [self AddUrlToQueue:[NSString stringWithFormat:@"%@/%@",@"http://www.whichinvestmentproperty.com.au",url] Title:title];
            
        }];
        
        
        
    }];
    
    [self.tableView reloadData];
    
    
//    [self LoadNextCachePage];
    
}


//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
//didReceiveResponse:(NSURLResponse *)response
// completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
//{
//    NSLog(@"dataTask didReceiveResponse: %@", response);
//    completionHandler(NSURLSessionResponseAllow);
//}
//
//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
//    didReceiveData:(NSData *)data
//{
//    
//    if(dataTask == ipAddressTask){
//        
////         NSLog(@"dataTask didReceiveData: %@", data);
//        NSError *JSONError = nil;
//        NSArray *json = [NSJSONSerialization JSONObjectWithData:data
//                                                        options:0
//                                                          error:&JSONError];
//        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
//        NSLog(@"didReceiveResponse json:   %@", jsonDict);
//        
//        
//        if (JSONError)
//        {
//            NSLog(@"Serialization error: %@", JSONError.localizedDescription);
//        } else {
//            NSLog(@"ipAddressTask Data: %@", json);
//            
//            NSDictionary *dictionary = [json firstObject];
//            
//            ipAddress = [NSString stringWithString:[dictionary objectForKey:@"internalipaddress"]];
//            
//            NSURLSession *session = [NSURLSession sessionWithConfiguration:nil
//                                                                  delegate:self
//                                                             delegateQueue:nil];
//            
//            NSString *apiPath = [NSString stringWithFormat:@"/api/%@/lights/",HUE_API_USER];
//            NSString *urlString = [NSString stringWithFormat:@"http://%@%@",ipAddress,apiPath];
//            NSLog(@"Light Task URL: %@", urlString);
//            
//            lightsTask = [session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:nil];
//            
//            [lightsTask resume];
//        }
//    } else if(dataTask == lightsTask){
//        NSError *JSONError = nil;
//        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
//                                                             options:0
//                                                               error:&JSONError];
//        if (JSONError)
//        {
//            NSLog(@"Serialization error: %@", JSONError.localizedDescription);
//        } else {
//            NSLog(@"lightsTask Data: %@", json);
//            
//            for(NSString* key in json){
//                NSString *lightName = [[json objectForKey:key] objectForKey:@"name"];
//                [dataSource addObject:lightName];
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableView reloadData];
//                [self updateLightStates];
//            });
//        }
//    }
//    
//}

//-(void)updateLightStates
//{
//    NSURLSession *session = [NSURLSession sharedSession];
//    
//    for(int i=0;i<[dataSource count];i++){
//        
//        NSString *apiPath = [NSString stringWithFormat:@"/api/%@/lights/%i",HUE_API_USER,i+1];
//        NSString *urlString = [NSString stringWithFormat:@"http://%@%@",ipAddress,apiPath];
//        NSURLSessionDataTask *getTask = [session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            NSLog(@"%@", json);
//            NSDictionary *lightState = [json objectForKey:@"state"];
//            
//            NSNumber *currentState = [lightState objectForKey:@"on"];
//            [lightStates setObject:currentState forKey:[NSString stringWithFormat:@"%i",i+1]];
//            NSLog(@"On state for Light %i: %@",i+1,[lightState objectForKey:@"on"]);
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//            });
//        }];
//        [getTask resume];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    completionHandler(NCUpdateResultNewData);
}

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return [dataSource count];
    return [m_TitleQueue count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
//    cell.textLabel.text = [dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = [m_TitleQueue objectAtIndex:indexPath.row];
    cell.imageView.image =[UIImage imageNamed:@"IconLatestNews"];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
//    NSNumber *currentState = (NSNumber *)[lightStates objectForKey:[NSString stringWithFormat:@"%i",indexPath.row+1]];
//    
//    if([currentState boolValue]){
        cell.textLabel.textColor = [UIColor whiteColor];
//    } else {
//        cell.textLabel.textColor = [UIColor lightGrayColor];
//    }
    
    return cell;
}

#pragma UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSURLSession *session = [NSURLSession sharedSession];
    
//    NSString *apiPath = [NSString stringWithFormat:@"/api/%@/lights/%i/state", HUE_API_USER, indexPath.row+1];
//    NSString *urlString = [NSString stringWithFormat:@"http://%@%@",ipAddress,apiPath];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    [request setHTTPMethod:@"PUT"];
//    
//    NSNumber *currentState = (NSNumber *)[lightStates objectForKey:[NSString stringWithFormat:@"%i",indexPath.row+1]];
//    NSNumber *newState = [NSNumber numberWithBool:[currentState boolValue]?NO:YES];
//    
//    NSDictionary *mapData = @{@"on":newState};
//    NSError *error;
//    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
//    [request setHTTPBody:postData];
//    
//    NSURLSessionDataTask *postTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"PUT Result: %@", json);
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [lightStates setObject:newState forKey:[NSString stringWithFormat:@"%i",indexPath.row+1]];
//            [self.tableView reloadData];
//        });
//    }];
//    
//    [postTask resume];
    
    NSString *linkClick = [m_LoadingQueue objectAtIndex:indexPath.row];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"com.sterlingpublishing.WIP://?%@",linkClick]];
    
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        
    }];
}

-(NSString *)getClickedLink :(NSIndexPath *)indexPath
{
    if (indexPath.row<[m_LoadingQueue count]) {
        NSString *linkClick = [m_LoadingQueue objectAtIndex:indexPath.row];
        [m_LoadingQueue removeObjectAtIndex:indexPath.row];
        [m_TitleQueue removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];

        return linkClick;
    } else {
        return nil;
    }
    
    
    
}

@end
