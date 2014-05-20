//
//  SiteGuideDataHandler.m
//  siteguide
//
//  Created by Christof Luethi on 24.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "SiteGuideDataHandler.h"

@implementation SiteGuideDataHandler

@synthesize next = nextHandler;

-(void)setNextModule:(SiteGuideDataHandler *)module {
    nextHandler = module;
}

-(void)handleData:(MonomorphicArray *)data {
    if(nextHandler) {
        [nextHandler handleData:data];
    }
}
@end
