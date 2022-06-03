//
//  AppDelegate.m
//  DSFAppearanceManager ObjC Demo
//
//  Created by Darren Ford on 14/4/2022.
//

#import "AppDelegate.h"

@import DSFAppearanceManager;

@interface AppDelegate () <DSFAppearanceCacheNotifiable>

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	[[DSFAppearanceCache shared] register: self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
	[[DSFAppearanceCache shared] deregister: self];
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
	return YES;
}

- (void)appearanceDidChange {
	NSLog(@"AppDelegate[register]: AppearanceDidChange");
}


@end
