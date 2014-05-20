//
//  PointOfInterest.m
//  SiteGuide
//
//  Created by Christof Luethi on 03.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "PointOfInterest.h"

@implementation PointOfInterest
-(id)initWithName:(NSString *)name description:(NSString *)description poiId:(int)poiId location:(Location *)location {
    self = [super init];
    
    if(self) {
        _name = name;
        _description = description;
        _poiId = poiId;
        _location = location;
        _documentsCacheTime = 0l;
        _distance = 0.0;
    }
    
    return self;
}

@end
