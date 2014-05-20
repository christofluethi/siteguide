//
//  PositionModeTableViewController.m
//  siteguide
//
//  Created by Christof Luethi on 12.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "PositionModeTableViewController.h"

@interface PositionModeTableViewController ()

@end

@implementation PositionModeTableViewController {
    NSArray* _positionModes;
    NSUInteger _selectedIndex;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* must be the same ordering as the values in constants.h*/
    /* that should be a list of PositionStrategies objects having a name propery - sometimes later */
    _positionModes = @[@"Proximity iOS", @"Trilateration iOS", @"Mixed iOS", @"Trilateration Server"];
    _selectedIndex = _positionMode;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_positionModes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PositionModeCell"];
    cell.textLabel.text = _positionModes[indexPath.row];
    
    if (indexPath.row == _selectedIndex) {
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
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)_selectedIndex] forKey:kSettingsPositionMode];
    DLog(@"Setting PositionMode to: %@", [[NSUserDefaults standardUserDefaults] stringForKey:kSettingsPositionMode]);
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    /*
     * the positioningMode should be set at one point only. appdelegate should not know all strategies
     * needs to be refactored. This code is also at AppDelegate.
     *
     * since we set a default value for PositionMode we are save here.
     */
    id strategy = nil;
    if(_selectedIndex == positionModeProximity) {
        strategy = [[ProximityStrategy alloc] init];
    } else if(_selectedIndex == positionModePosition) {
        strategy = [[TrilaterationStrategy alloc] init];
    } else if(_selectedIndex == positionModeMixed) {
        strategy = [[MixedStrategy alloc] init];
    } else if(_selectedIndex == positionModePositionServer) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NetworkStatus status = [[appDelegate getReachability] currentReachabilityStatus];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kSettingsLogging];
        
        if (status != ReachableViaWiFi) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Konnektivität" message:@"Sie haben den Positionierungs-Modus 'Trilateration Server' gewählt. In diesem Modus werden kontinuierlich Daten zum Server übertragen. Es wird empfohlen den Modus nur über ein Wireless Netzwerk zu verwenden." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
       
        [[SensorManager sharedInstance] restart];
        strategy = [[ServerPositionStrategy alloc] init];
    }
    
    [userInfo setObject:strategy forKey:@"strategy"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPositioningStrategyChanged object:self userInfo:userInfo];
    
    [self.delegate positionModeTableViewController:self didSelectPositionMode:&(_selectedIndex)];
}
@end
