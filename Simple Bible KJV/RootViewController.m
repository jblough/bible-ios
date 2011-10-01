//
//  RootViewController.m
//  Simple Bible KJV
//
//  Created by Joe on 9/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "ChapterViewController.h"
#import "SearchViewController.h"
#import "Simple_Bible_KJVAppDelegate.h"

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Books of the Bible";
    BibleLibrary *library = ((Simple_Bible_KJVAppDelegate *)[UIApplication sharedApplication].delegate).library;
    [otBooks release];
    otBooks = [library loadBooks:1];
    //NSLog(@"Loaded %d Old Testament books", [otBooks count]);
    [ntBooks release];
    ntBooks = [library loadBooks:2];
    //NSLog(@"Loaded %d New Testament books", [ntBooks count]);
    
	searchButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch 
                                                                     target:self action:@selector(onSearch:)];
    self.navigationItem.leftBarButtonItem = searchButtonItem;
    
	bookmarksButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks 
                                                                        target:self action:@selector(onBookmarks:)];
    self.navigationItem.rightBarButtonItem = bookmarksButtonItem;
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

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

// Customize the number of sections in the table view.
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
    Book *book = (indexPath.section == 0) ? [otBooks objectAtIndex:indexPath.row] : [ntBooks objectAtIndex:indexPath.row];

    cell.textLabel.text = book.name;
    cell.imageView.image = [UIImage imageNamed:@"closed3"];
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
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Book *book = (indexPath.section == 0) ? [otBooks objectAtIndex:indexPath.row] : [ntBooks objectAtIndex:indexPath.row];
    NSLog(@"Selected book %@", book.name);
    
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ChapterViewController *nextViewController = [[ChapterViewController alloc] initWithBookId:book.bookId chapterNumber:1];
    [self.navigationController pushViewController:nextViewController animated:YES];
    [nextViewController release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [otBooks release];
    [ntBooks release];
    
    [searchButtonItem release];
    [bookmarksButtonItem release];
    
    [super dealloc];
}

- (void)onSearch:(id)sender {
    UIViewController *nextViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    [self.navigationController pushViewController:nextViewController animated:YES];
    [nextViewController release];
}

- (void)onBookmarks:(id)sender {
    NSLog(@"Opening bookmarks...");
    BookmarksViewController *bookmarksViewController = 
        [[BookmarksViewController alloc] initWithDelegate:self];
    [self presentModalViewController:bookmarksViewController animated:YES];
    [bookmarksViewController release];
}

- (void)loadBookmark:(int)bookmark {
    // Dismiss the bookmark dialog
    [self.modalViewController dismissModalViewControllerAnimated:YES];
    
    // Load bookmark
    BibleLibrary *library = ((Simple_Bible_KJVAppDelegate *)[UIApplication sharedApplication].delegate).library;
    Verse *bookmarkedVerse = [library loadVerse:bookmark];
    
    // Create view for rendering the bookmark
    ChapterViewController *nextViewController = [[ChapterViewController alloc] initWithBookId:bookmarkedVerse.bookId 
                                                chapterNumber:bookmarkedVerse.chapter
                                                 verseNumber:bookmarkedVerse.number];
    [self.navigationController pushViewController:nextViewController animated:YES];
    [nextViewController release];
    [bookmarkedVerse release];
}

- (void)cancelBookmarkLoad {
    // Dismiss the bookmark dialog
    [self.modalViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - SelectChapterDelegate functions
- (void)selectChapter:(int)bookId {
    NSLog(@"Select chapter for book %d", bookId);
}

@end
