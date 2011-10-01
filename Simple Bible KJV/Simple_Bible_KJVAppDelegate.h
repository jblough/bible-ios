//
//  Simple_Bible_KJVAppDelegate.h
//  Simple Bible KJV
//
//  Created by Joe on 9/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BibleLibrary.h"

@interface Simple_Bible_KJVAppDelegate : NSObject <UIApplicationDelegate> {

    BibleLibrary *library;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) BibleLibrary *library;

@end
