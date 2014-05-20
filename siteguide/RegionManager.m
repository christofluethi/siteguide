//
//  RegionManager.m
//  SiteGuide
//
//  Created by Christof Luethi on 03.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "RegionManager.h"

NSString* const REGION_API_CALL = @"/TestCockpit/api/1/site/%i/regions";
NSString* const DISTANCE_API_CALL = @"/TestCockpit/api/1/site/%i/distances?byPositionX=%f&byPositionY=%f";

@implementation RegionManager {
    Site *site;
    NSMutableArray *rootRegions;
    NSMutableDictionary *regionDistances;
    NSMutableDictionary *poiDistances;
    Location *lastPosition;
    long distanceDataFetched;
}

/* yes this is a singleton */
+ (id)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(id)init {
    self = [super init];
    
    if(self) {
        [self reload];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteChanged:) name:kNotificationSiteChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(positionUpdate:) name:kNotificationPositionUpdate object:nil];
        
        distanceDataFetched = -1;
    }
    
    return self;
}

-(void)reload {
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsSite];
    if(encodedObject) {
        site = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    }
    
    if(rootRegions == nil) {
        rootRegions = [[NSMutableArray alloc] init];
    } else {
        [rootRegions removeAllObjects];
    }
    
    if(site) {
        [self makeRegionRequest];
    }
}

-(void)makeRegionRequest {
    NSString* baseUrl = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingsUrl];
    NSString* regionCall = [NSString stringWithFormat:@"%@%@", baseUrl, [NSString stringWithFormat:REGION_API_CALL, site.siteId]];
    
    DLog(@"NetworkCall: %@", regionCall);
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:regionCall]
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        DLog(@"%@", json);
        
        if (jsonError) {
            return;
        }
        
        NSMutableArray *tempRegions = [[NSMutableArray alloc] init];
        NSMutableDictionary *idToRegion = [[NSMutableDictionary alloc] init];
        int delayed = 0;
        int errors = 0;
        int added = 0;
        // fill up new site
        for (NSDictionary *dataDict in json) {
            NSString *rid = [dataDict objectForKey:@"id"];
            NSString *rname = [dataDict objectForKey:@"name"];
            NSString *rdesc = [dataDict objectForKey:@"description"];
            NSString *rtype = [dataDict objectForKey:@"type"];
            NSString *rkey = [dataDict objectForKey:@"key"];
            NSString *pid = [dataDict objectForKey:@"insideRegionId"];
            NSMutableArray *pois = [self parsePOIJson:[dataDict objectForKey:@"pointOfInterests"]];
            NSMutableArray *shapes = [self parseShapeJson:[dataDict objectForKey:@"shape"]];
            
            Region *region = [[Region alloc] initWithName:rname description:rdesc regionId:[rid intValue] parentId:[pid intValue] type:rtype key:rkey poiList:pois shapeList:shapes];
            
            /*
             Now Build a region tree with the given JSON data
             */
            [idToRegion setObject:region forKey:[NSNumber numberWithInt:[rid intValue]]];
            if(pid == nil) {
                // no parent. this is a root node.
                [rootRegions addObject:region];
                added++;
            } else {
                // has parent. this is a child node.
                Region *parent = [idToRegion objectForKey:[NSNumber numberWithInt:region.parentId]];
                if(parent) {
                    [region setParent:parent];
                    [parent addChild:region];
                    added++;
                } else {
                    // cannot assign at the moment
                    [tempRegions addObject:region];
                }
            }
        }
    
                                                
        /*
        try to add the delayed nodes
        */
        for (Region *delayedRegion in tempRegions) {
            delayed++;
            Region *parent = [idToRegion objectForKey:[NSNumber numberWithInt:delayedRegion.parentId]];
            if(parent) {
                [parent addChild:delayedRegion];
                [delayedRegion setParent:parent];
                added++;
            } else {
                // cannot assign at the moment
                DLog("No parent for ID[%d] found. Illegal tree detected. Removing Node/Subtree with ID[%d] and name[%@]", delayedRegion.parentId, delayedRegion.regionId, delayedRegion.name);
                errors++;
            }
        }
                           
        DLog("TreeBuild done: Added[%d], Delayed[%d], Errors[%d]", added, delayed, errors);
        tempRegions = nil;
        idToRegion = nil;
        
        //[self dumpTreeWithArray:rootRegions andLevel:0];
    }];
    
    [dataTask resume];
}

-(void)siteChanged:(NSNotification *)notification {
    DLog("Received Notification SiteChanged");
    
    if ([[notification name] isEqualToString:kNotificationSiteChanged]) {
        [self reload];
    }
}


-(NSMutableArray *)parsePOIJson:(NSArray *)pois {
    NSMutableArray *poiList = [[NSMutableArray alloc] init];
    for (NSDictionary *poiDict in pois) {
        NSString *pid = [poiDict objectForKey:@"id"];
        NSString *pname = [poiDict objectForKey:@"name"];
        NSString *pdesc = [poiDict objectForKey:@"description"];
        
        Location *loc = [self parseLocationJson:[poiDict objectForKey:@"location"]];
        
        PointOfInterest *poi = [[PointOfInterest alloc] initWithName:pname description:pdesc poiId:[pid intValue] location:loc];
        
        [poiList addObject:poi];
    }
    
    return poiList;
}



-(NSMutableArray *)parseShapeJson:(NSArray *)shapes {
    NSMutableArray *shapeList = [[NSMutableArray alloc] init];
    for (NSDictionary *shapeDict in shapes) {
        Location *loc = [self parseLocationJson:shapeDict];
        [shapeList addObject:loc];
    }
    
    return shapeList;
}


-(Location *)parseLocationJson:(NSDictionary *)dict {
    NSNumber *xCoord = [NSNumber numberWithFloat:[[dict objectForKey:@"x"] floatValue]];
    NSNumber *yCoord = [NSNumber numberWithFloat:[[dict objectForKey:@"y"] floatValue]];
    //DLog("[x:%@/y:%@]: ", xCoord, yCoord);
    
    return [[Location alloc] initWithXCoordinate:[xCoord floatValue] YCoordinate:[yCoord floatValue]];
}


/*
 debug method
 */
-(void)dumpTreeWithArray:(NSMutableArray *)array andLevel:(int)level {
    for (Region *rRegion in array) {
        NSString *indent = [@"-" stringByPaddingToLength:level withString:@"-" startingAtIndex:0];
        
        DLog("%@r[id:%i/%@]", indent, rRegion.regionId, rRegion.name);
        for(PointOfInterest *poi in rRegion.poiList) {
            DLog("     %@p[id:%i/%@]: ", indent, poi.poiId, poi.name);
        }
        
        for(Location *loc in rRegion.shapeList) {
            DLog("     %@s[x:%f/y:%f]: ", indent, loc.xCoordinate, loc.yCoordinate);
        }

        
        if([rRegion hasChilds]) {
            [self dumpTreeWithArray:rRegion.childs andLevel:++level];
        }
    }
}

-(NSMutableArray *)rootRegions {
    return rootRegions;
}

-(BOOL)hasChilds:(NSMutableArray *)regions {
    if(!regions) {
        regions = rootRegions;
    }
    
    if([regions count] > 0) {
        for(Region *r in regions) {
            if([r.childs count] > 0) {
                return YES;
            }
        }
    }
    
    return NO;
}

-(BOOL)hasPois:(NSMutableArray *)regions {
    if(!regions) {
        regions = rootRegions;
    }
    
    BOOL hasPois = NO;

    if([regions count] > 0) {
        for(Region *r in regions) {
            if([r.poiList count] > 0) {
                return YES;
            } else {
                return [self hasPois:r.childs];
            }
        }
    }
    
    return hasPois;
}

-(NSMutableArray *)allPoisForRegion:(Region *)region {
    if(!region) {
       return [self allPoisForRegions:rootRegions];
    }
    
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    [list addObject:region];
    return [self allPoisForRegions:list];
}

-(NSMutableArray *)allPoisForRegions:(NSMutableArray *)regions {
    if(!regions) {
        regions = rootRegions;
    }
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    if([regions count] > 0) {
        for(Region *r in regions) {
            [list addObjectsFromArray:r.poiList];
            [list addObjectsFromArray:[self allPoisForRegions:r.childs]];
        }
    }
    
    return list;
}

-(int)poiCount:(NSMutableArray *)regions {
    if(!regions) {
        regions = rootRegions;
    }
    
    int poiCount = 0;
    if([regions count] > 0) {
        for(Region *r in regions) {
            poiCount += [r.poiList count];
            poiCount += [self poiCount:r.childs];
        }
    }
    
    return poiCount;
}

-(int)shapeCount:(NSMutableArray *)regions {
    if(!regions) {
        regions = rootRegions;
    }
    
    int shapeCount = 0;
    if([regions count] > 0) {
        for(Region *r in regions) {
            shapeCount += [r.shapeList count];
            shapeCount += [self shapeCount:r.childs];
        }
    }

    return shapeCount;
}

-(int)regionCount:(NSMutableArray *)regions {
    if(!regions) {
        regions = rootRegions;
    }
    
    int regionCount = 0;
    if([regions count] > 0) {
        for(Region *r in regions) {
            regionCount += 1 + [self regionCount:r.childs];
        }
    }
    
    return regionCount;
}




-(CGSize)mapSize:(NSMutableArray *)regions {
    
    if(!regions) {
        regions = rootRegions;
    }
    
    CGSize ms = CGSizeMake(0,0);
    CGFloat xmap = 0;
    CGFloat ymap = 0;
    
    CGFloat xmin = MAXFLOAT;
    CGFloat ymin = MAXFLOAT;
    CGFloat xmax= 0;
    CGFloat ymax = 0;
    
    
    if([regions count] > 0) {
        for(Region *r in regions) {
            // we only handle rectangles so far, therefore calculate bounding-box first (safety measure)
            for(Location* location in r.shapeList) {
                if (location.xCoordinate < xmin) {
                    xmin = location.xCoordinate;
                }
                if (location.xCoordinate > xmax) {
                    xmax = location.xCoordinate;
                }
                if (location.yCoordinate < ymin) {
                    ymin = location.yCoordinate;
                }
                if (location.yCoordinate > ymax) {
                    ymax = location.yCoordinate;
                }
            }
        
            NSLog(@"Scale Rooms %f,%f,%f,%f",xmin,ymin,xmax,ymax);
            
            //scale map (scrollMapView.contentSize)
            if (xmap < xmax) {
                xmap = xmax;
            };
            if (ymap < ymax) {
                ymap = ymax;
            };
            
        }
    }

    xmap = xmap + 5; //BorderX for beacons
    ymap = ymap + 5; //BorderY for beacons
    
    NSLog(@"Map Size Generic %f, %f",xmap,ymap);
    ms = CGSizeMake(xmap,ymap);
    return ms;
}

-(void)reachabilityChanged:(NSNotification *)notification {
    Reachability *r = [notification object];
    if( [r isKindOfClass: [Reachability class]]) {
        NetworkStatus status = [r currentReachabilityStatus];
        switch(status) {
            case NotReachable:
                break;
            case ReachableViaWiFi:
                [self reload];
                break;
            case ReachableViaWWAN:
                [self reload];
                break;
            default:
                break;
        }
    }
}

-(void)requestDistanceUpdateWithDelegate:(id<RegionPOIDistanceDelegate>)delegate {
    if(lastPosition == nil) {
        DLog("Notifying caller about failed distanceUpdate - location is nil");
        [delegate distanceUpdateCompletedWithSuccess:NO regions:nil pointOfInterests:nil];
        return;
    }
    
        NSString* baseUrl = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingsUrl];
        NSString* distanceCall = [NSString stringWithFormat:@"%@%@", baseUrl, [NSString stringWithFormat:DISTANCE_API_CALL, site.siteId, lastPosition.xCoordinate, lastPosition.yCoordinate]];
        
        DLog(@"NetworkCall: %@", distanceCall);
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:distanceCall] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            DLog(@"%@", json);
            
            if (jsonError) {
                DLog("Notifying caller about failed distanceUpdate");
                [delegate distanceUpdateCompletedWithSuccess:NO regions:nil pointOfInterests:nil];
                return;
            }
            
            NSMutableDictionary *regionDict = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *poiDict = [[NSMutableDictionary alloc] init];
            
            NSMutableDictionary *tmpDict = [json objectForKey:@"regions"];
            if(tmpDict != nil) {
                for (NSMutableDictionary *dict in tmpDict) {
                    int rid = (int)[[dict objectForKey:@"id"] intValue];
                    NSString *rdouble = [dict objectForKey:@"distance"];
                    [regionDict setObject:rdouble forKey:[NSString stringWithFormat:@"%i", rid]];
                }
            }
            
            tmpDict = [json objectForKey:@"pois"];
            if(tmpDict != nil) {
                for (NSMutableDictionary *dict in tmpDict) {
                    int pid = (int)[[dict objectForKey:@"id"] intValue];
                    NSString *pdouble = [dict objectForKey:@"distance"];
                    [poiDict setObject:pdouble forKey:[NSString stringWithFormat:@"%i", pid]];
                }
            }
            
            if([regionDict count] > 0 && [poiDict count] > 0) {
                regionDistances = regionDict;
                poiDistances = poiDict;
                distanceDataFetched = ((long)[[NSDate date] timeIntervalSince1970]);
                
                if(delegate != nil) {
                    DLog("Notifying caller about successfull distanceUpdate");
                    [delegate distanceUpdateCompletedWithSuccess:YES regions:regionDistances pointOfInterests:poiDistances];
                }
            }
        }];
        
        [dataTask resume];
}

-(long)distanceDataAge {
    return distanceDataFetched;
}

- (void)positionUpdate:(NSNotification *) notification {
    if ([[notification name] isEqualToString:kNotificationPositionUpdate]) {
        NSDictionary* userInfo = notification.userInfo;
        Location *pos = [userInfo objectForKey:@"lastPosition"];
        
        if(pos != nil && !isnan(pos.xCoordinate) && !isnan(pos.yCoordinate)) {
            lastPosition = pos;
        }
    }
}
@end
