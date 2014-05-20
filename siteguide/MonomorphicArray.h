//
//  MonomorphicArray.h
//  siteguide
//
//  Created by Christof Luethi on 25.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Array which only allows to store objects of the same type
 http://stackoverflow.com/questions/5197446/nsmutablearray-force-the-array-to-hold-specific-object-type-only
 */
@interface MonomorphicArray : NSMutableArray {
    Class elementClass;
    NSMutableArray *array;
}

/**
 init array with given class type and capacity
 */
- (id) initWithClass:(Class)element andCapacity:(NSUInteger)numItems;

/**
 init array with given class type
 */
- (id) initWithClass:(Class)element;

@end
