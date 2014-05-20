//
//  PositionDebugViewController.m
//  SiteGuide
//
//  Created by Christof Luethi on 27.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "PositionDebugViewController.h"



@implementation PositionDebugViewController {
    UILabel *nearestBeacon;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *positionData = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, 200, 20)];
    [positionData setBackgroundColor:[UIColor clearColor]];
    [positionData setText:@"Positions Information"];
    [[self view] addSubview:positionData];
    
    RegionManager *manager = [RegionManager sharedInstance];
    
    UILabel *regions = [[UILabel alloc]initWithFrame:CGRectMake(10, 90, 200, 20)];
    [regions setBackgroundColor:[UIColor clearColor]];
    [regions setText:[NSString stringWithFormat:@"Regions: %i", [manager regionCount:nil]]];
    [[self view] addSubview:regions];
    
    UILabel *pois = [[UILabel alloc]initWithFrame:CGRectMake(10, 120, 200, 20)];
    [pois setBackgroundColor:[UIColor clearColor]];
    [pois setText:[NSString stringWithFormat:@"POIs: %i", [manager poiCount:nil]]];
    [[self view] addSubview:pois];
    
    UILabel *shapes = [[UILabel alloc]initWithFrame:CGRectMake(10, 150, 200, 20)];
    [shapes setBackgroundColor:[UIColor clearColor]];
    [shapes setText:[NSString stringWithFormat:@"Shapes: %i", [manager shapeCount:nil]]];
    [[self view] addSubview:shapes];
    
    UILabel *beacons = [[UILabel alloc]initWithFrame:CGRectMake(10, 180, 200, 20)];
    UIFont *openSansFont = [UIFont fontWithName:@"OpenSans" size:16];
    beacons.font = openSansFont; // test für CustomFont
    [beacons setBackgroundColor:[UIColor clearColor]];
    [beacons setText:@"Beacons:"];
    [[self view] addSubview:beacons];
    
    UILabel *mapSize = [[UILabel alloc]initWithFrame:CGRectMake(10, 300, 200, 20)];
    [mapSize setBackgroundColor:[UIColor clearColor]];
    [mapSize setText:[NSString stringWithFormat:@"MapSize: %@", NSStringFromCGSize([manager mapSize:nil])]];
    [[self view] addSubview:mapSize];
    
    UILabel *posLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 360, 200, 20)];
    [posLabel setBackgroundColor:[UIColor clearColor]];
    [posLabel setText:@"Current Position"];
    [[self view] addSubview:posLabel];
    
    nearestBeacon = [[UILabel alloc]initWithFrame:CGRectMake(10, 390, 200, 20)];
    [nearestBeacon setBackgroundColor:[UIColor clearColor]];
    [nearestBeacon setText:@"unknown"];
    [[self view] addSubview:nearestBeacon];
    
    // [self listAllFonts]; // Debug
}

- (void)positionUpdate:(NSNotification *) notification {
    if ([[notification name] isEqualToString:kNotificationPositionUpdate]) {
        NSDictionary* userInfo = notification.userInfo;
        Location *pos = [userInfo objectForKey:@"lastPosition"];
        
        nearestBeacon.text = [NSString stringWithFormat:@"X:%.2f Y:%.2f Z:%.2f", pos.xCoordinate, pos.yCoordinate, pos.zCoordinate];
    }
}

/* attach notification whenever the view will appear */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(positionUpdate:) name:kNotificationPositionUpdate object:nil];
}

/* the view is not active. we do not need the notification */
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/* List all installed fonts on iPhone to NSLog */
- (void) listAllFonts {
    
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
    {
        DLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames = [[NSArray alloc] initWithArray:
                     [UIFont fontNamesForFamilyName:
                      [familyNames objectAtIndex:indFamily]]];
        for (indFont=0; indFont<[fontNames count]; ++indFont)
        {
            DLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
        }
        
    }
}

 
@end