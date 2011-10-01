//
//  ChapterViewController.m
//  bible-ios
//
//  Created by Joe on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChapterViewController.h"
#import "Simple_Bible_KJVAppDelegate.h"
#import "HoverView.h"

#define MIN_FONT_SIZE 10
#define MAX_FONT_SIZE 36
#define DEFAULT_FONT_SIZE 18
#define TAP_Y_THRESHHOLD 50

NSString *Show_HoverView = @"SHOW";

@implementation ChapterViewController

- (id)initWithBookId:(int)bookId chapterNumber:(int)chapterNumber {
    self = [super init];
    if (self) {
        BibleLibrary *library = ((Simple_Bible_KJVAppDelegate *)[UIApplication sharedApplication].delegate).library;
        book = [library loadBook:bookId];
        chapter = chapterNumber;
        starterVerse = 0;
        
        self.title = book.name;
        verseFontSize = DEFAULT_FONT_SIZE;
    }
    return self;
}


- (id)initWithBookId:(int)bookId chapterNumber:(int)chapterNumber verseNumber:(int)verseNumber {
   self = [super init];
   if (self) {
      BibleLibrary *library = ((Simple_Bible_KJVAppDelegate *)[UIApplication sharedApplication].delegate).library;
      book = [library loadBook:bookId];
      chapter = chapterNumber;
      starterVerse = verseNumber;

      self.title = book.name;
       verseFontSize = DEFAULT_FONT_SIZE;
   }
   return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
   [super viewDidLoad];

    // Handle swipe gesture
	UISwipeGestureRecognizer *recognizer;
    
    // right swipes
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previousChapterAction:)];
	[self.view addGestureRecognizer:recognizer];
	[recognizer release];

    // left swipes
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextChapterAction:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
    
   // Set up the hover view

	// determine the size of HoverView
	CGRect frame = hoverView.frame;
	frame.origin.x = round((self.view.frame.size.width - frame.size.width) / 2.0);
	frame.origin.y = self.view.frame.size.height - 110;
	hoverView.frame = frame;
    hoverView.alpha = 0.0;
    //hoverView.hidden = YES;
	
	[self.view addSubview:hoverView];
	
	// called by MainView, when the user touches once on the background image
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showViewNotif:) name:Show_HoverView object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showViewNotif:) name:nil object:chapterWebView];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showViewNotif:) name:Show_HoverView object:self.view];
    
    mWindow = (TapDetectingWindow *)[[UIApplication sharedApplication].windows objectAtIndex:0];
    mWindow.viewToObserve = chapterWebView;
    mWindow.controllerThatObserves = self;

	bookmarksButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks 
                                                                        target:self action:@selector(onBookmarks:)];
    self.navigationItem.rightBarButtonItem = bookmarksButtonItem;
    
    [self renderChapter];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [book release];
    
	[hoverView release];
	[myTimer release];
	
    [bookmarksButtonItem release];
    
    [super dealloc];
}

#pragma mark - WebViewDelegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
   //NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
   //NSLog(@"webViewDidFinishLoad");
    [self hideBusyIndicator];
    // Maybe use [webView stringByEvaluatingJavaScriptFromString:@""] to autonavigate to selected verse
    if (starterVerse > 0) {
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.location.hash = 'verse%d'", starterVerse]];
        
        // Reset the starter verse
        starterVerse = 1;
    }
    
    // Add javascript handlers for the bookmarks
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[request.URL scheme] isEqual:@"verse"]) {
        NSArray *parts = [[request.URL relativeString] componentsSeparatedByString:@":"];
        if ([parts count] == 2) {
            int verseId = [[parts objectAtIndex:1] intValue];
            //[self promptForAddingBookmark:verseId];
            [Bookmark addBookmark:verseId];
        }
        return NO;
    }
    return YES;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([@"Yes" isEqualToString:[alertView buttonTitleAtIndex:buttonIndex]]) {
        NSLog(@"Saving bookmark");
    }
}

#pragma mark - HoverView methods
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan");
    
    NSUInteger numTaps = [[touches anyObject] tapCount];
	if (numTaps == 1)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:Show_HoverView object:nil];
	}
}
*/
- (void)showHoverView:(BOOL)show
{
    //NSLog(@"showHoverView: %d", show);
    
	// reset the timer
	[myTimer invalidate];
	[myTimer release];
	myTimer = nil;
	
	// fade animate the view out of view by affecting its alpha
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.40];
   
	if (show)
	{
		// as we start the fade effect, start the timeout timer for automatically hiding HoverView
		hoverView.alpha = 1.0;
//        hoverView.hidden = NO;
		myTimer = [[NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO] retain];
		[[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSDefaultRunLoopMode];
	}
	else
	{
		hoverView.alpha = 0.0;
	}
	
	[UIView commitAnimations];
}

- (void)timerFired:(NSTimer *)timer
{
	// time has passed, hide the HoverView
	[self showHoverView: NO];
}

- (void)showViewNotif:(NSNotification *)aNotification {
    NSLog(@"showViewNotif");
    
	// start over - reset the timer
	[myTimer invalidate];
	[myTimer release];
	myTimer = nil;
	
	[self showHoverView:(hoverView.alpha != 1.0)];
}

- (IBAction)decreaseFont:(id)sender {
    verseFontSize -= 2;
    if (verseFontSize < MIN_FONT_SIZE)
        verseFontSize = MIN_FONT_SIZE;

    // Update the web view with the resized font
    [self refreshFontStyle];

    // Keep the hover view active
    [self showHoverView:YES];
}

- (IBAction)increaseFont:(id)sender {
    verseFontSize += 2;
    if (verseFontSize > MAX_FONT_SIZE)
        verseFontSize = MAX_FONT_SIZE;
    
    // Update the web view with the resized font
    [self refreshFontStyle];
    
    // Keep the hover view active
    [self showHoverView:YES];
}

- (void)refreshFontStyle {
    NSString *javascript = [NSString stringWithFormat:@"var mysheet=document.styleSheets[0];var myrules=mysheet.cssRules? mysheet.cssRules: mysheet.rules;for (i=0; i<myrules.length; i++){if ('p' == myrules[i].selectorText.toLowerCase()) {myrules[i].style.fontSize = '%dpx';}}", verseFontSize];
    [chapterWebView stringByEvaluatingJavaScriptFromString:javascript];
}

- (IBAction)previousChapterAction:(id)sender {
	// If this is the first chapter of the first book, do nothing
	// If this is the first chapter, go to the previous book
	// Else go to the previous chapter
	if (book.bookId == 1 && chapter == 1) {
	    //Toast.makeText(this, "You are currently at the beginning of the Bible", Toast.LENGTH_SHORT).show();
	    // Do nothing
	}
	else if (chapter > 1) {
	    // Go to the previous chapter
	    chapter--;
	    [self renderChapter];
	}
	else {
	    // Go to the previous book (last chapter in that book)
        
	    // Load the previous book to update the title
        BibleLibrary *library = ((Simple_Bible_KJVAppDelegate *)[UIApplication sharedApplication].delegate).library;
        [book release];
	    book = [library loadBook:(book.bookId - 1)];
        
	    // Set the current chapter to the last chapter in the previous book
        chapter = [library chapterCount:book.bookId];
        
	    // Load the data 
	    [self renderChapter];
	}

    // Reset the "hide navigation bar" timer if this was triggered by a button tap
    if ([sender isKindOfClass:[UIButton class]]) {
        [self showHoverView:YES];
    }
}

- (IBAction)nextChapterAction:(id)sender {
	// If this is the last chapter in the last book, do nothing
	// If this is the last chapter in the book, go to the first chapter in the next book
	// Else go to the next chapter
	if (book.bookId == 66 && chapter == 22) {
	    //Toast.makeText(this, "You have reached the end of the Bible", Toast.LENGTH_SHORT).show();
	    
	    // Do nothing
	    return;
	}
	
    BibleLibrary *library = ((Simple_Bible_KJVAppDelegate *)[UIApplication sharedApplication].delegate).library;
    
	// Get the chapter count
    int chapterCount = [library chapterCount:book.bookId];
	
	if (chapter == chapterCount) {
	    // Go to the next book
	    chapter = 1;
        
	    // Load the next book to update the title
        [book release];
	    book = [library loadBook:(book.bookId + 1)];
	    
	    [self renderChapter];
	}
	else {
	    // Go to the next chapter
	    chapter++;
	    [self renderChapter];
	}
    
    // Reset the "hide navigation bar" timer if this was triggered by a button tap
    if ([sender isKindOfClass:[UIButton class]]) {
        [self showHoverView:YES];
    }
}

- (IBAction)selectChapterAction:(id)sender {
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Select Chapter"
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:@"Select"
                                             otherButtonTitles:nil];
    // Add the picker
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,185,0,0)];
    
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;    // note this is default to NO
    
    [menu addSubview:pickerView];
    [menu showInView:self.view];
    [menu setBounds:CGRectMake(0,0,320, 700)];
    
    [pickerView release];
    [menu release];
}

- (void)renderChapter {
    self.title = book.name;
    chapterLabel.text = [NSString stringWithFormat:@"Chapter %d", chapter];
    
    [self displayBusyIndicator];
    
    BibleLibrary *library = ((Simple_Bible_KJVAppDelegate *)[UIApplication sharedApplication].delegate).library;
    NSArray *verses = [library loadVerses:book.bookId chapter:chapter];
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSMutableString *html = [NSMutableString stringWithFormat:@"<html><head><style>p {padding: 0; margin: 0;border-bottom: 1px solid #ddd; font-size: %dpx} span.verse-number {padding-right: 5px;} p a {text-decoration: none; color: #000;} p img {padding-top: 5px; padding-bottom: 0;}</style></head><body>", verseFontSize];
    for (Verse *verse in verses) {
        [html appendString:[NSString stringWithFormat:@"<p><a href='verse:%d'><span class='verse-number' id='verse%d'><img src='ribbon.png' width='16' height='24'> [%d]</span></a> %@</p>", verse.verseId, verse.number, verse.number, verse.text]];
    }
    [html appendString:@"</body></html>"];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    [chapterWebView loadHTMLString:html baseURL:[NSURL fileURLWithPath:path]];
    //[html release];
    [pool release];
    
    [verses release];
}

- (void)userDidTapWebView:(id)tapPoint {
    //NSLog(@"userDidTapWebView");
    // Ignore tap events on the left edge of the screen where the bookmark links are
    //if (((CGPoint)tapPoint).x > TAP_Y_THRESHHOLD)
    NSArray *parts = (NSArray *)tapPoint;
    if ([[parts objectAtIndex:0] floatValue] > TAP_Y_THRESHHOLD)
        [self showHoverView:YES];
}

- (void)displayBusyIndicator {
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	//HUD.dimBackground = YES;
    HUD.labelText = @"Loading";
    
	// Regiser for HUD callbacks so we can remove it from the window at the right time
    //HUD.delegate = self;
    
    [HUD show:YES];
}

- (void)hideBusyIndicator {
    [HUD hide:YES];
    [HUD release];
    HUD = nil;
}

#pragma - UIPickerView methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"Chapter %d", (row+1)];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    BibleLibrary *library = ((Simple_Bible_KJVAppDelegate *)[UIApplication sharedApplication].delegate).library;
    
	// Get the chapter count
    return [library chapterCount:book.bookId];
}

#pragma - UIActionSheet methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([actionSheet cancelButtonIndex] == buttonIndex) {
        return;
    }
    
    if ([actionSheet destructiveButtonIndex] == buttonIndex) {
        int selectedChapterNumber = chapter;
        NSArray *actionSubviews = actionSheet.subviews;
        for (int i=0; i<[actionSubviews count]; i++) {
            if ([[actionSubviews objectAtIndex:i] isKindOfClass:[UIPickerView class]]) {
                UIPickerView *picker = [actionSubviews objectAtIndex:i];
                selectedChapterNumber = [picker selectedRowInComponent:0] + 1;
            }
        }

        if (selectedChapterNumber > 0) {
            chapter = selectedChapterNumber;
            [self renderChapter];
        }
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    NSArray *actionSubviews = actionSheet.subviews;
    for (int i=0; i<[actionSubviews count]; i++) {
        if ([[actionSubviews objectAtIndex:i] isKindOfClass:[UIPickerView class]]) {
            [[actionSubviews objectAtIndex:i] selectRow:(chapter-1) inComponent:0 animated:NO];
        }
    }
}

#pragma - Bookmark methods
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
    [book release];
    book = [library loadBook:bookmarkedVerse.bookId];
    chapter = bookmarkedVerse.chapter;
    starterVerse = bookmarkedVerse.number;
    [bookmarkedVerse release];
    [self renderChapter];
}

- (void)cancelBookmarkLoad {
    // Dismiss the bookmark dialog
    [self.modalViewController dismissModalViewControllerAnimated:YES];
}

@end
