//
//  Book.h
//  bible-ios
//
//  Created by Joe on 7/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Book : NSObject {

   int bookId;
   NSString *name;
}

@property int bookId;
@property (nonatomic, retain) NSString *name;

@end
