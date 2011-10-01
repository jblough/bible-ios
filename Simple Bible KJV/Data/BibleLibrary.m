//
//  BibleLibrary.m
//  bible-ios
//
//  Created by Joe on 7/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BibleLibrary.h"

@implementation BibleLibrary

+ (NSString *)databaseFilePath {
   return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"bible.db"];
}

- (id)init {
   self = [super init];
   if (self != nil) {
      if (sqlite3_open([[BibleLibrary databaseFilePath] UTF8String], &database) != SQLITE_OK) {
         NSAssert(0, @"Failed to open Bible database");
      }
   }
   return self;
}

- (void)dealloc {
   sqlite3_close(database);
   
   [super dealloc];
}

- (NSArray *)loadBooks {
   NSMutableArray *books = [[NSMutableArray alloc] init];
   
   NSAutoreleasePool *pool = [NSAutoreleasePool new];
   NSString *query = @"SELECT id, Book FROM Books ORDER BY id";
   sqlite3_stmt *statement;
   if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
      while (sqlite3_step(statement) == SQLITE_ROW) {
         Book *book = [[Book alloc] init];
         book.bookId = sqlite3_column_int(statement, 0);
			char *str = (char*)sqlite3_column_text(statement, 1);
         book.name = (str) ? [NSString stringWithUTF8String:str]: @"";
         
         [books addObject:book];
         [book release];
      }
      sqlite3_reset(statement);
   }
   sqlite3_finalize(statement);
   [pool release];
   
   return books;
}

- (NSArray *)loadBooks:(int)testamentId {
   NSMutableArray *books = [[NSMutableArray alloc] init];
   
   NSAutoreleasePool *pool = [NSAutoreleasePool new];
   NSString *query = @"SELECT id, Book FROM Books WHERE TestamentID = ? ORDER BY id";
   sqlite3_stmt *statement;
   if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
      sqlite3_bind_int(statement, 1, testamentId);
      while (sqlite3_step(statement) == SQLITE_ROW) {
         Book *book = [[Book alloc] init];
         book.bookId = sqlite3_column_int(statement, 0);
			char *str = (char*)sqlite3_column_text(statement, 1);
         book.name = (str) ? [NSString stringWithUTF8String:str]: @"";
         
         [books addObject:book];
         [book release];
      }
      sqlite3_reset(statement);
   }
   sqlite3_finalize(statement);
   [pool release];
   
   return books;
}

- (Book *)loadBook:(int)bookId {
   Book *book = nil;
   
   NSAutoreleasePool *pool = [NSAutoreleasePool new];
   NSString *query = @"SELECT id, Book FROM Books WHERE id = ?";
   sqlite3_stmt *statement;
   if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
      sqlite3_bind_int(statement, 1, bookId);
      while (sqlite3_step(statement) == SQLITE_ROW) {
         book = [[Book alloc] init];
         book.bookId = sqlite3_column_int(statement, 0);
			char *str = (char*)sqlite3_column_text(statement, 1);
         book.name = (str) ? [NSString stringWithUTF8String:str]: @"";
      }
      sqlite3_reset(statement);
   }
   sqlite3_finalize(statement);
   [pool release];
   
   return book;
}

- (int)chapterCount:(int)bookId {
   int count = 0;
   
   NSAutoreleasePool *pool = [NSAutoreleasePool new];
   NSString *query = @"SELECT MAX(Chapter) AS count FROM Verses WHERE BookID = ?";
   sqlite3_stmt *statement;
   if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
      sqlite3_bind_int(statement, 1, bookId);
      while (sqlite3_step(statement) == SQLITE_ROW) {
         count = sqlite3_column_int(statement, 0);
      }
      sqlite3_reset(statement);
   }
   sqlite3_finalize(statement);
   [pool release];
   
   return count;
}

- (int)verseCount:(int)bookId chapter:(int)chapter {
   int count = 0;
   
   NSAutoreleasePool *pool = [NSAutoreleasePool new];
   NSString *query = @"SELECT MAX(Verse) AS count FROM Verses WHERE BookID = ? AND Chapter = ?";
   sqlite3_stmt *statement;
   if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
      sqlite3_bind_int(statement, 1, bookId);
      sqlite3_bind_int(statement, 2, chapter);
      while (sqlite3_step(statement) == SQLITE_ROW) {
         count = sqlite3_column_int(statement, 0);
      }
      sqlite3_reset(statement);
   }
   sqlite3_finalize(statement);
   [pool release];
   
   return count;
}

- (NSArray *)loadVerses:(int)bookId chapter:(int)chapter {
   NSMutableArray *verses = [[NSMutableArray alloc] init];
   
   NSAutoreleasePool *pool = [NSAutoreleasePool new];
   NSString *query = @"SELECT id, BookID, Chapter, Verse, VerseText FROM Verses WHERE BookID = ? AND Chapter = ? ORDER BY BookID ASC, Chapter ASC, Verse ASC";
   sqlite3_stmt *statement;
   if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
      sqlite3_bind_int(statement, 1, bookId);
      sqlite3_bind_int(statement, 2, chapter);
      while (sqlite3_step(statement) == SQLITE_ROW) {
         Verse *verse = [[Verse alloc] init];
         verse.verseId = sqlite3_column_int(statement, 0);
         verse.bookId = sqlite3_column_int(statement, 1);
         verse.chapter = sqlite3_column_int(statement, 2);
         verse.number = sqlite3_column_int(statement, 3);
			char *str = (char*)sqlite3_column_text(statement, 4);
         verse.text = (str) ? [NSString stringWithUTF8String:str]: @"";
         
         [verses addObject:verse];
         [verse release];
      }
      sqlite3_reset(statement);
   }
   sqlite3_finalize(statement);
   [pool release];
   
   return verses;
}

- (Verse *)loadVerse:(int)bookId chapter:(int)chapter verseNumber:(int)verseNumber {
   Verse *verse = nil;
   
   NSAutoreleasePool *pool = [NSAutoreleasePool new];
   NSString *query = @"SELECT id, BookID, Chapter, Verse, VerseText FROM Verses WHERE BookID = ? AND Chapter = ? AND Verse = ?";
   sqlite3_stmt *statement;
   if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
      sqlite3_bind_int(statement, 1, bookId);
      sqlite3_bind_int(statement, 2, chapter);
      sqlite3_bind_int(statement, 3, verseNumber);
      while (sqlite3_step(statement) == SQLITE_ROW) {
          verse = [[Verse alloc] init];
          verse.verseId = sqlite3_column_int(statement, 0);
          verse.bookId = sqlite3_column_int(statement, 1);
          verse.chapter = sqlite3_column_int(statement, 2);
          verse.number = sqlite3_column_int(statement, 3);
          char *str = (char*)sqlite3_column_text(statement, 4);
          verse.text = (str) ? [NSString stringWithUTF8String:str]: @"";
      }
      sqlite3_reset(statement);
   }
   sqlite3_finalize(statement);
   [pool release];
   
   return verse;
}

- (Verse *)loadVerse:(int)verseId {

   Verse *verse = nil;
   
   NSAutoreleasePool *pool = [NSAutoreleasePool new];
   NSString *query = @"SELECT id, BookID, Chapter, Verse, VerseText FROM Verses WHERE id = ?";
   sqlite3_stmt *statement;
   if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
      sqlite3_bind_int(statement, 1, verseId);
      while (sqlite3_step(statement) == SQLITE_ROW) {
          verse = [[Verse alloc] init];
          verse.verseId = sqlite3_column_int(statement, 0);
          verse.bookId = sqlite3_column_int(statement, 1);
          verse.chapter = sqlite3_column_int(statement, 2);
          verse.number = sqlite3_column_int(statement, 3);
          char *str = (char*)sqlite3_column_text(statement, 4);
          verse.text = (str) ? [NSString stringWithUTF8String:str]: @"";
      }
      sqlite3_reset(statement);
   }
   sqlite3_finalize(statement);
   [pool release];
   
   return verse;
}

- (Bookmark *)loadBookmark:(int)verseId {
    
    Bookmark *bookmark = nil;
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSString *query = @"SELECT v.id, b.Book, v.BookID, v.Chapter, v.Verse FROM Verses v JOIN Books b ON v.BookID = b.id WHERE v.id = ?";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_int(statement, 1, verseId);
        while (sqlite3_step(statement) == SQLITE_ROW) {
            bookmark = [[Bookmark alloc] init];
            bookmark.verseId = sqlite3_column_int(statement, 0);
            char *str = (char*)sqlite3_column_text(statement, 1);
            bookmark.bookName = (str) ? [NSString stringWithUTF8String:str]: @"";
            bookmark.bookId = sqlite3_column_int(statement, 2);
            bookmark.chapter = sqlite3_column_int(statement, 3);
            bookmark.verseNumber = sqlite3_column_int(statement, 4);
        }
        sqlite3_reset(statement);
    }
    sqlite3_finalize(statement);
    [pool release];
    
    return bookmark;
}


- (NSArray *)searchVerses:(NSString *)where {
   NSMutableArray *verses = [[NSMutableArray alloc] init];
   
   NSAutoreleasePool *pool = [NSAutoreleasePool new];
   NSString *query = [NSString stringWithFormat:@"SELECT id, BookID, Chapter, Verse, VerseText FROM Verses WHERE %@ ORDER BY BookID ASC, Chapter ASC, Verse ASC", where];
   sqlite3_stmt *statement;
   if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
      while (sqlite3_step(statement) == SQLITE_ROW) {
          Verse *verse = [[Verse alloc] init];
          verse.verseId = sqlite3_column_int(statement, 0);
          verse.bookId = sqlite3_column_int(statement, 1);
          verse.chapter = sqlite3_column_int(statement, 2);
          verse.number = sqlite3_column_int(statement, 3);
          char *str = (char*)sqlite3_column_text(statement, 4);
          verse.text = (str) ? [NSString stringWithUTF8String:str]: @"";
          
          [verses addObject:verse];
          [verse release];
      }
      sqlite3_reset(statement);
   }
   sqlite3_finalize(statement);
   [pool release];
   
   return verses;
}

@end
