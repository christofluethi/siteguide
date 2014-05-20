//
//  POIListTableViewController.h
//  SiteGuide
//
//  Created by Christof Luethi on 03.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Region.h"
#import "RegionManager.h"
#import "ContentViewController.h"
#import "DocumentTableViewController.h"
#import "SortTableViewController.h"
#import "MapViewController.h"
#import "ToastView.h"

@interface POIListTableViewController : UITableViewController<SortTableViewControllerDelegate, RegionPOIDistanceDelegate>
@property (nonatomic, strong) NSMutableArray* regions;
@property (nonatomic, strong) NSMutableArray* pois;
@property (nonatomic, strong) NSString *regionName;

-(void)distanceUpdateCompletedWithSuccess:(BOOL)success regions:(NSMutableDictionary *)regions pointOfInterests:(NSMutableDictionary *)pois;
-(void)refreshTable;
@end
