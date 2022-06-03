//
//  AppDelegate.swift
//  DSFAppearanceManager Demo
//
//  Created by Darren Ford on 14/4/2022.
//

import Cocoa
import DSFAppearanceManager

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	var observer: NSObjectProtocol?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application

		self.observer = NotificationCenter.default.addObserver(
			forName: DSFAppearanceCache.ChangeNotificationName,
			object: DSFAppearanceManager.shared,
			queue: OperationQueue.main) { notification in
				Swift.print("AppDelegate[NotificationCenter] - appearance did change")
			}

	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}


}

extension AppDelegate: DSFAppearanceCacheNotifiable {
	func appearanceDidChange() {
		Swift.print("AppDelegate[RegisteredObject] - appearance did change")
	}
}
