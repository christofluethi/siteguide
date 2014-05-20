//
//  DocumentTableViewController.m
//  SiteGuide
//
//  Created by Christof Luethi on 06.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "DocumentTableViewController.h"

#define ROW_HEIGHT_TABLE_CELL 50
NSString *const INFORMATION_API_CALL = @"/TestCockpit/api/1/site/%i/informations?byPointOfInterestId=%i";
long const MAX_CACHE_TIME = 600l;

@implementation DocumentTableViewController {
    UIActivityIndicatorView *activity;
    Site *site;
    NSUInteger _selectedIndex;
    NSSortDescriptor *sortDescriptor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsSite];
    if(encodedObject) {
        site = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    }
    
    self.title = _poi.name;
    
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
    [activity startAnimating];

    NSString* baseUrl = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingsUrl];
    if(baseUrl == nil || [baseUrl length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Server nicht gefunden"
                                                        message:@"Es wurde kein SiteGuide Server konfiguriert. Bitte konfigurieren sie einen SiteGuide Server."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    } else {
        [self makeInformationRequest:NO];
    }
}

-(void)makeInformationRequest:(BOOL)forceRefresh {
    long currentTime = (long)[[NSDate date] timeIntervalSince1970];
    
    /* 
     check if the document list is newer than MAX_CACHE_TIME
     Download if needed 
    */
    if(_poi.documents != nil && (currentTime - _poi.documentsCacheTime) < MAX_CACHE_TIME) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [activity stopAnimating];
        });
        DLog("Cache hit. age of documents: %ld", (currentTime - _poi.documentsCacheTime));
        return;
    }
    
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingsUrl];
    NSString *qPart = [NSString stringWithFormat:INFORMATION_API_CALL, site.siteId, _poi.poiId];
    NSString *informationCall = [NSString stringWithFormat:@"%@%@", baseUrl, qPart];
    
    DLog(@"NetworkCall: %@", informationCall);
    NSMutableArray *documentList = [[NSMutableArray alloc] init];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:informationCall] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        DLog(@"%@", json);
        
        if (jsonError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [activity stopAnimating];
            });
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
        
        for (NSDictionary *dataDict in json) {
           // link = [dataDict objectForKey:@"content"];
            
          /*    "id":315040,
                "title":"testinfo",
                "sortPosition":0,
                "description":null,
                "pointOfInterestId":315038,
                "type":"TEXT",
                "category":"DETAILINFO",
                "content":"my content"
           }*/
        
            NSString *did = [dataDict objectForKey:@"id"];
            NSString *dname = [dataDict objectForKey:@"title"];
            NSString *ddesc = [dataDict objectForKey:@"description"];
            NSString *poiId = [dataDict objectForKey:@"pointOfInterestId"];
            NSString *dtype = [dataDict objectForKey:@"type"];
            NSString *dcategory = [dataDict objectForKey:@"category"];
            NSString *dcontent = [dataDict objectForKey:@"content"];
            
            int pid = [poiId intValue];
            if(pid != _poi.poiId) {
                return;
            }
            
            Document *d = [[Document alloc] initWithName:dname description:ddesc docId:[did intValue] poiId:[poiId intValue] type:dtype category:dcategory content:dcontent];
            
            [documentList addObject:d];
        }
        
        [_poi setDocuments:documentList];
        if([documentList count] > 0) {
            [_poi setDocumentsCacheTime:currentTime];
        }
        /* dispatch async needed for displaying cells correctly - if not applied the cells are only refreshed if you scroll */
        dispatch_async(dispatch_get_main_queue(), ^{
            [activity stopAnimating];
            [self.tableView reloadData];
        });
        
    }];
    [dataTask resume];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Dokumente";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _poi.documents.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT_TABLE_CELL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DocumentListCell"];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    Document *doc = [_poi.documents objectAtIndex:indexPath.row];
    
    // Default FileIcon Color is grey
    cell.textLabel.text = [NSString stringWithFormat:@"%@", doc.name];
    
    if(doc.description != (id)[NSNull null]) {
        cell.detailTextLabel.text = doc.description;
    } else {
        cell.detailTextLabel.text = @"";
    }
    
    cell.imageView.image = [UIImage imageNamed:@"FileGrey.png"];
    
    if ([doc.type  isEqual: @"TEXT"]) {
        cell.imageView.image = [UIImage imageNamed:@"FileGreen.png"];
    }
    
    if ([doc.type  isEqual: @"LINK"]) {
        cell.imageView.image = [UIImage imageNamed:@"FileYellow.png"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _selectedIndex = indexPath.row;
    
    [self performSegueWithIdentifier:@"ShowContent" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowContent"]) {
        ContentViewController *contentViewController = segue.destinationViewController;
        Document *d = [_poi.documents objectAtIndex:_selectedIndex];
        contentViewController.contentLink = d.content;
    } else if ([segue.identifier isEqualToString:@"ShowSortForDocuments"]) {
        SortTableViewController *sortController = segue.destinationViewController;
        sortController.delegate = self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)sortTableViewController:(SortTableViewController *)controller didSelectSort:(int)sort {
    /* we do not need to take specific actions. we load the sort value from the userdefaults whenever the viewWillAppear method is called. */
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSSortDescriptor *)sortDescriptorForSortMode:(int)sort {
    if(sort == sortModeNameDescending) {
        return [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    } else if(sort == sortModeDistance) {
        return [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    }  else {
        return [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    }
}

/* attach notification whenever the view will appear */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    sortDescriptor = [self sortDescriptorForSortMode:(int)[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsSortMode]];
    if(_poi.documents != nil) {
        [_poi.documents sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
    [self.tableView reloadData];

}
@end
