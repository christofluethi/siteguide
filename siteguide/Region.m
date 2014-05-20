//
//  Region.m
//  SiteGuide
//
//  Created by Christof Luethi on 03.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "Region.h"

@implementation Region

-(id)initWithName:(NSString*)name description:(NSString *)description regionId:(int)regionId parentId:(int)parentId type:(NSString *)type key:(NSString *)key {
    self = [super init];
    
    if(self) {
        _name = name;
        _description = description;
        _type = type;
        _key = key;
        _regionId = regionId;
        _parentId = parentId;
        _childs = [[NSMutableArray alloc] init];
        _distance = 0.0;
    }
    
    return self;
}

-(id)initWithName:(NSString*)name description:(NSString *)description regionId:(int)regionId parentId:(int)parentId type:(NSString *)type key:(NSString *)key poiList:(NSMutableArray *)poiList shapeList:(NSMutableArray *)shapeList {
    self = [super init];
    
    if(self) {
        _name = name;
        _description = description;
        _key = key;
        _type = type;
        _regionId = regionId;
        _parentId = parentId;
        _childs = [[NSMutableArray alloc] init];
        _poiList = poiList;
        _shapeList = shapeList;
        _distance = 0.0;
    }
    
    return self;
}

-(void)addChild:(Region *)region {
    [_childs addObject:region];
    // DLog("Adding Region to ID[%d]: Count %lu", _regionId, (unsigned long)[_childs count]);
}

-(BOOL)hasChilds {
    if([_childs count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

-(void)setDistance:(double)distance {
    _distance = distance;
}


-(BOOL)isRoom {
    return ([_type caseInsensitiveCompare:@"room"] == NSOrderedSame);
}

-(BOOL)isArea {
    return ([_type caseInsensitiveCompare:@"area"] == NSOrderedSame);
}

-(BOOL)isOther {
    return ([_type caseInsensitiveCompare:@"other"] == NSOrderedSame);
}
@end
