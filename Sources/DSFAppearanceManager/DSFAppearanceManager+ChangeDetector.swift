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

public extension DSFAppearanceManager {
	/// An appearance change detector object.
	///
	/// The `ChangeDetector` object receives notifcations from the system when appearance, accessibility and/or
	/// theme changes occur for the current user (eg. the system changes from dark to light).
	///
	/// Simple example :-
	///
	/// ```swift
	/// class MyVisibleView: NSView {
	///    let appearanceCapture = DSFAppearanceManager.ChangeDetector()
	/// ...
	///    init() {
	///       super.init()
	///       appearanceCapture.appearanceChangeCallback = { [weak self] change in
	///          self?.doSomething(change)
	///    }
	/// }
	@objc(DSFAppearanceManagerChangeDetector)
	class ChangeDetector: NSObject {
		/// A callback for when the appearance changes. Guaranteed to be called on the main thread.
		///
		/// Note: Make sure to use [weak self] in the block when necessary to avoid retain cycles.
		@objc public var appearanceChangeCallback: ((DSFAppearanceManager.Change) -> Void)?

		/// Create a change detector with no initial callback
		@objc override public init() {
			super.init()
			self.observer = DSFAppearanceManager.shared.addObserver(queue: .main) { [weak self] notify in
				guard let `self` = self else {
					// we've gone away (which is valid). Ignore this callback
					return
				}

				guard
					let info = notify.userInfo?[DSFAppearanceManager.AppearanceManagerChange],
					let changeType = info as? DSFAppearanceManager.Change
				else {
					// Incorrect programming? The change object is unavailable
					fatalError()
				}
				self.appearanceDidChange(changeType)
			}
		}

		/// Create a change detector with an appearance change callback
		/// - Parameter appearanceChangeCallback: The block to call when the appearance changes
		@objc public convenience init(appearanceChangeCallback: @escaping ((DSFAppearanceManager.Change) -> Void)) {
			self.init()
			self.appearanceChangeCallback = appearanceChangeCallback
		}

		deinit {
			self.observer = nil
			self.appearanceChangeCallback = nil
		}

		// Privates

		private var observer: NSObjectProtocol?

		@objc private func appearanceDidChange(_ change: DSFAppearanceManager.Change) {
			assert(Thread.isMainThread)
			self.appearanceChangeCallback?(change)
		}
	}
}

public extension DSFAppearanceManager {
	/// The current set of appearance changes that occurred for the current change
	@objc(DSFAppearanceManagerChange)
	class Change: NSObject {
		/// The changes that occurred
		public private(set) var changes = Set<StyleChangeType>()

		/// The changes that occurred as an NSSet (objc)
		@objc public var nsChanges: NSSet {
			return NSSet(set: self.changes)
		}

		@objc override public var description: String {
			self.changes.map { $0.name }.joined(separator: ", ")
		}

		internal func add(change: StyleChangeType) {
			self.changes.insert(change)
		}
	}
}

#endif
