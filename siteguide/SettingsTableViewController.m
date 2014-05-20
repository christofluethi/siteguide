//
//  SettingsTableViewController.m
//  siteguide
//
//  Created by Christof Luethi on 11.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "SettingsTableViewController.h"

@implementation SettingsTableViewController {
    NSUserDefaults* defaults;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    [_loggingSwitch addTarget:self action:@selector(action:) forControlEvents:UIControlEventValueChanged];
    [_urlTextfield addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingDidEnd];
    
    _urlTextfield.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSData *encodedObject = [defaults objectForKey:kSettingsSite];
    if(encodedObject) {
        Site *sSite = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        self.siteNameLabel.text = sSite.name;
    }
    
    NSString* currentUrl = [defaults stringForKey:kSettingsUrl];
    if([currentUrl length] > 0) {
        _urlTextfield.text = currentUrl;
    }
    
    if([defaults boolForKey:kSettingsLogging] == true) {
        _loggingSwitch.on = YES;
    } else {
        _loggingSwitch.on = NO;
    }
    
    NSInteger smode = [defaults integerForKey:kSettingsSimulationMode];
    self.simulationModeLabel.text = [self simulationModeToName:(NSUInteger *)smode];
    
    NSInteger pmode = [defaults integerForKey:kSettingsPositionMode];
    self.positionModeLabel.text = [self positionModeToName:(NSUInteger *)pmode];
    
    int x = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsDebugXCoord];
    int y = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsDebugYCoord];

    _debugPositionLabel.text = [NSString stringWithFormat:@"%i/%i", x, y];
    
    BOOL isDebug = [defaults boolForKey:kSettingsIsDebug];
    _debugSwitch.on = isDebug;
    
    BOOL isDebugPosition = [defaults boolForKey:kSettingsIsDebugPosition];
    _debugPositionSwitch.on = isDebugPosition;
    
    BOOL showBeacons = [defaults boolForKey:kSettingsShowBeacon];
    _showBeaconSwitch.on = showBeacons;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([segue.identifier isEqualToString:@"PickPositionMode"]) {
        PositionModeTableViewController *positionModeTableViewController = segue.destinationViewController;
        positionModeTableViewController.delegate = self;
        positionModeTableViewController.positionMode = [defaults integerForKey:kSettingsPositionMode];
    } else if ([segue.identifier isEqualToString:@"PickSite"]) {
        SiteNameTableViewController *siteNameTableViewController = segue.destinationViewController;
        siteNameTableViewController.delegate = self;
        NSData *encodedObject = [defaults objectForKey:kSettingsSite];
        Site *sSite = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        siteNameTableViewController.selectedSite = sSite;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)action:(id)sender
{
    if(sender == _loggingSwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:_loggingSwitch.isOn forKey:kSettingsLogging];
        DLog(@"Logging: %s", [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsLogging] ? "ON" : "OFF");
        [[SensorManager sharedInstance] restart];
        
        int pmode = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsPositionMode];
        
        if(_loggingSwitch.isOn == NO && pmode == positionModePositionServer) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Positionierungs Modus" message:@"Sie verwenden den Positionierungs-Modus 'Trilateration Server'. Durch das Ausschalten des Sendens der Daten an den Server werden keine aktuellen Positionsinformationen mehr vom Server zur Verfügung gestellt. Aktivieren Sie das Server Logging wieder um die Positionierung zu reaktivieren oder ändern Sie den Positionierungs-Modus." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
    }
}

-(void)textFieldChanged:(id)sender
{
    if(sender == _urlTextfield) {
       [[NSUserDefaults standardUserDefaults] setObject:_urlTextfield.text forKey:kSettingsUrl];
       DLog(@"URL: %@", [[NSUserDefaults standardUserDefaults] stringForKey:kSettingsUrl]);
        //DLog(@"URL: %@",_textfieldUrl.text);
    }
}

/* activate textfield even if not clicked inside textfield but inside cell */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self.urlTextfield becomeFirstResponder];
    }
}

- (void)siteNameTableViewController:(SiteNameTableViewController *)controller didSelectSite:(Site *)site
{
    _siteNameLabel.text = site.name;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)positionModeTableViewController:(PositionModeTableViewController *)controller didSelectPositionMode:(NSUInteger *)positionMode
{
    _positionModeLabel.text = [self positionModeToName:positionMode];
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSString *)simulationModeToName:(NSUInteger *)simulationMode {
    NSString* name = @"None";
    
    switch ((int)simulationMode) {
        case simulationModeNone:
            name = @"None";
            break;
        case simulationModeSensors:
            name = @"Sensors";
            break;
        case simulationModePosition:
            name = @"Position";
            break;
        default:
            break;
    }
    
    return name;
}

-(NSString *)positionModeToName:(NSUInteger *)positionMode {
    NSString* name = @"Proximity iOS";
    
    int pmode = (int)positionMode;
    
    switch (pmode) {
        case positionModeProximity:
            name = @"Proximity iOS";
            break;
        case positionModePosition:
            name = @"Trilateration iOS";
            break;
        case positionModeMixed:
            name = @"Mixed iOS";
            break;
        case positionModePositionServer:
            name = @"Trilateration Server";
            break;
        default:
            break;
    }
    
    return name;
}

- (IBAction)switchDebugMode:(id)sender {
   if(sender == _debugSwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:_debugSwitch.isOn forKey:kSettingsIsDebug];
        DLog(@"Debug View: %s", [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsIsDebug] ? "ON" : "OFF");
    }
}

- (IBAction)switchShowBeaconMode:(id)sender {
    if(sender == _showBeaconSwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:_showBeaconSwitch.isOn forKey:kSettingsShowBeacon];
        DLog(@"Show Beacon: %s", [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsShowBeacon] ? "ON" : "OFF");
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
- (IBAction)switchDebugPosition:(id)sender {
    if(sender == _debugPositionSwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:_debugPositionSwitch.isOn forKey:kSettingsIsDebugPosition];
        DLog(@"Debug Position: %s", [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsIsDebugPosition] ? "ON" : "OFF");
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
