//
//  Bookmark.m
//  Simple Bible KJV
//
//  Created by Joe on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Bookmark.h"
#import "Simple_Bible_KJVAppDelegate.h"
#import "BibleLibrary.h"

#define BOOKMARKS_KEY @"bookmarks"

@implementation Bookmark

@synthesize verseId, bookName, bookId, chapter, verseNumber;

- (void)dealloc {
    [bookName release];
    
    [super dealloc];
}

+ (NSArray *)loadBookmarks {
    NSMutableArray *bookmarks = [[NSMutableArray alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *bookmarkVerseIds = [defaults arrayForKey:BOOKMARKS_KEY];
    
    if (bookmarkVerseIds) {
        BibleLibrary *library = ((Simple_Bible_KJVAppDelegate *)[UIApplication sharedApplication].delegate).library;
        for (NSNumber *bookmarkVerseId in bookmarkVerseIds) {
            Bookmark *bookmark = [library loadBookmark:[bookmarkVerseId intValue]];
            [bookmarks addObject:bookmark];
            [bookmark release];
        }
    }
    
    return bookmarks;
}

+ (void)addBookmark:(int)verseId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *defaultBookmarks = [defaults arrayForKey:BOOKMARKS_KEY];
    
    if (!defaultBookmarks || ![defaultBookmarks containsObject:[NSNumber numberWithInt:verseId]]) {
        NSMutableArray *bookmarks = [[NSMutableArray alloc] init];
        
        // Add in all the old bookmarks
        if (defaultBookmarks != nil) {
            [bookmarks addObjectsFromArray:defaultBookmarks];
        }

        // Add the new bookmark
        [bookmarks addObject:[NSNumber numberWithInt:verseId]];
        
        // Save the bookmarks
        [defaults setValue:bookmarks forKey:BOOKMARKS_KEY];
        [bookmarks release];
    }
}

+ (void)removeBoomark:(int)verseId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *defaultBookmarks = [defaults arrayForKey:BOOKMARKS_KEY];

    if (defaultBookmarks && [defaultBookmarks containsObject:[NSNumber numberWithInt:verseId]]) {
        NSMutableArray *bookmarks = [[NSMutableArray alloc] init];
        
        // Add in all the old bookmarks
        if (defaultBookmarks != nil) {
            [bookmarks addObjectsFromArray:defaultBookmarks];
        }
        
        // Remove the bookmark
        [bookmarks removeObject:[NSNumber numberWithInt:verseId]];
        
        // Save the bookmarks
        [defaults setValue:bookmarks forKey:BOOKMARKS_KEY];
        [bookmarks release];
    }
}

+ (void)saveBookmarks:(NSArray *)bookmarks {

    // Replace all existing bookmarks with the verse IDs from the passed in array
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *bookmarkVerseIds = [[NSMutableArray alloc] initWithCapacity:[bookmarks count]];
    
    for (Bookmark *bookmark in bookmarks) {
        [bookmarkVerseIds addObject:[NSNumber numberWithInt:bookmark.verseId]];
    }
    
    // Save the bookmarks
    [defaults setValue:bookmarkVerseIds forKey:BOOKMARKS_KEY];
    
    [bookmarkVerseIds release];
                                         
}

@end
