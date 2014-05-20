//
//  SensorData.h
//  siteguide
//
//  Created by Christof Luethi on 24.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Model Class holding values for a RAW sensor value
 Sensor Values are created by the SensorManager
 */
@interface SensorData : NSObject
@property (nonatomic, strong, readonly) NSMutableDictionary *data;
@property (nonatomic, assign) sensorDataType type;

/**
 init new SensorData with type only
 @return id of created object
 */
-(id)initWithType:(sensorDataType)type;

/**
 init new SensorData with type and given data
 @return id of created object
 */
-(id)initWithType:(sensorDataType)type data:(NSMutableDictionary *)data;

/**
 set an object for the given key
 @return void
 */
-(void)setObject:(id)value forKey:(NSString *)key;

/**
 return object for given key
 @return id of object or nil if not found.
 */
-(id)objectForKey:(NSString *)key;

/**
 Returns the type of the origin Sensor which created this SensorData sample.
 @return sensorType responsible for this SensorData object
 */
-(sensorDataType)getDataType;
@end
