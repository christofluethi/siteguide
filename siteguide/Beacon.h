//
//  Beacon.h
//  siteguide
//
//  Created by Christof Luethi on 08.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

/**
 Model class representing a Beacon
 Each beacon has a given Location
 The UUID which belongs to a beacon is stored in the Site object. Its not possible to have multiple UUIDs.
 */
@interface Beacon : NSObject
@property (nonatomic, assign, readonly) int beaconId;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) Location *location;
@property (nonatomic, assign, readonly) int major;
@property (nonatomic, assign, readonly) int minor;
@property (nonatomic, assign, readonly) int powerLevelOffset;

/**
 init a new Beacon
 */
-(id)initWithName:(NSString*)name beaconId:(int)beaconId major:(int)major minor:(int)minor location:(Location *)location powerLevelOffset:(int)powerLevelOffset;
@end
