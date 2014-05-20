//
//  MixedStrategy.m
//  siteguide
//
//  Created by Christof Luethi on 10.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "MixedStrategy.h"

const double PROXIMITY_TRIGGER = 0.5;

@implementation MixedStrategy

/*
 Due to simplicity this code is copypasted from TriangulationStrategy
 only made small changes
 */
-(Location *)calculateWithSensorData:(MonomorphicArray *)data {
    int dimensions = 2;
    DLog("Total Beacons Available: %lu", (unsigned long)[data count]);
    
    if([data count] > 0 && [data count] < 3) {
        SensorData *d = [data objectAtIndex:0];
        int major = [[d objectForKey:@"major"] intValue];
        int minor = [[d objectForKey:@"minor"] intValue];
        double distance = [[d objectForKey:@"distance"] doubleValue];
        Beacon *b = [[BeaconManager sharedInstance] getBeaconByMajor:major minor:minor];
        if(b != nil) {
            DLog("Returning position in ProximityMode Distance[%f] ID[%i/%i] Name[%@]", distance, b.major, b.minor, b.name);
            return b.location;
        }
    } else if([data count] >= 3) {
        Beacon *p1 = nil;
        Beacon *p2 = nil;
        Beacon *p3 = nil;
        double DistA = 0.0;
        double DistB = 0.0;
        double DistC = 0.0;
        
        for (int i = 0; i < 3; i++) {
            SensorData *d = [data objectAtIndex:i];
            int major = [[d objectForKey:@"major"] intValue];
            int minor = [[d objectForKey:@"minor"] intValue];
            double distance = [[d objectForKey:@"distance"] doubleValue];
            
            // refactor - ugly. chl 2014-03-09
            switch (i) {
                case 0:
                    p1 = [[BeaconManager sharedInstance] getBeaconByMajor:major minor:minor];
                    DLog("Beacon: Name[%@], ID[%i/%i], Beacon Location[%.1f/%.1f], Distance[%.2f]", p1.name, major, minor, p1.location.xCoordinate, p1.location.yCoordinate, distance);
                    DistA = distance;
                    break;
                case 1:
                    p2 = [[BeaconManager sharedInstance] getBeaconByMajor:major minor:minor];
                    DLog("Beacon: Name[%@], ID[%i/%i], Beacon Location[%.1f/%.1f], Distance[%.2f]", p2.name, major, minor, p2.location.xCoordinate, p2.location.yCoordinate, distance);
                    DistB = distance;
                    break;
                case 2:
                    p3 = [[BeaconManager sharedInstance] getBeaconByMajor:major minor:minor];
                    DLog("Beacon: Name[%@], ID[%i/%i], Beacon Location[%.1f/%.1f], Distance[%.2f]", p3.name, major, minor, p3.location.xCoordinate, p3.location.yCoordinate, distance);
                    DistC = distance;
                    break;
                default:
                    break;
            }
        }
        
        /* check if we are near a beacon */
        if(DistA < PROXIMITY_TRIGGER) {
            DLog("Returning position in ProximityMode Distance[%f] Id[%i/%i] Name[%@]", DistA, p1.major, p1.minor, p1.name);
            return p1.location;
        }
        
        NSMutableArray *ex = [[NSMutableArray alloc] initWithCapacity:0];
        double temp = 0;
        for (int i = 0; i < dimensions; i++) {
            double t1 = [p2.location locationComponentForDimension:i];
            double t2 = [p1.location locationComponentForDimension:i];
            double t = t1 - t2;
            temp += (t*t);
        }
        
        for (int i = 0; i < dimensions; i++) {
            double t1 = [p2.location locationComponentForDimension:i];
            double t2 = [p1.location locationComponentForDimension:i];
            double exx = (t1 - t2)/sqrt(temp);
            [ex addObject:[NSNumber numberWithDouble:exx]];
        }
        
        // i = dot(ex, P3 - P1)
        NSMutableArray *p3p1 = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < dimensions; i++) {
            double t1 = [p3.location locationComponentForDimension:i];
            double t2 = [p1.location locationComponentForDimension:i];
            double t3 = t1 - t2;
            [p3p1 addObject:[NSNumber numberWithDouble:t3]];
        }
        
        double ival = 0;
        for (int i = 0; i < [ex count]; i++) {
            double t1 = [[ex objectAtIndex:i] doubleValue];
            double t2 = [[p3p1 objectAtIndex:i] doubleValue];
            ival += (t1*t2);
        }
        
        // ey = (P3 - P1 - i*ex)/(numpy.linalg.norm(P3 - P1 - i*ex))
        NSMutableArray *ey = [[NSMutableArray alloc] initWithCapacity:0];
        double p3p1i = 0;
        for (int  i = 0; i < dimensions; i++) {
            double t1 = [p3.location locationComponentForDimension:i];
            double t2 = [p1.location locationComponentForDimension:i];
            double t3 = [[ex objectAtIndex:i] doubleValue] * ival;
            double t = t1 - t2 -t3;
            p3p1i += (t*t);
        }
        
        for (int i = 0; i < dimensions; i++) {
            double t1 = [p3.location locationComponentForDimension:i];
            double t2 = [p1.location locationComponentForDimension:i];
            double t3 = [[ex objectAtIndex:i] doubleValue] * ival;
            double eyy = (t1 - t2 - t3)/sqrt(p3p1i);
            [ey addObject:[NSNumber numberWithDouble:eyy]];
        }
        
        // ez = numpy.cross(ex,ey)
        // if 2-dimensional vector then ez = 0
        NSMutableArray *ez = [[NSMutableArray alloc] initWithCapacity:0];
        double ezx;
        double ezy;
        double ezz;
        if (dimensions !=3){
            ezx = 0;
            ezy = 0;
            ezz = 0;
        } else {
            ezx = ([[ex objectAtIndex:1] doubleValue]*[[ey objectAtIndex:2]doubleValue]) - ([[ex objectAtIndex:2]doubleValue]*[[ey objectAtIndex:1]doubleValue]);
            ezy = ([[ex objectAtIndex:2] doubleValue]*[[ey objectAtIndex:0]doubleValue]) - ([[ex objectAtIndex:0]doubleValue]*[[ey objectAtIndex:2]doubleValue]);
            ezz = ([[ex objectAtIndex:0] doubleValue]*[[ey objectAtIndex:1]doubleValue]) - ([[ex objectAtIndex:1]doubleValue]*[[ey objectAtIndex:0]doubleValue]);
        }
        
        [ez addObject:[NSNumber numberWithDouble:ezx]];
        [ez addObject:[NSNumber numberWithDouble:ezy]];
        [ez addObject:[NSNumber numberWithDouble:ezz]];
        
        // d = numpy.linalg.norm(P2 - P1)
        double d = sqrt(temp);
        
        // j = dot(ey, P3 - P1)
        double jval = 0;
        for (int i = 0; i < [ey count]; i++) {
            double t1 = [[ey objectAtIndex:i] doubleValue];
            double t2 = [[p3p1 objectAtIndex:i] doubleValue];
            jval += (t1*t2);
        }
        
        // x = (pow(DistA,2) - pow(DistB,2) + pow(d,2))/(2*d)
        double xval = (pow(DistA,2) - pow(DistB,2) + pow(d,2))/(2*d);
        
        // y = ((pow(DistA,2) - pow(DistC,2) + pow(i,2) + pow(j,2))/(2*j)) - ((i/j)*x)
        double yval = ((pow(DistA,2) - pow(DistC,2) + pow(ival,2) + pow(jval,2))/(2*jval)) - ((ival/jval)*xval);
        
        // z = sqrt(pow(DistA,2) - pow(x,2) - pow(y,2))
        // if 2-dimensional vector then z = 0
        double zval;
        if(dimensions !=3) {
            zval = 0;
        } else {
            zval = sqrt(pow(DistA,2) - pow(xval,2) - pow(yval,2));
        }
        
        // triPt = P1 + x*ex + y*ey + z*ez
        NSMutableArray *triPt = [[NSMutableArray alloc] initWithCapacity:0];
        Location *pos = [[Location alloc] init];
        for (int i = 0; i < dimensions; i++) {
            double t1 = [p1.location locationComponentForDimension:i];
            double t2 = [[ex objectAtIndex:i] doubleValue] * xval;
            double t3 = [[ey objectAtIndex:i] doubleValue] * yval;
            double t4 = [[ez objectAtIndex:i] doubleValue] * zval;
            double triptx = t1+t2+t3+t4;
            [pos setLocationComponentForDimension:i coordinate:triptx];
            [triPt addObject:[NSNumber numberWithDouble:triptx]];
        }
        
        DLog(@"ex %@",ex);
        DLog(@"i %f",ival);
        DLog(@"ey %@",ey);
        DLog(@"d %f",d);
        DLog(@"j %f",jval);
        DLog(@"x %f",xval);
        DLog(@"y %f",yval);
        DLog(@"y %f",yval);
        DLog(@"final result %@",triPt);
        
        DLog("Returning position in Triangulation");
        return pos;
    } else {
        return nil;
    }
    
    return nil;
}

-(NSString *)name {
    return @"MixedStrategy";
}

@end
