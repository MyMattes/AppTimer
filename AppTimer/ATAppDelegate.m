//
//  ATAppDelegate.m
//  AppTimer
//
//  Created by Matthias Arndt on 18.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// Button zum Zurücksetzen

#import "ATAppDelegate.h"

@implementation ATAppDelegate

@synthesize window = _window;
@synthesize secondsLeft;
@synthesize applicationBundleID;
@synthesize applicationTimer;

- (void)dealloc
{
	[super dealloc];
	[textField release], textField = nil;
	[applicationBundleID release], applicationBundleID = nil;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[[NSApplication sharedApplication] hide:self];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[self setSecondsLeft:[defaults integerForKey:@"kSecondsLeft"]];
	if ([self secondsLeft] == 0) [self setSecondsLeft:[self resetSeconds]];
	[self setApplicationBundleID:[defaults stringForKey:@"kApplicationBundleID"]];
	if ([self applicationBundleID] == nil) [self setApplicationBundleID:@"com.Mojang Specifications.Minecraft.Minecraft"];

	NSLog(@"Monitoring \"%@\" started.", [self applicationBundleID]);

	NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
	[nc addObserver:self selector:@selector(launchedApplication:) name:@"NSWorkspaceDidLaunchApplicationNotification" object:nil];
	[nc addObserver:self selector:@selector(stoppedApplication:) name:@"NSWorkspaceDidTerminateApplicationNotification" object:nil];
	
	NSArray *runningApplications = [[NSWorkspace sharedWorkspace] runningApplications];
	for (NSRunningApplication *runningApplication in runningApplications)
	{
		NSString *runningBundleID = [runningApplication bundleIdentifier];
		if ([runningBundleID isEqualToString:[self applicationBundleID]])
		{
			NSLog(@"Running \"%@\" detected, %i seconds left.", [self applicationBundleID], [self secondsLeft]);
			[self timerStart];
		}
	}

	[self refreshDisplay];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[self timerStop];

	NSLog(@"Monitoring \"%@\" stopped.", [self applicationBundleID]);

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:[self secondsLeft] forKey:@"kSecondsLeft"];
	[defaults setObject:[self applicationBundleID] forKey:@"kApplicationBundleID"];
	
	NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
	[nc removeObserver:self];
}

- (void)launchedApplication:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSString *launchedBundleID = [userInfo valueForKey:@"NSApplicationBundleIdentifier"];
	
	if ([launchedBundleID isEqualToString:[self applicationBundleID]])
	{
		NSLog(@"Launching \"%@\" detected, %i seconds left.", [self applicationBundleID], [self secondsLeft]);
		[self timerStart];
	}
}

- (void)stoppedApplication:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSString *launchedBundleID = [userInfo valueForKey:@"NSApplicationBundleIdentifier"];

	if ([launchedBundleID isEqualToString:[self applicationBundleID]])
	{
		NSLog(@"Terminating \"%@\" detected, %i seconds left.", [self applicationBundleID], [self secondsLeft]);
		[self timerStop];
	}
}

- (void)timerStart
{
	[self setApplicationTimer:[NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerUpdate:) userInfo:nil repeats:YES]];
	[[NSRunLoop currentRunLoop] addTimer:[self applicationTimer] forMode:NSRunLoopCommonModes];
}

- (void)timerUpdate:(NSTimer *)timer
{
	[self setSecondsLeft:[self secondsLeft] - 1];
	[self refreshDisplay];
	if ([self secondsLeft] == 0) [self timerElapsed:timer];
}

- (IBAction)timerReset:(id)sender
{
	[self setSecondsLeft:[self resetSeconds]];
	[self refreshDisplay];
}

- (void)timerStop
{
	if (![[self applicationTimer] isValid]) return;
	[[self applicationTimer] invalidate];
	[self refreshDisplay];	
}

- (void)timerElapsed:(NSTimer *)timer
{
	[[NSApplication sharedApplication] unhide:self];

	NSSound *systemSound = [NSSound soundNamed:@"alarm.aif"];
	if (systemSound) [systemSound play];
}

- (void)refreshDisplay
{
	int hours = [self secondsLeft] / 3600;
	int minutes = ([self secondsLeft] - hours * 3600) / 60;
	int seconds = [self secondsLeft] - hours * 3600 - minutes * 60;
	
	if ([[self applicationTimer] isValid]) [textField setTextColor:[NSColor blueColor]];
	else [textField setTextColor:[NSColor blackColor]];
	
	if ([self secondsLeft] <= 0) [textField setTextColor:[NSColor redColor]];
	
	[textField setStringValue:[NSString stringWithFormat:@"%02i:%02i:%02i", hours, ABS(minutes), ABS(seconds)]];
}

- (int)resetSeconds
{
	return 5400;
}

@end
