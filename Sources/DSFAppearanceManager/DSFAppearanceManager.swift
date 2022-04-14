//
//  DSFAppearanceManager.swift
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
//  With help from
//    https://chromium.googlesource.com/chromium/src/+/master/content/renderer/theme_helper_mac.mm
//    https://bugzilla.mozilla.org/show_bug.cgi?id=1062801
//
//  Simple Usage :-
//
//     _ = DSFAppearanceManager.shared.addObserver { notification in
//         Swift.print(...)
//     }
//

#if os(macOS)

import AppKit

/// Apple notifications for theme changes
internal extension NSNotification.Name {
	static let ThemeChangedNotification = NSNotification.Name("AppleInterfaceThemeChangedNotification")
	static let AccentChangedNotification = NSNotification.Name("AppleColorPreferencesChangedNotification")
	static let AquaVariantChangeNotification = NSNotification.Name("AppleAquaColorVariantChanged")
	static let SystemColorsChangeNotification = NSNotification.Name("NSSystemColorsDidChangeNotification")
}

@objc public final class DSFAppearanceManager: NSObject {
	/// A common shared appearance manager
	@objc public static let shared = DSFAppearanceManager()

	/// The notification sent when a change occurs in the theme.
	///
	/// The userInfo contains the change type(s) as an via the key DSFAppearanceManager.AppearanceChangedNotification,
	/// as a `DSFAppearanceManager.Changes` object
	@objc(DSFAppearanceManagerThemeChangedNotification)
	public static let AppearanceChangedNotification = NSNotification.Name("DSFAppearanceManager.AppearanceChangedNotification")

	/// Key for the notification containing the type(s) of changes that occured.
	@objc(DSFAppearanceManagerChange)
	public static let AppearanceManagerChange = "DSFAppearanceManagerChange"

	/// The type of a change that occurred
	@objc(DSFAppearanceManagerStyleChangeType)
	public enum StyleChangeType: Int {
		/// The system appearance changed (dark/light>
		case theme = 0
		/// Accent colors changed (eg. accent/highlight)
		case accent = 1
		/// For older macOS versions, the variant (blue, graphite)
		case aquaVariant = 2
		/// The user changed the system colors
		case systemColors = 3
		/// The Finder label colors change changed
		case finderLabelColorsChanged = 4
		/// Accessibility display settings changed
		case accessibility = 5
	}

	/// A class containing the current set of theme changes
	@objc(DSFAppearanceManagerChange)
	public class Change: NSObject {
		public private(set) var changes = Set<StyleChangeType>()

		@objc func add(change: StyleChangeType) {
			self.changes.insert(change)
		}

		@objc public var nsChanges: NSSet {
			return NSSet(set: self.changes)
		}
	}

	@objc(DSFAppearanceManagerAquaColorVariant)
	public enum AppleAquaColorVariant: Int {
		case blue = 1
		case graphite = 6
		public var stringValue: String {
			switch self {
			case .blue: return "blue"
			case .graphite: return "graphite"
			default: fatalError()
			}
		}
	}

	@objc(DSFAppearanceManagerSystemColor)
	public enum SystemColor: Int {
		case graphite = -1
		case red = 0
		case orange = 1
		case yellow = 2
		case green = 3
		case blue = 4
		case purple = 5
		case pink = 6
	}

	/// Return the NSColor object representing the system color
	@objc public static func Color(for systemColor: SystemColor) -> NSColor {
		return DSFAppearanceManager.ColorForInt(systemColor.rawValue)
	}

	/// Map an integer value to a system color
	private static func ColorForInt(_ value: Int) -> NSColor {
		switch value {
		case -1: return NSColor.systemGray
		case 0: return NSColor.systemRed
		case 1: return NSColor.systemOrange
		case 2: return NSColor.systemYellow
		case 3: return NSColor.systemGreen
		case 4: return NSColor.systemBlue
		case 5: return NSColor.systemPurple
		case 6: return NSColor.systemPink
		default: return self.DefaultColor
		}
	}

	// Default color (has changed in Big Sur)
	private static var DefaultColor: NSColor {
		if #available(OSX 11.0, *) {
			return NSColor.systemGray
		}
		else {
			return NSColor.systemBlue
		}
	}

	/// Is the UI currently being displayed as dark (Mojave upwards)
	@objc public private(set) var isDark: Bool = DSFAppearanceManager.IsDark

	/// Are the menu and doc currently being displayed as dark (Yosemite upwards)
	@objc public private(set) var isDarkMenu: Bool = DSFAppearanceManager.IsDarkMenu

	/// What is the current accent color?
	@objc public private(set) var accentColor: NSColor = DSFAppearanceManager.AccentColor

	/// What is the current highlight color?
	@objc public private(set) var highlightColor: NSColor = DSFAppearanceManager.HighlightColor

	/// What is the current aqua variant color?
	@objc public private(set) var aquaVariant: AppleAquaColorVariant = DSFAppearanceManager.AquaVariant

	/// Should the UI be drawn with increased contrast?
	@objc public private(set) var increaseContrast: Bool = DSFAppearanceManager.IncreaseContrast

	/// Should the UI be drawn differentiating without using color?
	@objc public private(set) var differentiateWithoutColor: Bool = DSFAppearanceManager.DifferentiateWithoutColor

	/// Should the UI be drawn with reduced transparency?
	@objc public private(set) var reduceTransparency: Bool = DSFAppearanceManager.ReduceTransparency

	/// Is the system currently configured to invert the display?
	@objc public private(set) var invertColors: Bool = DSFAppearanceManager.InvertColors

	/// Should we reduce motion within our UI?
	@objc public private(set) var reduceMotion: Bool = DSFAppearanceManager.ReduceMotion

	init(notificationCenter: NotificationCenter = NotificationCenter.default) {
		self.notificationCenter = notificationCenter
		super.init()
		self.installNotificationListeners()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
		self.distributedNotificationCenter.removeObserver(self)
	}

	override public var description: String {
		return
	"""
	Current Theme:
		isDark: \(self.isDark)
		isDarkMenu: \(self.isDarkMenu)
		accentColor: \(self.accentColor)
		highlightColor: \(self.highlightColor)
		aquaVariant: \(self.aquaVariant)
		increaseContrast: \(self.increaseContrast)
		differentiateWithoutColor: \(self.differentiateWithoutColor)
		reduceTransparency: \(self.reduceTransparency)
		invertColors: \(self.invertColors)
		reduceMotion: \(self.reduceMotion)
	"""
	}

	/// Force a reload of the theme cache
	@objc public func updateCache() {
		self.isDark = Self.IsDark
		self.isDarkMenu = Self.IsDarkMenu
		self.accentColor = Self.AccentColor
		self.highlightColor = Self.HighlightColor
		self.aquaVariant = Self.AquaVariant
		self.differentiateWithoutColor = Self.DifferentiateWithoutColor
		self.reduceMotion = Self.ReduceMotion
		self.reduceTransparency = Self.ReduceTransparency
		self.increaseContrast = Self.IncreaseContrast
		self.invertColors = Self.InvertColors
	}

	// Private

	// The distributed notification center to listen to for some of the notification types
	internal let distributedNotificationCenter = DistributedNotificationCenter.default()

	// The notification center to post updates on
	internal var notificationCenter: NotificationCenter

	internal let debouncer = DSFDebounce(seconds: 0.1)
	internal var queuedChanges = Change()

	fileprivate static let kInterfaceStyle = "AppleInterfaceStyle"
	fileprivate static let kHighlightStyle = "AppleHighlightColor"
	fileprivate static let kAccentColor = "AppleAccentColor"
	fileprivate static let kAquaVariantColor = "AppleAquaColorVariant"
}

// MARK: - Observers and Listeners

@objc public extension DSFAppearanceManager {
	/// Adds an entry to the notification center to call the provided selector with the notification.
	func addObserver(_ observer: Any, selector aSelector: Selector) {
		self.notificationCenter.addObserver(
			observer,
			selector: aSelector,
			name: DSFAppearanceManager.AppearanceChangedNotification,
			object: self
		)
	}

	/// Adds an entry to the notification center to receive notifications that passed to the provided block.
	func addObserver(queue: OperationQueue? = nil, using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
		return NotificationCenter.default.addObserver(
			forName: DSFAppearanceManager.AppearanceChangedNotification,
			object: self,
			queue: queue,
			using: block
		)
	}

	/// Removes all entries specifying an observer from the notification center's dispatch table
	func removeObserver(_ observer: NSObject) {
		self.notificationCenter.removeObserver(observer)
	}
}

// MARK: - Static theme values

@objc public extension DSFAppearanceManager {
	/// Is the user interface being displayed as dark (Mojave and later)
	@objc static var IsDark: Bool {
		if #available(OSX 10.14, *) {
			if let style = UserDefaults.standard.string(forKey: DSFAppearanceManager.kInterfaceStyle) {
				return style.lowercased().contains("dark")
			}
		}
		return false
	}

	/// Are the menu bars and dock being displayed as dark (Yosemite and later)
	@objc static var IsDarkMenu: Bool {
		if let style = UserDefaults.standard.string(forKey: DSFAppearanceManager.kInterfaceStyle) {
			return style.lowercased().contains("dark")
		}
		return false
	}

	/// Returns the user's current accent color
	@objc static var AccentColor: NSColor {
		if #available(OSX 10.14, *) {
			// macOS 10.14 and above have a dedicated static NSColor
			return NSColor.controlAccentColor
		}

		// Use standard user defaults for anything lower than 10.14
		let userDefaults = UserDefaults.standard
		guard userDefaults.object(forKey: kAccentColor) != nil else {
			//  Pre-11.0, defaults to blue
			//  Post-11.0, uses application-defined accent color if provided (SwiftUI only?), else blue
			return Self.DefaultColor
		}

		return ColorForInt(userDefaults.integer(forKey: kAccentColor))
	}

	/// Returns the user's current highlight color
	@objc static var HighlightColor: NSColor {
		let ud = UserDefaults.standard

		guard let setting = ud.string(forKey: DSFAppearanceManager.kHighlightStyle) else {
			return NSColor.systemGray
		}

		let c = setting.components(separatedBy: " ")
		guard let r = Float(c[0]), let g = Float(c[1]), let b = Float(c[2]) else {
			return NSColor.systemGray
		}

		return NSColor(calibratedRed: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
	}

	/// Returns the current aqua variant. (graphite or aqua style on older macOS)
	@objc static var AquaVariant: AppleAquaColorVariant {
		let userDefaults = UserDefaults.standard
		guard userDefaults.object(forKey: DSFAppearanceManager.kAquaVariantColor) != nil else {
			return AppleAquaColorVariant.blue
		}

		let colorDef = userDefaults.integer(forKey: DSFAppearanceManager.kAquaVariantColor)
		guard let variant = AppleAquaColorVariant(rawValue: colorDef) else {
			return AppleAquaColorVariant.blue
		}
		return variant
	}

	/// Get the current accessibility display option for high-contrast UI.  If this is true, UI should be presented with high contrast such as utilizing a less subtle color palette or bolder lines.
	///
	/// See: `NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast`.
	@objc static var IncreaseContrast: Bool {
		if #available(macOS 10.10, *) {
			return NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
		}
		return false
	}

	/// Get the current accessibility display option for differentiate without color. If this is true, UI should not convey information using color alone and instead should use shapes or glyphs to convey information.
	///
	/// See: `NSWorkspace.shared.accessibilityDisplayShouldDifferentiateWithoutColor`.
	@objc static var DifferentiateWithoutColor: Bool {
		if #available(macOS 10.10, *) {
			return NSWorkspace.shared.accessibilityDisplayShouldDifferentiateWithoutColor
		}
		return false
	}

	/// Get the current accessibility display option for reduce transparency. If this property's value is true, UI (mainly window) backgrounds should not be semi-transparent; they should be opaque.
	///
	/// See: `NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency`
	@objc static var ReduceTransparency: Bool {
		if #available(macOS 10.10, *) {
			return NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
		}
		else {
			return false
		}
	}

	/// Get the current accessibility display option for invert colors. If this property's value is true then the display will be inverted. In these cases it may be needed for UI drawing to be adjusted to in order to display optimally when inverted.
	///
	/// See: `NSWorkspace.shared.accessibilityDisplayShouldInvertColors`
	@objc static var InvertColors: Bool {
		if #available(macOS 10.12, *) {
			return NSWorkspace.shared.accessibilityDisplayShouldInvertColors
		}
		return false
	}

	/// Get the current accessibility display option for reduce motion. If this property's value is true, UI should avoid large animations, especially those that simulate the third dimension.
	///
	/// See: `NSWorkspace.shared.accessibilityDisplayShouldReduceMotion`.
	@objc static var ReduceMotion: Bool {
		if #available(macOS 10.12, *) {
			return NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
		}
		else {
			// Fallback on earlier versions
			return false
		}
	}
}


#endif
