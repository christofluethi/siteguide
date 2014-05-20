//
//  SensorDataQueue.h
//  siteguide
//
//  Created by Christof Luethi on 24.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Code based on DKQueue - FIFO (first in first out) data structure for Objective-C
 Source: https://github.com/dominikkrejcik/Objective-C-Stack---Queue/
 */
@interface SensorDataQueue : NSObject {
    NSMutableArray *array;
}

/**
 return and remove last element
 @return id of dequeued object
 */
-(id)dequeue;

/**
 return last element
 @return id of last element
 */
-(id)peek;

/**
 add element to queue
 */
-(void)enqueue:(id)element;

/**
 add all elements from array
 */
-(void)enqueueElementsFromArray:(NSArray*)arr;


/**
 add all elements from queue
 */
-(void)enqueueElementsFromQueue:(SensorDataQueue*)queue;

/**
 remove all elements
 */
-(void)clear;

/**
 check if the queue is empty
 @return YES if and only if the queue is empty
 */
-(BOOL)isEmpty;

/**
 return size of queue
 @return size of queue
 */
-(NSUInteger)size;

@end
