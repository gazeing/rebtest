//
//  JsonDownloader.h
//  RPM
//
//  Created by Steven Xu on 4/02/2015.
//  Copyright (c) 2015 Sterling Publishing. All rights reserved.
//

#import <Foundation/Foundation.h>



// declare our class
@class JsonDownloader;

// define the protocol for the delegate
@protocol JsonDownloaderDelegate

// define protocol functions that can be used in any class using this delegate
//-(void)sayHello:(JsonDownloader *)customClass;

@required
- (void)onDownloadFinished:(NSMutableArray* ) outList;

@end

@interface JsonDownloader : NSObject
{
    NSMutableArray *list;
    

}

// define delegate property
@property (nonatomic, assign) id  delegate;

@property (strong, nonatomic) NSMutableArray* categoryList;

// define public functions
-(id)initWithList:(NSMutableArray *) inList;

-(void)loadArticleList:(NSMutableArray* )categoryList;

@end
