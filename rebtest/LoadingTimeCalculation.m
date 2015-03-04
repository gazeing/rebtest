//
//  LoadingTimeCalculation.m
//  HybridWebView
//
//  Created by Steven Xu on 15/08/2014.
//  Copyright (c) 2014 Sterling Publishing. All rights reserved.
//

#import "LoadingTimeCalculation.h"

@implementation LoadingTimeCalculation

- (id)initCalculation
{
    self = [super init];
    self.beginTime =0;
    self.endTime =0;
    self.totalCount =0;
    self.totalTIme = 0;
    
    return self;
}



- (void) LoadingStart:(NSTimeInterval) begin
{
    self.beginTime = begin;
}

- (void) LoadingStart
{
    NSTimeInterval myInterval = [[NSDate date] timeIntervalSince1970];
    
    [self LoadingStart:myInterval];
}

- (void) LoadingFinsish:(NSTimeInterval) end LoadUrl:(NSString *)url
{
    self.endTime = end;
    NSTimeInterval gap = self.endTime - self.beginTime;
    if (gap>1)//the gap less then 1 second is not page loading
    {
        NSLog(@"loading %@ cost time: %f",url,gap);
        
        self.totalTIme += gap;
        self.totalCount++;
        if (self.totalCount!=0) {
            float ave = self.totalTIme/self.totalCount;
            NSLog(@"Now the avarage loading time per page is:  %f",ave);
        }
    }


}

- (void) LoadingFinsish:(NSString *)url
{
    NSTimeInterval endInterval = [[NSDate date] timeIntervalSince1970];
    
    [self LoadingFinsish:endInterval LoadUrl:url];
}

- (void) reset
{
    self.beginTime =0;
    self.endTime =0;
    self.totalCount =0;
    self.totalTIme = 0;
}

@end
