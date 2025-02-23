//
//  Copyright © 2025 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  With help from
//    https://chromium.googlesource.com/chromium/src/+/master/content/renderer/theme_helper_mac.mm
//    https://bugzilla.mozilla.org/show_bug.cgi?id=1062801
//

#if os(macOS)

import AppKit
import Foundation

/// Apple notifications for theme changes
internal extension NSNotification.Name {
	static let ThemeChangedNotification = NSNotification.Name("AppleInterfaceThemeChangedNotification")
	static let AccentChangedNotification = NSNotification.Name("AppleColorPreferencesChangedNotification")
	static let AquaVariantChangeNotification = NSNotification.Name("AppleAquaColorVariantChanged")
	static let SystemColorsChangeNotification = NSNotification.Name("NSSystemColorsDidChangeNotification")
}

internal extension DSFAppearanceManager {
	func installNotificationListeners() {
		// Listen for appearance changes
		self.distributedNotificationCenter.addObserver(
			self,
			selector: #selector(self.themeChange),
			name: NSNotification.Name.ThemeChangedNotification,
			object: nil
		)
		
		// Listen for accent changes
		self.distributedNotificationCenter.addObserver(
			self,
			selector: #selector(self.accentChange),
			name: NSNotification.Name.AccentChangedNotification,
			object: nil
		)
		
		// Listen for aqua variant changes
		self.distributedNotificationCenter.addObserver(
			self,
			selector: #selector(self.aquaVariantChange),
			name: NSNotification.Name.AquaVariantChangeNotification,
			object: nil
		)
		
		// Listen for changes on NSSystemColorsDidChangeNotification (user changed the accent color)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.systemColorsChange),
			name: NSNotification.Name.SystemColorsChangeNotification,
			object: nil
		)
		
		// Listen for changes on NSWorkspace.didChangeFileLabelsNotification (the accent name or color changed)
		NSWorkspace.shared.notificationCenter.addObserver(
			self,
			selector: #selector(self.finderLabelsDidChange),
			name: NSWorkspace.didChangeFileLabelsNotification,
			object: nil
		)
		
		// Accessibility changes
		NSWorkspace.shared.notificationCenter.addObserver(
			self,
			selector: #selector(self.accessibilityDidChange),
			name: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
			object: NSWorkspace.shared
		)

		// Autoplay animated images changes
		if let axName = AutoplayAnimatedImagesNotificationName() {
			NotificationCenter.default.addObserver(
				self,
				selector: #selector(animatedImagesChanged),
				name: axName,
				object: nil
			)
		}
	}
	
	@objc private func animatedImagesChanged(_ notification: Notification) {
		self.appearanceDidChange(change: .autoplayAnimatedImages)
	}

	@objc private func themeChange() {
		self.appearanceDidChange(change: .theme)
	}
	
	@objc private func accentChange() {
		self.appearanceDidChange(change: .accent)
	}
	
	@objc private func aquaVariantChange() {
		self.appearanceDidChange(change: .aquaVariant)
	}
	
	@objc private func systemColorsChange() {
		self.appearanceDidChange(change: .systemColors)
	}
	
	@objc private func finderLabelsDidChange() {
		self.appearanceDidChange(change: .finderLabelColorsChanged)
	}
	
	@objc private func accessibilityDidChange() {
		self.appearanceDidChange(change: .accessibility)
	}
	
	private func appearanceDidChange(change: StyleChangeType) {
		// Make sure that these occur on the main queue
		DispatchQueue.main.async { [weak self] in
			self?.update(change: change)
		}
	}
	
	private func update(change: StyleChangeType) {
		// Using the main thread here avoids race conditions on `self.queuedChanges`
		assert(Thread.isMainThread)
		
		// Update the queue with the new change type
		self.queuedChanges.add(change: change)
		
		// And debounce, so that we don't receive lots of messages for a single change
		self.debouncer.debounce { [weak self] in
			self?.postChanges()
		}
	}
	
	private func postChanges() {
		// Using the main thread here avoids race conditions on `self.queuedChanges`
		assert(Thread.isMainThread)
		
		// Take ownership of the current set of queued changes
		let ch = self.queuedChanges
		self.queuedChanges = Change()
		self.notificationCenter.post(
			name: DSFAppearanceManager.AppearanceChangedNotification,
			object: self,
			userInfo: [DSFAppearanceManager.AppearanceManagerChange: ch]
		)
	}
}

// MARK: - Observers and Listeners

internal extension DSFAppearanceManager {
	// Adds an entry to the notification center to call the provided selector with the notification.
	func addObserver(_ observer: Any, selector aSelector: Selector) {
		self.notificationCenter.addObserver(
			observer,
			selector: aSelector,
			name: DSFAppearanceManager.AppearanceChangedNotification,
			object: self
		)
	}

	// Adds an entry to the notification center to receive notifications that passed to the provided block.
	func addObserver(queue: OperationQueue? = nil, using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
		return NotificationCenter.default.addObserver(
			forName: DSFAppearanceManager.AppearanceChangedNotification,
			object: self,
			queue: queue,
			using: block
		)
	}

	// Removes all entries specifying an observer from the notification center's dispatch table
	func removeObserver(_ observer: NSObject) {
		self.notificationCenter.removeObserver(observer)
	}
}

#endif
