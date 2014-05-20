//
//  PointOfInterest.h
//  SiteGuide
//
//  Created by Christof Luethi on 03.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

/**
 Model Class holding values for Point of Interests
 Point of interests may have documents assigned.
 
 Documentlists may be cached to prevent networkload. The last fetch of the documentList is stored in the field documentsCacheTime
 */
@interface PointOfInterest : NSObject
@property (nonatomic, assign, readonly) int poiId;
@property (nonatomic, assign) double distance;
@property (nonatomic, strong, readonly) Location *location;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *description;
@property (nonatomic, strong) NSMutableArray *documents;
@property (nonatomic, assign) long documentsCacheTime;

/**
 Init a new POI
 */
-(id)initWithName:(NSString*)name description:(NSString*)description poiId:(int)poiId location:(Location *)location;
@end
