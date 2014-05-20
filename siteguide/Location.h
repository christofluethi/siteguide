//
//  Location.h
//  SiteGuide
//
//  Created by Christof Luethi on 27.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Model class for holding any coordinate
 This class is 3D ready. However, we only use 2D at the moment.
 
 Location dimensions:
 dimension 0 = x
 dimension 1 = y
 dimension 2 = z
 */
@interface Location : NSObject
@property (nonatomic, assign) double xCoordinate;
@property (nonatomic, assign) double yCoordinate;
@property (nonatomic, assign) double zCoordinate;


/**
 init new object with given X, Y & Z coordinates
 */
-(id)initWithXCoordinate:(double)x YCoordinate:(double)y ZCoordinate:(double)z;

/**
 init new object with given X, Y coordinates
 */
-(id)initWithXCoordinate:(double)x YCoordinate:(double)y;

/**
 init new object with a given Dictionary
 The dictionary is expected to have entries for 'x', 'y'
 */
-(id)initWithDictionary:(NSDictionary *)dict;

/**
 Get of Location component depending on given dimension
 */
-(double)locationComponentForDimension:(int)dimension;

/**
 Set specified dimension to the given location component
 */
-(void)setLocationComponentForDimension:(int)dimension coordinate:(double)coord;
@end
