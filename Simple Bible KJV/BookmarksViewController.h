//
//  BookmarksViewController.h
//  Simple Bible KJV
//
//  Created by Joe on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BookmarkLoaderDelegate
    - (void)loadBookmark:(int)bookmark;
    - (void)cancelBookmarkLoad;
@end

@interface BookmarksViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

    NSArray *bookmarks;
    id<BookmarkLoaderDelegate> _delegate;
    
    IBOutlet UITableView *bookmarkTable;
    IBOutlet UIBarButtonItem *editButton;
    IBOutlet UIBarButtonItem *doneButton;
    IBOutlet UINavigationItem *navBar;
}

- (id)initWithDelegate:(id<BookmarkLoaderDelegate>)delegate;

- (IBAction)toggleEditMode:(id)sender;
- (IBAction)done:(id)sender;

@end
