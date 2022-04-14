//
//  DSFAppearanceManager+Listeners.swift
//
//  Created by Darren Ford on 28/2/22.
//  Copyright © 2022 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#if os(macOS)

import AppKit
import Foundation

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
		// Swift.print("DSFAppearanceManager: update")
		
		// Make sure that these occur on the main queue
		DispatchQueue.main.async { [weak self] in
			self?.update(change: change)
		}
	}
	
	private func update(change: StyleChangeType) {
		// Using the main thread here avoids race conditions on `self.queuedChanges`
		assert(Thread.isMainThread)
		
		// Update the local caches first
		self.updateCache()
		
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

#endif
