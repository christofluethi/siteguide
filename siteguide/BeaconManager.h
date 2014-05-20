//
//  BeaconManager.h
//  siteguide
//
//  Created by Christof Luethi on 08.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Site.h"
#import "Beacon.h"
#import "Reachability.h"

/**
 Class responsible for managing the iBeacon locations and configuration
 Gets its data from the server.
 
 implemented as a singleton.
 */
@interface BeaconManager : NSObject
@property (nonatomic, strong) NSMutableArray *beacons;
@property (nonatomic, strong) NSMutableDictionary *beaconDict;

+(id)sharedInstance;

/**
 reload the data from the server
 */
-(void)reload;

/**
 @return the beacon for the given major minor combination
 */
-(Beacon *)getBeaconByMajor:(int)major minor:(int)minor;

-(void)reachabilityChanged:(NSNotification *)notification;
@end
