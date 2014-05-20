//
//  ProximityStrategy.m
//  siteguide
//
//  Created by Christof Luethi on 10.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "ProximityStrategy.h"

@implementation ProximityStrategy
-(Location *)calculateWithSensorData:(MonomorphicArray *)data {
    if([data count] > 0) {
        SensorData *d = [data objectAtIndex:0];
        int major = [[d objectForKey:@"major"] intValue];
        int minor = [[d objectForKey:@"minor"] intValue];
        
        Beacon *b = [[BeaconManager sharedInstance] getBeaconByMajor:major minor:minor];
        DLog("Nearest beacon is: Name[%@] Major[%d] Minor[%d]", b.name, major, minor);
        return b.location;
    } else {
        return nil;
    }
}

-(NSString *)name {
    return @"ProximityStrategy";
}
@end
