//
//  Region.h
//  SiteGuide
//
//  Created by Christof Luethi on 03.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Model class for a Region Object
 Regions are created and managed by the RegionManager
 
 Optionally regions may have childs and an assigned poiList.
 
 Distance:
 Each Region can (but dont have to) have an attached distance value. The Distance value is based on position and therefore not specified while fetching Region infos from server. There's no garantee that a Region has a distance value set.
 */
@interface Region : NSObject
@property (nonatomic, assign, readonly) int regionId;
@property (nonatomic, assign) int parentId;
@property (nonatomic, assign) double distance;
@property (nonatomic, weak) Region *parent;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *description;
@property (nonatomic, strong, readonly) NSString *type;
@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, strong) NSMutableArray *childs;
@property (nonatomic, strong) NSMutableArray *poiList;
@property (nonatomic, strong) NSMutableArray *shapeList;


/**
 Init new Region with given name, description, regionId and parentId
 */
-(id)initWithName:(NSString*)name description:(NSString*)description regionId:(int)regionId parentId:(int)parentId type:(NSString *)type key:(NSString *)key ;


/**
 Init new Region with given name, description, regionId, parentId, poiList and shapeList
 */
-(id)initWithName:(NSString*)name description:(NSString*)description regionId:(int)regionId parentId:(int)parentId type:(NSString *)type key:(NSString *)key poiList:(NSMutableArray *)poiList shapeList:(NSMutableArray *)shapeList;


/**
 add a new Childregion
 */
-(void)addChild:(Region*)region;

/**
 check if a region has childs
 @return YES if and only if the Region has childs
 */
-(BOOL)hasChilds;

/**
 Set given distance
 */
-(void)setDistance:(double)distance;

/**
 Region is of type ROOM
 @return YES if and only if the room is of Room-Type ROOM
 */
-(BOOL)isRoom;

/**
 Region is of type OTHER
 @return YES if and only if the room is of Room-Type OTHER
 */
-(BOOL)isOther;

/**
 Region is of type AREA
 @return YES if and only if the room is of Room-Type AREA
 */
-(BOOL)isArea;

@end
