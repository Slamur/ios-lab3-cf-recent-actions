//
//  MasterViewController.m
//  CodeforcesRecentActions
//
//  Created by Admin on 28.05.16.
//  Copyright © 2016 SSAU. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController ()

@end

@implementation MasterViewController
{
    NSMutableData *recentActionsData;
    NSArray *recentActions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshActions:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    recentActions = [[NSArray alloc] init];
    [self refreshActions:self];
}

-(void)refreshActions:(id)sender {
    [self makeRequest];
}

-(void)makeRequest {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://codeforces.com/api/recentActions?maxCount=20"]];
    
    request.HTTPMethod = @"GET";
    
//    id urlSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//    id session = [NSURLSession sessionWithConfiguration:urlSessionConfig];
    
    [[NSURLConnection alloc] initWithRequest:request delegate: self];
}


-(void)connection:(NSURLConnection*)connection didReceiveResponse:(nonnull NSURLResponse *)response {
    recentActionsData = [[NSMutableData alloc] init];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*) data {
    [recentActionsData appendData:data];
}

-(NSCachedURLResponse*)connection:(NSURLConnection*)connection willCacheResponse:(nonnull NSCachedURLResponse *)cachedResponse {
    return nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection {
    NSString *jsonObjectString = [[NSString alloc] initWithData:recentActionsData encoding:NSUTF8StringEncoding];
    NSData *jsonObject = [jsonObjectString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSError *error = nil;
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:jsonObject options:kNilOptions error:&error];
    
    if (![jsonResponse[@"status"] isEqualToString: @"OK"]) {
        NSLog(@"Can load, but get failed with last codeforces actions. I can't live anymore ;(");
    }
    
    recentActions = jsonResponse[@"result"];//[self parseJsonRecentActions : jsonResponse];
    [self.tableView reloadData];
}

-(void)connection:(NSURLConnection*)connection didFailWithError:(nonnull NSError *)error {
    NSLog(@"Can't load last codeforces actions. I can't live anymore ;(");
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowDetails"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [recentActions objectAtIndex:indexPath.row];
        
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [recentActions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *recentAction = [recentActions objectAtIndex:indexPath.row];
    
    NSDictionary *blog = recentAction[@"blogEntry"];
    
    NSString *title = blog[@"title"];
    
    NSDictionary *commentAction = recentAction[@"comment"];
    if (commentAction != nil) {
        // new comment
        cell.textLabel.text = [NSString stringWithFormat:@"New comment: '%@'", title];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"Created: '%@'", title];
    }
}

#pragma mark - Fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

@end
