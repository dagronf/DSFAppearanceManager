//
//  DSFAppearanceNotifier.swift
//
//  Created by Darren Ford on 5/5/22.
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
//  With help from
//    https://chromium.googlesource.com/chromium/src/+/master/content/renderer/theme_helper_mac.mm
//    https://bugzilla.mozilla.org/show_bug.cgi?id=1062801
//

import Foundation

/// A protocol 
@objc public protocol DSFAppearanceManagerChangeCenterDetector: NSObjectProtocol {
	/// Called when the appearance changes
	/// - Parameter change: The change object indicating the type of change that occurred
	@objc func appearanceDidChange(_ change: DSFAppearanceManager.Change)
}

public extension DSFAppearanceManager {
	/// A centralizable appearance notification class
	///
	/// When dealing with a _lot_ of objects, it can be advantageous to centralize the change detection.
	///
	/// This class provides two mechanisms for detecting appearance changes for registered objects.
	///
	/// #### Using the notification center
	///
	/// A `ChangeCenter` object posts notifications on the default notification center (`NotificationCenter.default`)
	///
	/// Notification Center Example :-
	///
	/// ```swift
	///  NotificationCenter.default.addObserver(
	///     forName: DSFAppearanceManager.ChangeCenter.ChangeNotification,
	///     object: DSFAppearanceManager.ChangeCenter.shared,
	///     queue: OperationQueue.main) { notification in
	///        let change = notification.userInfo?[DSFAppearanceManager.ChangeCenter.ChangeObject] as? DSFAppearanceManager.Change
	///        // Do something with 'change'
	///     }
	/// ```
	///
	/// #### Using object registration
	///
	/// You can register objects that conform to `DSFAppearanceManagerChangeCenterDetector` with a `ChangeCenter` object.
	///
	/// Registered objects are held weakly and the protocol method `appearanceDidChange` will be called when the appearance changes
	///
	/// Registration example :-
	///
	/// ```swift
	/// class MyVisibleObject: CustomView, DSFAppearanceManagerChangeCenterDetector {
	///    init() {
	///       super.init()
	///       DSFAppearanceManager.ChangeCenter.shared.register(self)
	///    }
	///    deinit {
	///       DSFAppearanceManager.ChangeCenter.shared.deregister(self)
	///    }
	///
	///    func appearanceDidChange(_ change: DSFAppearanceManager.Change) {
	///       // Do something with `change`
	///    }
	/// }
	/// ```
	///
	@objc(DSFAppearanceManagerChangeCenter)
	class ChangeCenter: NSObject {

		/// A shared global appearance notification object
		@objc public static let shared = DSFAppearanceManager.ChangeCenter()

		/// The notification sent when a change occurs in the appearance.
		@objc(DSFAppearanceManagerChangeCenterChangeNotification)
		public static let ChangeNotification = NSNotification.Name("DSFAppearanceManagerChangeCenterChangeNotification")
		/// Key for the notification containing the type(s) of changes that occured.
		@objc(DSFAppearanceManagerChangeCenterChangeObject)
		public static let ChangeObject = "DSFAppearanceManagerChangeCenterChangeObject"

		/// Create a change center object
		@objc public override init() {
			super.init()
			self.change.appearanceChangeCallback = { [weak self] change in
				// This will always be called on the main thread
				assert(Thread.isMainThread)

				guard let `self` = self else { return }
				Foundation.NotificationCenter.default.post(
					name: ChangeCenter.ChangeNotification,
					object: self,
					userInfo: [ChangeCenter.ChangeObject: change]
				)
				self.listeners.items.forEach { $0.appearanceDidChange(change) }
			}
		}

		/// Register an object to receive calls
		///
		/// `listener` is held weakly within the change center, so the caller is responsible for handling the lifetime of `listener`.
		@objc public func register(_ listener: DSFAppearanceManagerChangeCenterDetector) {
			self.listeners.add(listener)
		}

		/// Deregister an object
		@objc public func deregister(_ listener: DSFAppearanceManagerChangeCenterDetector) {
			self.listeners.remove(listener)
		}

		// private

		deinit {
			self.change.appearanceChangeCallback = nil
			self.listeners.removeAll()
		}

		private let change = DSFAppearanceManager.ChangeDetector()
		private var listeners = WeakBag<DSFAppearanceManagerChangeCenterDetector>()
	}
}
