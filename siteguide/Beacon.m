//
//  Beacon.m
//  siteguide
//
//  Created by Christof Luethi on 08.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "Beacon.h"

@implementation Beacon

-(id)initWithName:(NSString*)name beaconId:(int)beaconId major:(int)major minor:(int)minor location:(Location *)location powerLevelOffset:(int)powerLevelOffset {
    self = [super init];
    
    if(self) {
        _name = name;
        _beaconId = beaconId;
        _major = major;
        _minor = minor;
        _location = location;
        _powerLevelOffset = powerLevelOffset;
    }
    
    return self;
}

@end
