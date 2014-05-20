//
//  SensorData.m
//  siteguide
//
//  Created by Christof Luethi on 24.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "SensorData.h"

@implementation SensorData
-(id)initWithType:(sensorDataType)type {
    self = [super init];
    
    if(self) {
        _data = [[NSMutableDictionary alloc] init];
        _type = type;
    }
    
    return self;
}

-(id)initWithType:(sensorDataType)type data:(NSMutableDictionary *)data {
    self = [super init];
    
    if(self) {
        if(data) {
            _data = data;
        } else {
            // call initWithType:type
            _data = [[NSMutableDictionary alloc] init];
        }
        _type = type;
    }
    
    return self;
}

-(id)objectForKey:(NSString *)key {
    return [_data objectForKey:key];
}

-(void)setObject:(id)value forKey:(NSString *)key {
    [_data setObject:value forKey:key];
}

-(sensorDataType)getDataType {
    return _type;
}
@end
