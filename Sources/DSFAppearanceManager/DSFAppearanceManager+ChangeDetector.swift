//
//  DSFAppearanceManager+ChangeDetector.swift
//
//  Created by Darren Ford on 21/6/21.
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
//  Simple example :-
//
//   let appearanceCapture = DSFAppearanceManager.ChangeDetector()
//
//   appearanceCapture.appearanceChangeCallback = { [weak self] appearanceManager, change in
//      self?.doSomething(change)
//   }

#if os(macOS)

import AppKit

public extension DSFAppearanceManager {
	/// Detect visibility changes in the UI
	class ChangeDetector: NSObject {
		/// The appearance manager being observed
		public let appearanceManager: DSFAppearanceManager
		
		/// A callback for when the appearance changes. Guaranteed to always be called on the main thread
		public var appearanceChangeCallback: ((DSFAppearanceManager, DSFAppearanceManager.Change) -> Void)?
		
		public init(appearanceManager: DSFAppearanceManager = DSFAppearanceManager.shared) {
			self.appearanceManager = appearanceManager
			super.init()
			self.observer = self.appearanceManager.addObserver(queue: .main) { [weak self] notify in
				guard
					let `self` = self,
					let info = notify.userInfo?[DSFAppearanceManager.AppearanceManagerChange],
					let changeType = info as? DSFAppearanceManager.Change
				else {
					fatalError()
				}
				self.appearanceDidChange(changeType)
			}
		}
		
		deinit {
			self.observer = nil
			self.appearanceChangeCallback = nil
		}
		
		// Privates
		
		private var observer: NSObjectProtocol?
		
		@objc private func appearanceDidChange(_ change: DSFAppearanceManager.Change) {
			assert(Thread.isMainThread)
			self.appearanceChangeCallback?(self.appearanceManager, change)
		}
	}
}

#endif
