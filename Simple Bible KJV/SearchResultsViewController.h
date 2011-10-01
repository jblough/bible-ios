//
//  SearchResultsViewController.h
//  Simple Bible KJV
//
//  Created by Joe on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface SearchResultsViewController : UITableViewController <MBProgressHUDDelegate> {
 
    IBOutlet UILabel *searchResultsHeader;
    IBOutlet UITableViewCell *verseCell;
	MBProgressHUD *HUD;
    
    UIFont *font;
    CGSize cellSize;
    
    NSString *searchTerm;
    int searchMethod;
    int searchScope;
    NSArray *searchBooks;
    
    NSArray *searchResults;
}

@property (nonatomic, assign) IBOutlet UITableViewCell *verseCell;

- (id)initWithSearchTerm:(NSString *)search method:(int)method scope:(int)scope books:(NSArray *)books;
- (NSString *)generateSearchString;

@end
