//
//  SearchViewController.h
//  Simple Bible KJV
//
//  Created by Joe on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Book;

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITextField *searchField;
    IBOutlet UISegmentedControl *searchType;
    IBOutlet UISegmentedControl *searchScope;
    IBOutlet UITableView *selectBooksTable;

    NSArray *otBooks;
    NSArray *ntBooks;
    
    NSMutableArray *selectedBooksLookup;
}

- (IBAction)search:(id)sender;
- (IBAction)scopeChange:(id)sender;
- (IBAction)closeKeyboard:(id)sender;

- (Book *)getBook:(NSIndexPath *)indexPath;

@end
