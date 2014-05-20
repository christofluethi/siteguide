//
//  SiteGuideDataHandler.h
//  siteguide
//
//  Created by Christof Luethi on 24.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SensorData.h"
#import "MonomorphicArray.h"

/**
 Base class for any data handler
 */
@interface SiteGuideDataHandler : NSObject {
    SiteGuideDataHandler *nextHandler;
}

@property (nonatomic, retain) SiteGuideDataHandler *next;

/**
 Set the next SiteGuideDataHandler
 */
-(void)setNextModule:(SiteGuideDataHandler *)next;

/**
 Process data and dispatch to the next handler (if any)
 */
-(void)handleData:(MonomorphicArray *)data;
@end
