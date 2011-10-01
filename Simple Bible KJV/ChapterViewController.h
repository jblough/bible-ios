//
//  ChapterViewController.h
//  bible-ios
//
//  Created by Joe on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BibleLibrary.h"
#import "BookmarksViewController.h"
#import "TapDetectingWindow.h"
#import "MBProgressHUD.h"


@class HoverView;

@interface ChapterViewController : UIViewController 
    <UIWebViewDelegate, TapDetectingWindowDelegate, 
    UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate, BookmarkLoaderDelegate> {

   IBOutlet UILabel *chapterLabel;
   IBOutlet UIWebView *chapterWebView;
   TapDetectingWindow *mWindow;
   MBProgressHUD *HUD;

	IBOutlet HoverView *hoverView;
	NSTimer* myTimer;
        
    IBOutlet UIBarButtonItem *bookmarksButtonItem;
   
   Book *book;
   int chapter;
   int starterVerse;
        
    int verseFontSize;
}

- (id)initWithBookId:(int)bookId chapterNumber:(int)chapterNumber;
- (id)initWithBookId:(int)bookId chapterNumber:(int)chapterNumber verseNumber:(int)verseNumber;

- (IBAction)decreaseFont:(id)sender;
- (IBAction)increaseFont:(id)sender;
- (void)refreshFontStyle;

- (IBAction)previousChapterAction:(id)sender;
- (IBAction)nextChapterAction:(id)sender;
- (IBAction)selectChapterAction:(id)sender;
- (void)renderChapter;

- (void)displayBusyIndicator;
- (void)hideBusyIndicator;

@end
