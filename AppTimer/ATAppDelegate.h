//
//  ATAppDelegate.h
//  AppTimer
//
//  Created by Matthias Arndt on 18.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ATAppDelegate : NSObject <NSApplicationDelegate>
{
	IBOutlet NSTextField *textField;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) int secondsLeft;
@property (retain) NSString *applicationBundleID;
@property (retain) NSTimer *applicationTimer;

@end
