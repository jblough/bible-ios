//
//  SearchViewController.m
//  Simple Bible KJV
//
//  Created by Joe on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultsViewController.h"
#import "Simple_Bible_KJVAppDelegate.h"

const int searchScopeSelectBooks = 3;

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Search";
        selectedBooksLookup = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [otBooks release];
    [ntBooks release];
    [selectedBooksLookup release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    selectBooksTable.hidden = (searchScope.selectedSegmentIndex != searchScopeSelectBooks);
    
    BibleLibrary *library = ((Simple_Bible_KJVAppDelegate *)[UIApplication sharedApplication].delegate).library;
    [otBooks release];
    otBooks = [library loadBooks:1];
    [ntBooks release];
    ntBooks = [library loadBooks:2];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)search:(id)sender {
    [self closeKeyboard:sender];
    
    // Verify that a search term has been entered
    if (!searchField.text || [@"" isEqualToString:searchField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Search" message:@"Please enter a search term" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else {
        //UIViewController *nextViewController = [[SearchResultsViewController alloc] initWithNibName:@"SearchResultsViewController" bundle:nil];
        UIViewController *nextViewController = [[SearchResultsViewController alloc] 
                                                initWithSearchTerm:searchField.text                                                                                    method:searchType.selectedSegmentIndex 
                                                scope:searchScope.selectedSegmentIndex 
                                                books:selectedBooksLookup];
        [self.navigationController pushViewController:nextViewController animated:YES];
        [nextViewController release];
    }
}

- (IBAction)scopeChange:(id)sender {
    [self closeKeyboard:sender];
    
    selectBooksTable.hidden = (searchScope.selectedSegmentIndex != searchScopeSelectBooks);
}

- (IBAction)closeKeyboard:(id)sender {
    [searchField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITable methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0) ? [otBooks count] : [ntBooks count];
}

- (NSString *)tableView:(UITableView *)inTableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0) ? @"Old Testament" : @"New Testament";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    Book *book = [self getBook:indexPath];
    
    cell.textLabel.text = book.name;
    
    if ([selectedBooksLookup containsObject:[NSNumber numberWithInt:book.bookId]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Add the book to the list of selected books if it isn't already in the list
    //  or remove the book from the list if it's already in the list
    Book *book = [self getBook:indexPath];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([selectedBooksLookup containsObject:[NSNumber numberWithInt:book.bookId]]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [selectedBooksLookup removeObject:[NSNumber numberWithInt:book.bookId]];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedBooksLookup addObject:[NSNumber numberWithInt:book.bookId]];
    }
}

- (Book *)getBook:(NSIndexPath *)indexPath {
    return (indexPath.section == 0) ? [otBooks objectAtIndex:indexPath.row] : [ntBooks objectAtIndex:indexPath.row];
}

@end
