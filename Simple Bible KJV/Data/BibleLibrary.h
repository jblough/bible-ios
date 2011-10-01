//
//  BibleLibrary.h
//  bible-ios
//
//  Created by Joe on 7/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

#import "Book.h"
#import "Verse.h"
#import "Bookmark.h"


@protocol SelectChapterDelegate <NSObject>
- (void)selectChapter:(int)bookId;
@end


@interface BibleLibrary : NSObject {

   sqlite3 *database;

}

+ (NSString *)databaseFilePath;

- (NSArray *)loadBooks;
- (NSArray *)loadBooks:(int)testamentId;
- (Book *)loadBook:(int)bookId;
- (int)chapterCount:(int)bookId;
- (int)verseCount:(int)bookId chapter:(int)chapter;
- (NSArray *)loadVerses:(int)bookId chapter:(int)chapter;
- (Verse *)loadVerse:(int)bookId chapter:(int)chapter verseNumber:(int)verseNumber;
- (Verse *)loadVerse:(int)verseId;
- (Bookmark *)loadBookmark:(int)verseId;
- (NSArray *)searchVerses:(NSString *)where;

@end
