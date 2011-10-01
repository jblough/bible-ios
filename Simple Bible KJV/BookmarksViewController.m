//
//  BookmarksViewController.m
//  Simple Bible KJV
//
//  Created by Joe on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookmarksViewController.h"
#import "Bookmark.h"


@implementation BookmarksViewController

- (id)initWithDelegate:(id<BookmarkLoaderDelegate>)delegate {
    self = [super initWithNibName:@"BookmarksViewController" bundle:nil];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [bookmarks release];
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
    
    [bookmarks release];
    bookmarks = [Bookmark loadBookmarks];
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

- (IBAction)toggleEditMode:(id)sender {
    if ([bookmarkTable isEditing]) {
        // Turn off editing
        [bookmarkTable setEditing:NO animated:YES];
        // Update edit button label
        editButton.title = @"Edit";
        // Show the Close button to close the view
        navBar.rightBarButtonItem = doneButton;
    }
    else {
        // Turn on editing
        [bookmarkTable setEditing:YES animated:YES];
        // Update edit button label
        editButton.title = @"Done";
        // Show the Close button to close the view
        navBar.rightBarButtonItem = nil;
    }
}

- (IBAction)done:(id)sender {
    [_delegate cancelBookmarkLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (bookmarks) ? [bookmarks count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookmarkCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    Bookmark *bookmark = [bookmarks objectAtIndex:indexPath.row];
    cell.textLabel.text = bookmark.bookName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Chapter %d - Verse %d", 
                                 bookmark.chapter, bookmark.verseNumber];
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

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Bookmark *bookmark = [bookmarks objectAtIndex:indexPath.row];
        [Bookmark removeBoomark:bookmark.verseId];
        
        // Reload the bookmarks
        [bookmarks release];
        bookmarks = [Bookmark loadBookmarks];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // Cast to a mutable array (since [Bookmark loadBookmarks] returns an NSMutableArray, we can do this safely)
    NSMutableArray *editableBookmarks = (NSMutableArray *)bookmarks;
    
    // Safe off the bookmark that's being moved
    Bookmark *bookmark = [[bookmarks objectAtIndex:fromIndexPath.row] retain];
    [editableBookmarks removeObjectAtIndex:fromIndexPath.row];
    [editableBookmarks insertObject:bookmark atIndex:toIndexPath.row];
    [bookmark release];
    
    // Update the bookmarks saved to disk
    [Bookmark saveBookmarks:editableBookmarks];
    
    // Reload the bookmarks
    [bookmarks release];
    bookmarks = [Bookmark loadBookmarks];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Inform the delegate that a bookmark has been selected
    Bookmark *bookmark = [bookmarks objectAtIndex:indexPath.row];
    [_delegate loadBookmark:bookmark.verseId];
}


@end
