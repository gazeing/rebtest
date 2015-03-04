//
//  LoadingTimeCalculation.h
//  HybridWebView
//
//  Created by Steven Xu on 15/08/2014.
//  Copyright (c) 2014 Sterling Publishing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadingTimeCalculation : NSObject

@property (assign, nonatomic) NSTimeInterval beginTime;
@property (assign, nonatomic) NSTimeInterval endTime;
@property (assign, nonatomic) NSTimeInterval totalTIme;
@property (assign, nonatomic) NSUInteger totalCount;


- (id)initCalculation;

- (void) LoadingStart:(NSTimeInterval) begin;
- (void) LoadingStart;
- (void) LoadingFinsish:(NSTimeInterval) end LoadUrl:(NSString *)url;
- (void) LoadingFinsish:(NSString *)url;


- (void) reset;

@end
