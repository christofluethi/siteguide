//
//  MainViewController.m
//  siteguide
//
//  Created by Christof Luethi on 10.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "MainViewController.h"
#import "SensorManager.h"

@interface MainViewController ()

@end

@implementation MainViewController {
    UIColor *settingsColor;
    UIColor *mapColor;
    UIColor *listColor;
    UIColor *inactiveColor;
    UIColor *activeColor;
    UIColor *debugColor;
    NSDateFormatter *dateFormatter;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    settingsColor = [UIColor colorWithRed:107/255.0f green:194/255.0f blue:136/255.0f alpha:0.0f];
    mapColor = [UIColor colorWithRed:182/255.0f green:84/255.0f blue:113/255.0f alpha:0.0f];
    listColor = [UIColor colorWithRed:248/255.0f green:194/255.0f blue:42/255.0f alpha:0.0f];
    inactiveColor = [UIColor colorWithRed:197/255.0f green:197/255.0f blue:197/255.0f alpha:0.0f];
    activeColor = [UIColor colorWithRed:197/255.0f green:197/255.0f blue:197/255.0f alpha:0.1f];
    debugColor = [UIColor colorWithRed:169/255.0f green:182/255.0f blue:108/255.0f alpha:0.0f];

    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"HH:mm:ss 'am' dd.MM.yyyy"];
    
    /* reachability related */
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(positionUpdate:)
                                                 name: kNotificationPositionUpdate
                                               object: nil];
}

-(void)setButtonStateTo:(BOOL)state {
    _mapButton.enabled = state;
    _listButton.enabled = state;
    _settingsButton.enabled = state;
    _debugButton.enabled = state;
    
    if(state) {
        _mapButton.backgroundColor = activeColor; // mapColor;
        _listButton.backgroundColor = activeColor; //listColor;
        _settingsButton.backgroundColor = activeColor; //settingsColor;
        _debugButton.backgroundColor = activeColor; // debugColor;
    } else {
        _mapButton.backgroundColor = inactiveColor;
        _listButton.backgroundColor = inactiveColor;
        _settingsButton.backgroundColor = inactiveColor;
        _debugButton.backgroundColor = inactiveColor;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)switchMonitoring:(id)sender {
    SensorManager *manager = [SensorManager sharedInstance];
    if([manager isRunning]) {
        [manager stop];
    } else {
        [manager start];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"zurück"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:nil
                                                                action:nil];
    
    [self.navigationItem setBackBarButtonItem:backItem];
    
    BOOL debug = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsIsDebug];
    if(debug) {
        _positionLabel.hidden = NO;
        _debugButton.hidden = NO;
    } else {
        _positionLabel.hidden = YES;
        _debugButton.hidden = YES;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NetworkStatus status = [[appDelegate getReachability] currentReachabilityStatus];
    
    if (status == NotReachable) {
        [self setButtonStateTo:NO];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Netzwerkfehler" message:@"Sie müssen mit dem Internet verbunden sein damit Sie die App benutzen können." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                              
        [alert show];
    } else  {
        [self setButtonStateTo:TRUE];
    }
}

- (IBAction)aboutAction:(id)sender {
    [self performSegueWithIdentifier:@"ShowAbout" sender:self];
}

-(void)reachabilityChanged:(NSNotification *)notification {
    Reachability *r = [notification object];
    if( [r isKindOfClass: [Reachability class]]) {
        NetworkStatus status = [r currentReachabilityStatus];
        switch(status) {
            case NotReachable:
                [self setButtonStateTo:NO];
                [self.navigationController popToRootViewControllerAnimated:YES];
                DLog("Not Reachable");
                break;
            case ReachableViaWiFi:
                [self setButtonStateTo:YES];
                DLog("Reachable via WiFi");
                break;
            case ReachableViaWWAN:
                [self setButtonStateTo:YES];
                DLog("Reachable via WWAN");
                break;
            default:
                DLog("Unknown");
                break;
        }
    }
}

- (void)positionUpdate:(NSNotification *) notification {
    if ([[notification name] isEqualToString:kNotificationPositionUpdate]) {
        NSDictionary* userInfo = notification.userInfo;
        Location *pos = [userInfo objectForKey:@"lastPosition"];
        
        if (!isnan (pos.xCoordinate) && !isnan(pos.yCoordinate)) {
            _lastPositionLabel.text = [NSString stringWithFormat:@"Letzte bekannte Position: %.1f/%.1f (x/y)", pos.xCoordinate, pos.yCoordinate];
            _lastPositionTime.text = [NSString stringWithFormat:@"Letzte Positionierung um: %@", [dateFormatter stringFromDate:[NSDate date]]];
        }
        
    }
}

@end
