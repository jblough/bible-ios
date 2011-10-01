//
//  Bookmarks.h
//  bible-ios
//
//  Created by Joe on 7/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Bookmark : NSObject {

    int verseId;
    NSString *bookName;
    int bookId;
    int chapter;
    int verseNumber;
}

@property int verseId;
@property (nonatomic, retain) NSString *bookName;
@property int bookId;
@property int chapter;
@property int verseNumber;

+ (NSArray *)loadBookmarks;
+ (void)addBookmark:(int)verseId;
+ (void)removeBoomark:(int)verseId;
+ (void)saveBookmarks:(NSArray *)bookmarks;

@end
