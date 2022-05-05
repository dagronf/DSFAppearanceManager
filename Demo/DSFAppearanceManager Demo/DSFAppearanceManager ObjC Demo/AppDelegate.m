//
//  AppDelegate.m
//  DSFAppearanceManager ObjC Demo
//
//  Created by Darren Ford on 14/4/2022.
//

#import "AppDelegate.h"

@import DSFAppearanceManager;

@interface AppDelegate () <DSFAppearanceManagerChangeCenterDetector>

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	[[DSFAppearanceManagerChangeCenter shared] register: self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
	[[DSFAppearanceManagerChangeCenter shared] deregister: self];
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
	return YES;
}

- (void)appearanceDidChange: (DSFAppearanceManagerChange*)change {
	NSLog(@"AppDelegate[register]: AppearanceDidChange");
}


@end
