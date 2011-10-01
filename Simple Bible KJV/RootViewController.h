//
//  RootViewController.h
//  Simple Bible KJV
//
//  Created by Joe on 9/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BibleLibrary.h"
#import "BookmarksViewController.h"

@interface RootViewController : UITableViewController <SelectChapterDelegate, BookmarkLoaderDelegate> {

    IBOutlet UIBarButtonItem *searchButtonItem;
    IBOutlet UIBarButtonItem *bookmarksButtonItem;
    
    NSArray *otBooks;
    NSArray *ntBooks;
}


@end
