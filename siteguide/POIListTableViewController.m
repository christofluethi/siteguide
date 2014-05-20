//
//  POIListTableViewController.m
//  SiteGuide
//
//  Created by Christof Luethi on 03.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "POIListTableViewController.h"

/**
 Content Browsing View
 
 Storyboard has some limitations:
 - its not possible to have two BarButtonItems in the right area using storyboards.
 - Its not possible to do recursive segues to the same view controller AND a segue to another view controller. creating a 
 recursive segue from a table may be done by linking the cell prototype to the view controller. however, if done you cannot
 create another segue from the viewcontroller to another view controller for actions of the table cell.
 */

#define ROW_HEIGHT_TABLE_CELL 50

@implementation POIListTableViewController {
    NSUInteger _selectedIndex;
    BOOL hasNodes;
    BOOL hasPois;
    BOOL hasChilds;
    BOOL hasChildPois;
    PointOfInterest *selectedPoi;
    NSSortDescriptor *sortDescriptor;
    NSMutableDictionary *regionDistances;
    NSMutableDictionary *poiDistances;
    UIActivityIndicatorView *activity;
    UIRefreshControl *refreshControl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    RegionManager *manager = [RegionManager sharedInstance];
    if(!_regions) {
        _regions = [manager rootRegions];
        _pois = [manager allPoisForRegions:_regions];
        NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsSite];
        if(encodedObject) {
            Site *site = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
            self.title = site.name;
        }
    } else {
        if(_regionName) {
            self.title = _regionName;
        }
    }
    
    /* activity indicator */
    CGRect frame = CGRectMake (120.0, 185.0, 80, 80);
    
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activity setFrame:frame];
    
    activity.hidesWhenStopped = YES;
    
    activity.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:activity];
    /* end activity indicator */
    
    /* refresh indicator */
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:refreshControl];
    /* end refresh indicator */
    
    
    /* bar button - Its not possible to have two rightbar buttons in the navigation bar using storyboards */
    UIImage *sortImage = [UIImage imageNamed:@"barIconSort.png"];
    UIButton *sort = [UIButton buttonWithType:UIButtonTypeCustom];
    sort.bounds = CGRectMake( 50, 50, sortImage.size.width, sortImage.size.height );
    [sort setImage:sortImage forState:UIControlStateNormal];
    [sort addTarget:self action:@selector(flipToSortView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithCustomView:sort];
    
    UIImage *mapImage = [UIImage imageNamed:@"barIconMap2.png"];
    UIButton *map = [UIButton buttonWithType:UIButtonTypeCustom];
    map.bounds = CGRectMake( 50, 50, 25,25 );
    [map setImage:mapImage forState:UIControlStateNormal];
    [map addTarget:self action:@selector(flipToMapView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithCustomView:map];
    
    self.navigationItem.rightBarButtonItems = @[mapButton, sortButton];
    /* end bar button */
    
    hasNodes = ([_regions count] > 0);
    hasPois = ([_pois count] > 0);
    hasChilds = [manager hasChilds:_regions];
    hasChildPois = [manager hasPois:_regions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(hasNodes && section == 0) {
        return @"Region";
    } else {
        return @"Point of Interest";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(hasNodes && hasPois) {
        return 2;
    } else {
        return 1;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(hasNodes && section == 0) {
        unsigned long c = [_regions count];
        return c;
    } else if(hasNodes && section == 1) {
        unsigned long c = [_pois count];
        return c;
    } else {
        unsigned long c = [_pois count];
        return c;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    
    static NSString *CellIdentifier = @"RegionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    if(hasNodes && section == 0) {
        Region *region = [_regions objectAtIndex:indexPath.row];
        cell.textLabel.text = region.name;
        if(region.description != (id)[NSNull null]) {
            cell.detailTextLabel.text = region.description;
        } else {
            cell.detailTextLabel.text = @"";
        }
        if([region.childs count] > 0 || [region.poiList count] > 0) {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
    } else {
        PointOfInterest *poi = [_pois objectAtIndex:indexPath.row];
        cell.textLabel.text = poi.name;
        if(poi.description != (id)[NSNull null]) {
            cell.detailTextLabel.text = poi.description;
        } else {
            cell.detailTextLabel.text = @"";
        }
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _selectedIndex = indexPath.row;
    
    if(hasNodes && [indexPath section] == 0) {
        Region *r = [_regions objectAtIndex:_selectedIndex];
        if([r.childs count] > 0 || [r.poiList count] > 0) {
            [self pushToRegion:[_regions objectAtIndex:_selectedIndex]];
        } else {
            
            // UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath]; // Toast should be added to cell view, currently it ist attached to them TableViewController
            [ToastView showToastInParentView:self.parentViewController.view withText:@"Für die selektierte Region sind keine Dokumente hinterlegt!" withDuaration:2.0];
            return;
        }
    } else if (!hasPois && !hasChilds) {
               return;
    } else if ((hasNodes && [indexPath section] == 1) || (!hasNodes && [indexPath section] == 0)) {
        [self performSegueWithIdentifier:@"ShowDocuments" sender:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT_TABLE_CELL;
}
-(IBAction)pushToRegion:(Region*)region {
    POIListTableViewController *poiListTableViewController = (POIListTableViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ListNavigation"];

    poiListTableViewController.regionName = region.name;
    poiListTableViewController.regions = [region childs];
    poiListTableViewController.pois = [[RegionManager sharedInstance] allPoisForRegion:region];
    [self.navigationController pushViewController:poiListTableViewController animated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowDocuments"]) {
        DocumentTableViewController *documentViewController = segue.destinationViewController;
        documentViewController.poi = [_pois objectAtIndex:_selectedIndex];
    } else if ([segue.identifier isEqualToString:@"ShowSort"]) {
        SortTableViewController *sortController = segue.destinationViewController;
        sortController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ShowMap"]) {
        /* no setup needed, just perform the ShowMap segue */
        DLog("Flipping to MAP View");
    }
}

/**
 Between POIListTableViewController and MapViewController view there is a view flip machanism.
 Since this is could result in a loop for the navigation-controller we need to detect if we are pushed
 from the MapViewController.
 
 If yes, pop the MapViewController. If Not, its a regular transition to the MapViewController.
 */
-(void)flipToMapView {
    if([self backViewIsMapView]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self performSegueWithIdentifier:@"ShowMap" sender:self];
    }
}

/**
 Return true if an only if our back-ViewController is the MapViewController
 Should be implemented more generic and centralized using a parameter for the class.
 */
- (BOOL)backViewIsMapView {
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    
    if(numberOfViewControllers >= 2) {
        UIViewController *c = [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
        if([c isKindOfClass:[MapViewController class]]) {
            return YES;
        }
    }
    
    return NO;
}

-(void)flipToSortView {
    [self performSegueWithIdentifier:@"ShowSort" sender:self];
}

-(void)sortTableViewController:(SortTableViewController *)controller didSelectSort:(int)sort {
    /* we do not need to take specific actions. we load the sort value from the userdefaults whenever the viewWillAppear method is called. */
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSSortDescriptor *)sortDescriptorForSortMode:(int)sort {
    if(sort == sortModeNameDescending) {
        return [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    } else if(sort == sortModeDistance) {
        return [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    }  else {
        return [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    }
}

/* attach notification whenever the view will appear */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshTable];
    
}

-(void)refreshTable {
    int mode = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsSortMode];
    sortDescriptor = [self sortDescriptorForSortMode:mode];
    
    if(mode == sortModeDistance) {
        [activity startAnimating];
        [[RegionManager sharedInstance] requestDistanceUpdateWithDelegate:self];
    } else {
        [_regions sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [_pois sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [self.tableView reloadData];
    }
    
    [refreshControl endRefreshing];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)distanceUpdateCompletedWithSuccess:(BOOL)success regions:(NSMutableDictionary *)regions pointOfInterests:(NSMutableDictionary *)pois {
    dispatch_async(dispatch_get_main_queue(), ^{
        [activity stopAnimating];
    });
    
    if(!success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Keine Position" message:@"Es steht Momentan noch keine Position zur Sortierung nach Distanz zur Verfügung. Bitte versuchen Sie es später noch einmal." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
            [alert show];
        });
        
        return;
    }
    
    for (int i = 0; i < [_regions count]; i++) {
        Region *r = [_regions objectAtIndex:i];
        NSString *d = [regions objectForKey:[NSString stringWithFormat:@"%i", r.regionId]];
        [r setDistance:[d doubleValue]];
    }
    
    for (int i = 0; i < [_pois count]; i++) {
        PointOfInterest *p = [_pois objectAtIndex:i];
        NSString *d = [pois objectForKey:[NSString stringWithFormat:@"%i", p.poiId]];
        [p setDistance:[d doubleValue]];
    }
    
    /* dispatch async needed for displaying cells correctly - if not applied the cells are only refreshed if you scroll */
    dispatch_async(dispatch_get_main_queue(), ^{
        [_regions sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [_pois sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [self.tableView reloadData];
    });
}

@end
