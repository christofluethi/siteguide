//
//  SiteNameTableViewController.m
//  siteguide
//
//  Created by Christof Luethi on 17.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//


// http://aletschhorn.itds.ch:8888/TestCockpit/api/1/sites


#import "SiteNameTableViewController.h"

NSString* const SITE_API_CALL = @"/TestCockpit/api/1/sites";

@interface SiteNameTableViewController ()

@end

@implementation SiteNameTableViewController  {
    NSMutableArray* _sites;
    NSDictionary* dictionary;
    NSUInteger _selectedIndex;
    UIActivityIndicatorView *activity;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    NSString* baseUrl = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingsUrl];
    if(baseUrl == nil || [baseUrl length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Server nicht gefunden"
                            message:@"Es wurde kein SiteGuide Server konfiguriert. Bitte konfigurieren sie einen SiteGuide Server."
                            delegate:nil
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
        
        [alert show];
    } else {
        [self makeSiteNameRequest];
    }
}


-(void)makeSiteNameRequest {
    _sites = [[NSMutableArray alloc] init];
    
    NSString* baseUrl = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingsUrl];
    NSString* siteNameCall = [NSString stringWithFormat:@"%@%@", baseUrl, SITE_API_CALL];
    
    DLog(@"NetworkCall: %@", siteNameCall);
    [activity startAnimating];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:siteNameCall] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        DLog(@"%@", json);
        
        if (jsonError) {
            NSString* msg = [NSString stringWithFormat:@"Der konfigurierte Server '%@' ist kein SiteGuide Server oder steht im Moment nicht zur Verfügung. Bitte Versuchen Sie es später noch einmal.", baseUrl];
            DLog(@"Error fetching JSON: %@", [jsonError localizedDescription]);
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Server error"
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
            return;
        }
        
        // fill up new site
        for (NSDictionary *dataDict in json) {
            NSString *sid = [dataDict objectForKey:@"id"];
            NSString *sname = [dataDict objectForKey:@"name"];
            NSArray *uuids = [dataDict objectForKey:@"beacon_uuids"];
            
            // default and fallback UUID, should be removed, chl 2014-02-26
            NSString *uuid = @"DBAC24C5-8B8B-451D-A285-CC380C651F77";
            for (int i = 0; i < [uuids count]; i++) {
                NSString *uid = [uuids objectAtIndex:i];
                NSUUID *validUuid = [[NSUUID alloc] initWithUUIDString:uid];
                if(validUuid) {
                    uuid = uid;
                    break;
                }
            }
            
            Site *availableSite = [[Site alloc] initWithName:sname siteId:[sid intValue] beaconUUID:uuid];
            
            //dictionary = [NSDictionary dictionaryWithObjectsAndKeys:sid, siteid, sname, name, nil];
            [_sites addObject:availableSite];
        }
        
        /* dispatch async needed for displaying cells correctly - if not applied the cells are only refreshed if you scroll */
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [activity stopAnimating];
        });
    }];
    
    [dataTask resume];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Vorhandene Sites";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SiteNameCell"];
    
    Site *curSite = [_sites objectAtIndex:indexPath.row];
    cell.textLabel.text = curSite.name;
    
    /* check if strings are equal */
    if([curSite.name isEqualToString:_selectedSite.name]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_selectedIndex != NSNotFound) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    _selectedIndex = indexPath.row;
    Site *curSite = [_sites objectAtIndex:indexPath.row];

    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:curSite];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:kSettingsSite];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSiteChanged object:self userInfo:nil];

    [self.delegate siteNameTableViewController:self didSelectSite:curSite];
}
@end
