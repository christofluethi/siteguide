//
//  SensorDataQueue.m
//  siteguide
//
//  Created by Christof Luethi on 24.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "SensorDataQueue.h"

@implementation SensorDataQueue

-(id)init
{
    self = [super init];
    
    if(self) {
        array = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(id)dequeue {
    if([array count] > 0) {
        id last = [self peek];
        [array removeObjectAtIndex:0];
        return last;
    }
    
    return nil;
}

-(void)enqueue:(id)element {
    [array addObject:element];
}

-(void)enqueueElementsFromArray:(NSArray *)arr {
    [array addObjectsFromArray:arr];
}

-(void)enqueueElementsFromQueue:(SensorDataQueue*)queue
{
    while (![queue isEmpty]) {
        [self enqueue:[queue dequeue]];
    }
}

-(id)peek {
    if([array count] > 0) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

-(NSUInteger)size {
    return [array count];
}

-(BOOL)isEmpty {
    return ([array count] == 0);
}

-(void)clear {
    [array removeAllObjects];
}

@end
