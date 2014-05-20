//
//  CalibrationModule.m
//  siteguide
//
//  Created by Christof Luethi on 24.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "CalibrationModule.h"

@implementation CalibrationModule
- (id)init
{
    self = [super init];
    if (self) {
        _factor = 1;
    }
    return self;
}

-(void)handleData:(MonomorphicArray *)data {
    if(nextHandler != nil) {
        [nextHandler handleData:data];
    }
}
@end
