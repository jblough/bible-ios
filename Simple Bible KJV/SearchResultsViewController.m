//
//  SearchResultsViewController.m
//  Simple Bible KJV
//
//  Created by Joe on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "ChapterViewController.h"
#import "Simple_Bible_KJVAppDelegate.h"


#define SEARCH_METHOD_EXACT_PHRASE  0
#define SEARCH_METHOD_ALL_WORDS     1
#define SEARCH_METHOD_ANY_WORDS     2

#define SEARCH_SCOPE_ALL_BOOKS      0
#define SEARCH_SCOPE_OT_BOOKS       1
#define SEARCH_SCOPE_NT_BOOKS       2
#define SEARCH_SCOPE_SELECTED_BOOKS 3

#define SEARCH_RESULTS_LOCATION_LABEL_TAG   0
#define SEARCH_RESULTS_VERSE_TAG            1


@implementation SearchResultsViewController

@synthesize verseCell;

- (id)initWithSearchTerm:(NSString *)search method:(int)method scope:(int)scope books:(NSArray *)books {
    self = [super initWithNibName:@"SearchResultsViewController" bundle:nil];
    if (self) {
        self.title = @"Search Results";
        
        searchTerm = [search retain];
        searchMethod = method;
        searchScope = scope;
        searchBooks = [books retain];
        
        font = [UIFont systemFontOfSize:15];
        cellSize = CGSizeMake(280, 500);

        NSLog(@"search term: '%@', method; %d, scope: %d", searchTerm, searchMethod, searchScope);
        searchResultsHeader.text = [NSString stringWithFormat:@"Search results for \"%@\"", searchTerm];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //searchResultsHeader.text = [NSString stringWithFormat:@"Search results for \"%@\"", searchTerm];
    }
    return self;
}

- (void)dealloc
{
    [searchResults release];
    [searchTerm release];
    [searchBooks release];
//    [font release];
    
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    if (searchResults == nil) {
        searchResultsHeader.text = [NSString stringWithFormat:@"Search results for \"%@\"", searchTerm];
        
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        
        //HUD.dimBackground = YES;
        HUD.labelText = @"Searching";
        
        
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        
        // Show the HUD while the provided method executes in a new thread
        [HUD showWhileExecuting:@selector(performSearch) onTarget:self withObject:nil animated:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Search
- (void)performSearch {
    NSLog(@"searching...");
    BibleLibrary *library = ((Simple_Bible_KJVAppDelegate *)[UIApplication sharedApplication].delegate).library;

    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSString *whereClause = [self generateSearchString];
    [searchResults release];
    searchResults = [library searchVerses:whereClause];
    [whereClause release];
    [pool release];
    NSLog(@"Searching returned %d verses", [searchResults count]);
    [self.tableView reloadData];
}

- (NSString *)generateSearchString {
    NSMutableString *whereClause = [[NSMutableString alloc] init];
    
	// Create a WHERE clause based on the search method
	switch (searchMethod) {
        case SEARCH_METHOD_EXACT_PHRASE:
            // WHERE VerseText LIKE %?%
            NSLog(@"search term: %@", searchTerm);
            [whereClause appendFormat:@"VerseText LIKE '%%%@%%'", searchTerm];
            break;
        case SEARCH_METHOD_ALL_WORDS:
            // Break up the search term into words and add each as
            // WHERE VerseText LIKE %?% AND VerseText LIKE %?% AND ...
        {
            NSMutableCharacterSet *characterSet = [[NSMutableCharacterSet alloc] init];
            [characterSet addCharactersInString:@" ,."];
            NSArray *tokens = [searchTerm componentsSeparatedByCharactersInSet:characterSet];
            [characterSet release];
            
            int size = [tokens count];
            for (int i=0; i<size; i++) {
                NSString *token = [tokens objectAtIndex:i];
                [whereClause appendFormat:@"VerseText LIKE '%%%@%%'", token];
                if (i+1 < size) {
                    [whereClause appendString:@" AND "];
                }
            }
        }
            break;
        case SEARCH_METHOD_ANY_WORDS:
            // Break up the search term into words and add each as
            // WHERE VerseText LIKE %?% OR VerseText LIKE %?% OR ...
        {
            NSMutableCharacterSet *characterSet = [[NSMutableCharacterSet alloc] init];
            [characterSet addCharactersInString:@" ,."];
            NSArray *tokens = [searchTerm componentsSeparatedByCharactersInSet:characterSet];
            [characterSet release];
            
            int size = [tokens count];
            NSLog(@"%@ has %d tokens", searchTerm, size);
            for (int i=0; i<size; i++) {
                NSString *token = [tokens objectAtIndex:i];
                [whereClause appendFormat:@"VerseText LIKE '%%%@%%'", token];
                if (i+1 < size) {
                    [whereClause appendString:@" OR "];
                }
            }
        }
            break;
	}
	
	// Limit the scope of the search if needed
	switch (searchScope) {
        case SEARCH_SCOPE_NT_BOOKS:
            // AND BookID IN (SELECT id FROM Books WHERE TestamentID = 2)
            [whereClause appendString:@" AND BookID IN (SELECT id FROM Books WHERE TestamentID = 2)"];
            break;
        case SEARCH_SCOPE_OT_BOOKS:
            // AND BookID IN (SELECT id FROM Books WHERE TestamentID = 1)
            [whereClause appendString:@" AND BookID IN (SELECT id FROM Books WHERE TestamentID = 1)"];
            break;
        case SEARCH_SCOPE_SELECTED_BOOKS:
            // AND BookID IN (?, ?, ?, ?, ...)
            [whereClause appendString:@" AND BookID IN ("];
            int size = [searchBooks count];
            for (int i=0; i<size; i++) {
                [whereClause appendFormat:@"%d", [[searchBooks objectAtIndex:i] intValue]];
                if (i+1 < (size)) {
                    [whereClause appendString:@", "];
                }
            }
            [whereClause appendString:@")"];
            break;
	}
	
	// Run the query via BibleLibrary
    NSLog(@"search string: '%@'", whereClause);
    return whereClause;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (searchResults == nil) ? 0 : [searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VerseCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        /*cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];*/
        [[NSBundle mainBundle] loadNibNamed:@"SearchResultsCell" owner:self options:nil];
        cell = verseCell;
        //cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.verseCell = nil;        
    }
    
    // Configure the cell...
    BibleLibrary *library = ((Simple_Bible_KJVAppDelegate *)[UIApplication sharedApplication].delegate).library;
    
    Verse *verse = [searchResults objectAtIndex:indexPath.row];
    Book *book = [library loadBook:verse.bookId];
    //cell.textLabel.text = verse.text;
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:1];
    label.text = [NSString stringWithFormat:@"%@ - Chapter %d - Verse %d", book.name, verse.chapter, verse.number];
    [book release];
    
    label = (UILabel *)[cell viewWithTag:2];
    //label.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    label.text = [NSString stringWithFormat:@"%@", verse.text];    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        Verse *verse = [searchResults objectAtIndex:indexPath.row];
        CGSize s = [verse.text sizeWithFont:font constrainedToSize:cellSize];
        return s.height + 11; // I put some padding on it.
}
*/
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    Verse *verse = [searchResults objectAtIndex:indexPath.row];

    ChapterViewController *nextViewController = [[ChapterViewController alloc] initWithBookId:verse.bookId chapterNumber:verse.chapter verseNumber:verse.number];
    [self.navigationController pushViewController:nextViewController animated:YES];
    [nextViewController release];
}

@end
