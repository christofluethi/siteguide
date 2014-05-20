//
//  MonomorphicArray.m
//  siteguide
//
//  Created by Christof Luethi on 25.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "MonomorphicArray.h"

@implementation MonomorphicArray

- (id) initWithClass:(Class)element andCapacity:(NSUInteger)numItems {
    elementClass = element;
    array = [NSMutableArray arrayWithCapacity:numItems];
    return self;
}

- (id) initWithClass:(Class)element {
    elementClass = element;
    array = [NSMutableArray new];
    return self;
}


- (void) insertObject:(id)anObject atIndex:(NSUInteger)index {
    if ([anObject isKindOfClass:elementClass]) {
        [array insertObject:anObject atIndex:index];
    } else {
        NSException* myException = [NSException exceptionWithName:@"InvalidAddObject" reason:@"Added object has wrong type" userInfo:nil];
        @throw myException;
    }
}

- (void) removeObjectAtIndex:(NSUInteger)index {
    [array removeObjectAtIndex:index];
}

- (NSUInteger) count {
    return [array count];
}

- (id) objectAtIndex:(NSUInteger)index {
    return [array objectAtIndex:index];
}


static id NotSupported() {
    NSException* myException = [NSException exceptionWithName:@"InvalidInitializer" reason:@"Only initWithClass: and initWithClass:andCapacity: supported" userInfo:nil];
    @throw myException;
}

- (id)initWithArray:(NSArray *)anArray { return NotSupported(); }
- (id)initWithArray:(NSArray *)array copyItems:(BOOL)flag { return NotSupported(); }
- (id)initWithContentsOfFile:(NSString *)aPath { return NotSupported(); }
- (id)initWithContentsOfURL:(NSURL *)aURL { return NotSupported(); }
- (id)initWithObjects:(id)firstObj, ... { return NotSupported(); }
- (id)initWithObjects:(const id *)objects count:(NSUInteger)count { return NotSupported(); }

@end
