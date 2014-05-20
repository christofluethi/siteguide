//
//  MapViewController.m
//  siteguide
//
//  Created by Stefan Wagner on 03.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "MapViewController.h"
@implementation MapViewController{
NSMutableArray* regionList;
NSMutableArray* pois;
NSMutableArray* beacons;
CGSize regionSize;
float minZoomScaleWidht;
float minZoomScaleHeight;
float minZoomScale;
PointOfInterest *selectedPoi;
PointOfInterest *tappedPoi;
Beacon *tappedBeacon;
Region *tappedRoom;
UIButton *btnPosition;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.scrollMapView removeFromSuperview]; // remove any old scroll view from view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(positionUpdate:) name:kNotificationPositionUpdate object:nil];
    
    regionList = [[RegionManager sharedInstance] rootRegions];
    regionSize = [[RegionManager sharedInstance] mapSize:regionList] ;
    
    DLog(@"RegionSize%@", NSStringFromCGSize(regionSize));
    minZoomScaleWidht =  self.view.bounds.size.width/(regionSize.width+BorderX);
    minZoomScaleHeight = self.view.bounds.size.height/(regionSize.height+BorderY);
    minZoomScale = 0;
    
    if (minZoomScaleHeight < minZoomScaleWidht)
    {minZoomScale=minZoomScaleHeight;}
    else {minZoomScale = minZoomScaleWidht;}; // Scale according widht or hight minimum
    
    self.scrollMapView = [[UIScrollView alloc] initWithFrame:self.view.bounds]; // allocate a new Scrollview the same size as current view
    DLog(@"ViewBounds, %f, %f", self.view.bounds.size.width,self.view.bounds.size.height);
    
    
    self.scrollMapView.contentSize = CGSizeMake(regionSize.width*ScaleMap_X,regionSize.height*ScaleMap_Y); // set size of scroll-Area
    self.scrollMapView.pagingEnabled = false;
    self.scrollMapView.delegate = self;
    self.scrollMapView.maximumZoomScale = 2.0;
    self.scrollMapView.minimumZoomScale = minZoomScale /ScaleMap_X; // allow to zoom-out by factor 2
    self.scrollMapView.backgroundColor = colorMapBackground;
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, regionSize.width*ScaleMap_X,regionSize.height*ScaleMap_Y)]; // add content view which is the basis for scaling
    
    [self.scrollMapView addSubview:self.contentView]; // add base view to scroll-view
    
    self.scrollMapView.zoomScale = 0.62; // initial scale
    
    //draw Map
    [self drawRegions];
    [self drawBeacons];
    [self drawPosition];
    [self drawPois];
    
    
    // Empty content frame for map
    self.scrollMapView.contentInset = (UIEdgeInsets){
        .top = 10,
        .bottom = 10,
        .left = 10,
        .right = 10
    };
    
    [self.view addSubview:self.scrollMapView]; // finally add new scrollview to main view
    
    /* bar button */
    UIImage *listImage = [UIImage imageNamed:@"barIconList2.png"];
    UIButton *list = [UIButton buttonWithType:UIButtonTypeCustom];
    list.bounds = CGRectMake( 50, 50, 26, 26 );
    [list setImage:listImage forState:UIControlStateNormal];
    [list addTarget:self action:@selector(flipToListView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithCustomView:list];
    
    self.navigationItem.rightBarButtonItem = listButton;
}

-(void)viewWillAppear:(BOOL)animated {

    

}

/**
 Between MapViewController and POIListTableViewController view there is a view flip machanism.
 Since this is could result in a loop for the navigation-controller we need to detect if we are pushed
 from the POIListTableViewController.
 
 If yes, pop the POIListTableViewController. If Not, its a regular transition to the POIListTableViewController.
 */
-(void)flipToListView {
    [self performSegueWithIdentifier:@"ShowDocumentsForTappedRoom" sender:self];
}

/**
 Return true if an only if our back-ViewController is the POIListTableViewController
 Should be implemented more generic and centralized using a parameter for the class.
 */
- (BOOL)backViewIsListView {
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    
    if(numberOfViewControllers >= 2) {
        UIViewController *c = [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
        if([c isKindOfClass:[POIListTableViewController class]]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)roomTapped:(UIButton*)room {
    DLog(@"Room # %ld tapped",(long)room.tag);
    
    
    tappedRoom = nil;
    long int numberofPois = 0;
    
    for (Region* roomInList in regionList){
        if (roomInList.regionId == room.tag) {
            DLog(@"Tapped Poi %i",roomInList.regionId);
            tappedRoom = roomInList;
            numberofPois = roomInList.poiList.count;
        }
    }
    
    if ((tappedRoom) && (numberofPois > 0)){
    [self performSegueWithIdentifier:@"ShowDocumentsForTappedRoom" sender:self];
    }
    else {
        [ToastView showToastInParentView:self.parentViewController.view withText:@"Für das selektierte Zimmer sind keine Dokumente hinterlegt!" withDuaration:2.0];
        DLog(@"Room Key ,%@", tappedRoom.key );
    }
    
    
}

- (void)poiTapped:(UIButton*)poi {
    DLog(@"Poi # %ld tapped",(long)poi.tag);
    
    tappedPoi = nil;
    
    for (PointOfInterest* poiInList in pois){
        if (poiInList.poiId == poi.tag) {
            DLog(@"Tapped Poi %i",poiInList.poiId);
            tappedPoi = poiInList;
        }
    }

    if (tappedPoi) {
      [self performSegueWithIdentifier:@"ShowDocumentsForTappedPoi" sender:self];
    }
}


- (void)beaconTapped:(UIButton*)beacon {
    DLog(@"Beacon # %ld tapped",(long)beacon.tag);
    
    tappedBeacon = nil;
    
    
    BeaconManager *manager;
    manager = [BeaconManager sharedInstance];
    NSArray* beaconList = [manager beacons];
    
    
    for (Beacon* b in beaconList){
        if (b.beaconId == beacon.tag) {
            DLog(@"Tapped Beacon %i",b.beaconId);
        
            
            [ToastView showToastInParentView:self.parentViewController.view withText:[NSString stringWithFormat:@"Beacon %@,\r\n ID %d, %d, %d  ",b.name, b.beaconId, b.major, b.minor] withDuaration:2.0];

        }
    }
    
    if (tappedBeacon) {
        [self performSegueWithIdentifier:@"ShowDocumentsForTappedPoi" sender:self];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowDocumentsForTappedPoi"]) {
        DocumentTableViewController *documentViewController = segue.destinationViewController;
        documentViewController.poi = tappedPoi;
    } else if ([segue.identifier isEqualToString:@"ShowDocumentsForTappedRoom"]) {
        if(tappedRoom) {
            POIListTableViewController *poiListTableViewController = segue.destinationViewController;
            poiListTableViewController.regionName = tappedRoom.name;
            poiListTableViewController.regions = [tappedRoom childs];
            poiListTableViewController.pois = [[RegionManager sharedInstance] allPoisForRegion:tappedRoom];
            tappedRoom = nil;
        }
    }
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)didReceiveMemoryWarningn
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)drawPois {
    /* add pois to map */
    RegionManager *manager = [RegionManager sharedInstance];
    pois = [manager allPoisForRegions:Nil];
    DLog(@"PoiCount Drawing %i",[manager poiCount:Nil]);
    
    
    for (PointOfInterest* poi in pois){
        
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];

            int pox = ((poi.location.xCoordinate*ScaleMap_X)-poiSizeX/2.0); // center on coordinate
            int poy = ((poi.location.yCoordinate*ScaleMap_Y)-poiSizeY/2.0); // center on coordinate
            int psx = poiSizeX;
            int psy = poiSizeY;
        
            DLog(@"Poi Position,%f,%f",poi.location.xCoordinate,poi.location.yCoordinate);
            button.frame = CGRectMake(pox,poy,psx,psy); //placement on map
            button.layer.borderWidth = 0.0f; // add a border around the poi
            button.showsTouchWhenHighlighted = TRUE;
            button.layer.borderColor = colorButtonBorder; // and color the border
            button.tag = poi.poiId; // tag to later identify the poi
            [button setImage:[UIImage imageNamed:@"SG_POI_i_filled_brightblue.png"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"SG_POI_i_filled_brightblue.png"] forState:UIControlStateNormal];
            //button.titleLabel.font = fontOpenSansRegular;
            [button setTitle: @"i" forState:UIControlStateNormal]; // text for label --> number of documents in poi
            //DLog(@"Anzahl Docs in Poi %lu",(unsigned long)poi.documents.);
            [button setTitleColor: colorTitle forState:UIControlStateNormal]; // text color for label
            [button addTarget:self action:@selector(poiTapped:) forControlEvents:UIControlEventTouchUpInside]; // touch on button should be handeled by "poiTapped" method
            [self.contentView addSubview:button]; // add room to content-view (which itself is within scroll area)

    }
}

- (void) drawBeacons{
    
    BOOL showBeacons = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsShowBeacon];
    if(showBeacons) {
        
        /* add beacocn to map */

        BeaconManager *manager;
        manager = [BeaconManager sharedInstance];
        NSArray* beaconList = [manager beacons];
    
    
        for (Beacon* b in beaconList){
        
            UIButton* btnBeacon = [UIButton buttonWithType:UIButtonTypeCustom];
        
            DLog(@"Beacon Position,%f,%f",b.location.xCoordinate*ScaleMap_Y,b.location.yCoordinate*ScaleMap_Y);
            btnBeacon.frame = CGRectMake(b.location.xCoordinate*ScaleMap_Y-beaconSizeX/2,b.location.yCoordinate*ScaleMap_Y-beaconSizeY/2,beaconSizeX,beaconSizeY); //placement on map
            btnBeacon.layer.borderWidth = 0.0f; // add a border around the beacon
            btnBeacon.showsTouchWhenHighlighted = true;
            btnBeacon.layer.borderColor = [UIColor blackColor].CGColor; // and color the border
            btnBeacon.backgroundColor = colorBeaconBackground; //
            btnBeacon.tag = b.beaconId; // tag to later identify the poi
            btnBeacon.adjustsImageWhenHighlighted = NO;
            [btnBeacon setImage:[UIImage imageNamed:@"SG_iBeacon_white.png"] forState:UIControlStateNormal];
            [btnBeacon setBackgroundImage:[UIImage imageNamed:@"SG_iBeacon_white.png"] forState:UIControlStateNormal];
            btnBeacon.titleLabel.font = [UIFont systemFontOfSize:10]; // set font for label
            btnBeacon.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [btnBeacon setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; // text color for label
            [btnBeacon addTarget:self action:@selector(beaconTapped:)  forControlEvents:UIControlEventTouchUpInside]; // touch on button should be handeled by "beaconTapped" method
            [self.contentView addSubview:btnBeacon]; // add beacon to content-view (which itself is within scroll area)
        }
    }
}

- (void)drawPosition {
    /* add position markert to map */
    btnPosition = [UIButton buttonWithType:UIButtonTypeCustom];
    //DLog(@"My Position,%f,%f",poi.location.xCoordinate,poi.location.yCoordinate);
    btnPosition.frame = CGRectMake(-100,-100,50,50); //placement on map
    btnPosition.layer.borderWidth = 0.0f; // add a border around the poi
    btnPosition.showsTouchWhenHighlighted = true;
    //btnPosition.layer.borderColor = [UIColor blackColor].CGColor; // and color the border
    btnPosition.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.5 alpha:0.0]; // background color
    btnPosition.adjustsImageWhenHighlighted = NO;
    [btnPosition setImage:[UIImage imageNamed:@"SG_MapPoint02.png"] forState:UIControlStateNormal];
    [btnPosition setBackgroundImage:[UIImage imageNamed:@"SG_MapPoint02.png"] forState:UIControlStateNormal];
    btnPosition.titleLabel.font = [UIFont systemFontOfSize:10]; // set font for label
    btnPosition.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [btnPosition setBackgroundImage:[self imageWithColor:[UIColor lightGrayColor]]forState:UIControlStateHighlighted];
    //[btnPosition setTitle:poi.name forState:UIControlStateNormal]; // text for label
    [btnPosition setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; // text color for label
    [btnPosition addTarget:self action:@selector(poiTapped:)  forControlEvents:UIControlEventTouchUpInside]; // touch on button should be handeled by "poiTapped" method
    [self.contentView addSubview:btnPosition]; // add position to content-view (which itself is within scroll area)
}

- (void)drawRegions // Region = Room
{
    /* Add Rooms to map (called Regions) */
    
    for (Region* region in regionList) {
        // we only handle rectangles so far, therefore calculate bounding-box first (safety measure)
        CGFloat xmin = MAXFLOAT;
        CGFloat ymin = MAXFLOAT;
        CGFloat xmax= 0;
        CGFloat ymax = 0;
        for(Location* location in region.shapeList) {
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
        
        UIButton* room = [UIButton buttonWithType:UIButtonTypeCustom];
        room.frame = CGRectMake(xmin*ScaleMap_X, ymin*ScaleMap_Y, (xmax - xmin)*ScaleMap_X, (ymax - ymin)*ScaleMap_Y); //placement on map
        room.layer.borderWidth = roomBorderWidth; // 8.0f; // add a border around the room
        room.layer.borderColor = [UIColor colorWithRed:219.0/255.0 green:225.0/255.0 blue:228.0/255.0 alpha:1.0].CGColor;
        room.showsTouchWhenHighlighted = true;
        

        
        if (region.isRoom) {
            room.backgroundColor = colorRoomNoDocument;
        }


        if (region.poiList.count > 0) {

            room.backgroundColor = colorRoomWithDocument;
            room.enabled = true;
        }
        else {
            room.enabled = true;
        }
        
        
        if (region.isArea) {
            room.backgroundColor = colorRegionArea;
        }
        
        if (region.isOther) {
            room.backgroundColor = colorRegionOther;
        }
        
        
        room.tag = region.regionId; // tag to later identify the room
        room.titleLabel.font = [UIFont systemFontOfSize:14]; // set font for label
        room.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [room setBackgroundImage:[self imageWithColor:[UIColor lightGrayColor]]forState:UIControlStateHighlighted];
        

        
        //[ToastView showToastInParentView:self.parentViewController.view StringwithText:[NSString stringWithFormat:@"Beacon %@,\r\n ID %d, %d, %d  ",b.name, b.beaconId, b.major, b.minor] withDuaration:2.0];
        
        [room setTitle:region.key forState:UIControlStateNormal]; // text for label
        
        // 2 Lines for RoomID and RommTitel
        if ((xmax-xmin) > 10) {
            [room setTitle: [NSString stringWithFormat: @"%@",region.name]forState:UIControlStateNormal]; // text for label
        } else
            [room setTitle:region.key forState:UIControlStateNormal]; // text for label
        
        [room setTitleColor:[UIColor colorWithRed:220.0 green:225.0 blue:228.0 alpha:1.0] forState:UIControlStateNormal]; // text color for label
        [room addTarget:self action:@selector(roomTapped:)  forControlEvents:UIControlEventTouchUpInside]; // touch on button should be handeled by "roomTapped" method
        [self.contentView addSubview:room]; // add room to content-view (which itself is within scroll area)
        
    };
}



- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)positionUpdate:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:kNotificationPositionUpdate]) {
        NSDictionary* userInfo = notification.userInfo;
        Location *pos = [userInfo objectForKey:@"lastPosition"];
        
        
        if (isnan (pos.xCoordinate) || isnan(pos.yCoordinate))
        {
            // This means the dictionary does not contain it
            DLog (@"No new position found");
        }
        else
        {
            CGRect newFrame = btnPosition.frame;
            DLog(@"Old Position: %@", NSStringFromCGRect(newFrame));
            newFrame.origin.x  = pos.xCoordinate*ScaleMap_X;
            newFrame.origin.y  = pos.yCoordinate*ScaleMap_Y;
            newFrame.origin.x -=  newFrame.size.width/2; // Offset 1/2 Icon Size
            newFrame.origin.y -=  newFrame.size.height/2;
            DLog(@"New Position: %@", NSStringFromCGRect(newFrame));
            btnPosition.frame = newFrame;
            
            if (newFrame.origin.x < 0)
                {newFrame.origin.x = 0;
                 DLog(@"Position X0: %@", NSStringFromCGRect(newFrame));
                };
            if (newFrame.origin.y < 0)
                {newFrame.origin.y = 0;
                 DLog(@"Position Y0: %@", NSStringFromCGRect(newFrame));
                };
            if (newFrame.origin.x > regionSize.width)
                {newFrame.origin.x = regionSize.width;};
            if(newFrame.origin.y > regionSize.height)
                {newFrame.origin.y = regionSize.height;};

        }
        
    }
}

-(void)viewWillDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
