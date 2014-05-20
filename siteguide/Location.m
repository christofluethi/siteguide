//
//  Location.m
//  SiteGuide
//
//  Created by Christof Luethi on 27.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "Location.h"

@implementation Location

-(id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    
    if(self) {
        double xCoord = [[dict objectForKey:@"x"] doubleValue];
        double yCoord = [[dict objectForKey:@"y"] doubleValue];
        
        _xCoordinate = xCoord;
        _yCoordinate = yCoord;
        _zCoordinate = 0.0f;
    }
    
    return self;
}

-(id)initWithXCoordinate:(double)x YCoordinate:(double)y {
    self = [super init];
    
    if(self) {
        _xCoordinate = x;
        _yCoordinate = y;
        _zCoordinate = 0.0f;
    }
    
    return self;
}

-(id)initWithXCoordinate:(double)x YCoordinate:(double)y ZCoordinate:(double)z {
    self = [super init];
    
    if(self) {
        _xCoordinate = x;
        _yCoordinate = y;
        _zCoordinate = z;
    }
    
    return self;
}

-(double)locationComponentForDimension:(int)dimension {
    switch (dimension) {
        case 0:
            return _xCoordinate;
            break;
        case 1:
            return _yCoordinate;
            break;
        case 2:
            return _zCoordinate;
            break;
        default:
            return 0.0f;
            break;
    }
}

-(void)setLocationComponentForDimension:(int)dimension coordinate:(double)coord {
    switch (dimension) {
        case 0:
            _xCoordinate = coord;
            break;
        case 1:
            _yCoordinate = coord;
            break;
        case 2:
            _zCoordinate = coord;
            break;
        default:
            break;
    }
}
@end
