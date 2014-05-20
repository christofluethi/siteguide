//
//  RegionManager.h
//  SiteGuide
//
//  Created by Christof Luethi on 03.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Site.h"
#import "Region.h"
#import "PointOfInterest.h"
#import "Location.h"
#import "Reachability.h"

@protocol RegionPOIDistanceDelegate <NSObject>

@required
-(void)distanceUpdateCompletedWithSuccess:(BOOL)success regions:(NSMutableDictionary *)regions pointOfInterests:(NSMutableDictionary *)pois;
@end


/**
 Region Manager is responsible for getting any region related information from the server.
 For Example:
    - Regions
    - POIs
 
 RegionManager is implemented as Singleton
 */
@interface RegionManager : NSObject
+(id)sharedInstance;
-(void)reload;
-(void)reachabilityChanged:(NSNotification *)notification;

/**
 Returns all regions as a tree
 @return a Mutable array of root regions
 */
-(NSMutableArray *)rootRegions;

/**
 Get all POIs for a region (recursive)
 @return All pois for a region
 */
-(NSMutableArray *)allPoisForRegion:(Region *)region;

/**
 Get all Pois for a list of regions (recursive)
 @return List of pois for these regions
 */
-(NSMutableArray *)allPoisForRegions:(NSMutableArray *)regions;

/**
 Total region count starting from the given regions (recursive)
 @return total of regions below these regions
 */
-(int)regionCount:(NSMutableArray *)regions;

/**
 Total poi count starting from the given regions (recursive)
 @return total of pois below these regions
 */
-(int)poiCount:(NSMutableArray *)regions;

/**
 Total shape count starting from the given regions (recursive)
 @return total of shapes below these regions
 */
-(int)shapeCount:(NSMutableArray *)regions;

/**
 @return mapSize for the given regions
 */
-(CGSize)mapSize: (NSMutableArray *) regions;

/**
 @return true if and only if the given regions have childs (one of them)
 */
-(BOOL)hasChilds:(NSMutableArray *)regions;

/**
 @return true if and only if the given regions have pois (one of them)
 */
-(BOOL)hasPois:(NSMutableArray *)regions;

/**
 @return timestamp of last distance data fetch.
 */
-(long)distanceDataAge;

/**
 request updating the distanceData
 a callback may be provided to get notified whenever the update is done
 */
-(void)requestDistanceUpdateWithDelegate:(id<RegionPOIDistanceDelegate>)delegate;
@end
