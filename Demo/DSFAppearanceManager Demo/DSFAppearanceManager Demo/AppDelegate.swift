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

		DSFAppearanceManager.ChangeCenter.shared.register(self)

		self.observer = NotificationCenter.default.addObserver(
			forName: DSFAppearanceManager.ChangeCenter.ChangeNotification,
			object: DSFAppearanceManager.ChangeCenter.shared,
			queue: OperationQueue.main) { notification in
				let change = notification.userInfo?[DSFAppearanceManager.ChangeCenter.ChangeObject] as! DSFAppearanceManager.Change
				Swift.print("AppDelegate[NotificationCenter] - appearance did change (\(change))")
			}

	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}


}

extension AppDelegate: DSFAppearanceManagerChangeCenterDetector {
	func appearanceDidChange(_ change: DSFAppearanceManager.Change) {
		Swift.print("AppDelegate[RegisteredObject] - appearance did change (\(change))")
	}
}
