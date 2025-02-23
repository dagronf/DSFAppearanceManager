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

/// A protocol for receiving appearance notifications
@objc public protocol DSFAppearanceCacheNotifiable: NSObjectProtocol {
	@objc func appearanceDidChange()
}

/// A centralizable appearance notification class
///
/// When dealing with a _lot_ of objects, it can be advantageous to centralize the change detection.
///
/// This class provides two mechanisms for detecting appearance changes for registered objects.
///
/// #### Using the notification center
///
/// A `DSFAppearanceCache` object posts notifications on the default notification center (`NotificationCenter.default`)
///
/// Notification Center Example :-
///
/// ```swift
/// self.observer = NotificationCenter.default.addObserver(
///    forName: DSFAppearanceCache.ChangeNotificationName,
///    object: DSFAppearanceCache.shared,
///    queue: OperationQueue.main) { _ in
///       // Do something with the change
///    }
/// ```
///
/// #### Using object registration
///
/// You can register objects that conform to `DSFAppearanceCacheNotifiable` with a `DSFAppearanceCache` object.
///
/// Registered objects are held weakly and the protocol method `appearanceDidChange` will be called when the appearance changes
///
/// Registration example :-
///
/// ```swift
/// class MyVisibleObject: CustomView, DSFAppearanceCacheNotifiable {
///    init() {
///       super.init()
///       DSFAppearanceCache.shared.register(self)
///    }
///    deinit {
///       DSFAppearanceCache.shared.deregister(self)
///    }
///
///    func appearanceDidChange() {
///       // Do something
///    }
/// }
/// ```
///
@objc public class DSFAppearanceCache: NSObject {

	/// The notification sent when a change occurs in the appearance.
	@objc(DSFAppearanceCacheChangeNotificationName)
	public static let ChangeNotificationName = NSNotification.Name("DSFAppearanceCacheChangeNotification")

	/// A shared appearance cache
	@objc public static let shared = DSFAppearanceCache()

	/// Is the system mode dark?
	@objc public private(set) var isDark: Bool = DSFAppearanceManager.IsDark

	/// Are the menu bars and dock being displayed as dark (Yosemite and later)
	@objc public private(set) var isDarkMenu: Bool = DSFAppearanceManager.IsDarkMenu

	/// Get the current accessibility display option for high-contrast UI.  If this is true, UI should be presented with high contrast such as utilizing a less subtle color palette or bolder lines.
	@objc public private(set) var increaseContrast: Bool = DSFAppearanceManager.IncreaseContrast

	/// Get the current accessibility display option for reduce transparency. If this property's value is true, UI (mainly window) backgrounds should not be semi-transparent; they should be opaque.
	@objc public private(set) var reduceTransparency: Bool = DSFAppearanceManager.ReduceTransparency

	/// Get the current accessibility display option for reduce motion. If this property's value is true, UI should avoid large animations, especially those that simulate the third dimension.
	@objc public private(set) var reduceMotion: Bool = DSFAppearanceManager.ReduceMotion

	/// Returns the user's current accent color
	@objc public private(set) var accentColor: NSColor = DSFAppearanceManager.AccentColor

	/// Returns the user's current highlight color
	@objc public private(set) var highlightColor: NSColor = DSFAppearanceManager.HighlightColor

	/// Returns the current aqua variant. (graphite or aqua style on older macOS)
	@objc public private(set) var aquaVariant: DSFAppearanceManager.AppleAquaColorVariant = DSFAppearanceManager.AquaVariant

	/// Get the current accessibility display option for differentiate without color. If this is true, UI should not convey information using color alone and instead should use shapes or glyphs to convey information.
	@objc public private(set) var differentiateWithoutColor: Bool = DSFAppearanceManager.DifferentiateWithoutColor

	/// Get the current accessibility display option for invert colors. If this property's value is true then the display will be inverted. In these cases it may be needed for UI drawing to be adjusted to in order to display optimally when inverted.
	@objc public private(set) var invertColors: Bool = DSFAppearanceManager.InvertColors

	/// Get the current accessibility display option for autoplay animated images
	@objc public private(set) var autoplayAnimatedImages: Bool = DSFAppearanceManager.AutoplayAnimatedImages

	/// Is the user using the hardware color as the accent color?
	@objc public private(set) var isUsingSimulatedHardwareColor: Bool = DSFAppearanceManager.IsUsingSimulatedHardwareColor

	/// The simulated hardware color for this machine
	@objc public private(set) var simulatedHardwareColor: NSColor? = DSFAppearanceManager.SimulatedHardwareColor

	/// Create an appearance cache
	@objc override public init() {
		super.init()
		self.changeHandler.appearanceChangeCallback = { [weak self] _ in
			self?.sync()
		}
	}

	/// Register a listener
	@objc public func register(_ obj: DSFAppearanceCacheNotifiable) {
		self.listeners.add(obj)
	}

	/// Deregister a listener
	@objc public func deregister(_ obj: DSFAppearanceCacheNotifiable) {
		self.listeners.remove(obj)
	}

	// Registered listeners.
	private lazy var listeners: WeakBag<DSFAppearanceCacheNotifiable> = {
		return WeakBag<DSFAppearanceCacheNotifiable>()
	}()

	// The change handler
	private let changeHandler = DSFAppearanceManager.ChangeDetector()

	private func sync() {
		// Note that this function is guaranteed to be called on the main thread
		self.isDark = DSFAppearanceManager.IsDark
		self.isDarkMenu = DSFAppearanceManager.IsDarkMenu
		self.accentColor = DSFAppearanceManager.AccentColor
		self.highlightColor = DSFAppearanceManager.HighlightColor
		self.aquaVariant = DSFAppearanceManager.AquaVariant
		self.increaseContrast = DSFAppearanceManager.IncreaseContrast
		self.differentiateWithoutColor = DSFAppearanceManager.DifferentiateWithoutColor
		self.reduceTransparency = DSFAppearanceManager.ReduceTransparency
		self.reduceMotion = DSFAppearanceManager.ReduceMotion
		self.invertColors = DSFAppearanceManager.InvertColors
		self.autoplayAnimatedImages = DSFAppearanceManager.AutoplayAnimatedImages
		self.isUsingSimulatedHardwareColor = DSFAppearanceManager.IsUsingSimulatedHardwareColor
		self.simulatedHardwareColor = DSFAppearanceManager.SimulatedHardwareColor

		self.listeners.validElements.forEach { listener in
			listener.appearanceDidChange()
		}

		// Post a notification if you're not interested in registering against the 
		NotificationCenter.default.post(name: Self.ChangeNotificationName, object: self, userInfo: nil)
	}
}

#endif
