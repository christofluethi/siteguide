//
//  Site.m
//  siteguide
//
//  Created by Christof Luethi on 20.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "Site.h"

@implementation Site
-(id)initWithName:(NSString*)name siteId:(int)siteId beaconUUID:(NSString*)beaconUUID {
    self = [super init];
    
    if(self) {
        _name = name;
        _siteId = siteId;
        _beaconUUID = beaconUUID;
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    
    if(self) {
        _name = [decoder decodeObjectForKey:@"name"];
        _siteId = (int)[decoder decodeIntegerForKey:@"siteId"];
        _beaconUUID = [decoder decodeObjectForKey:@"beaconUUID"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeInt:_siteId forKey:@"siteId"];
    [encoder encodeObject:_beaconUUID forKey:@"beaconUUID"];
}
@end
