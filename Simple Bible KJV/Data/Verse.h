//
//  Verse.h
//  bible-ios
//
//  Created by Joe on 7/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Verse : NSObject {

   int verseId;
   int number;
   NSString *text;
   int bookId;
   int chapter;
}

@property int verseId;
@property int number;
@property (nonatomic, retain) NSString *text;
@property int bookId;
@property int chapter;

@end
