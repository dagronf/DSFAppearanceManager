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

#if os(macOS)

import AppKit

/// A macOS system-appearance wrapper class.
///
/// This class wraps the complexities of accessing the user's current appearance settings,
/// across all supported macOS platforms.
///
/// Example usage :-
///
/// ```swift
/// // Get the current highlight color
/// let color = DSFAppearanceManager.HighlightColor
/// // Get the user's current 'reduce contrast' setting.
/// let isHighContrast = DSFAppearanceManager.IncreaseContrast
/// ```
///
/// Change detection usage (Swift) :-
///
/// ```swift
/// let appearanceChangeDetector = DSFAppearanceManager.ChangeDetector()
/// ...
/// appearanceChangeDetector.appearanceChangeCallback = { [weak self] change in
///   let currentHighlightColor = DSFAppearanceManager.HighlightColor
///   self?.redrawComponent()
///   ...
/// }
///
@objc public final class DSFAppearanceManager: NSObject {
	/// The notification sent when a change occurs in the theme.
	///
	/// The userInfo contains the change type(s) as an via the key DSFAppearanceManager.AppearanceChangedNotification,
	/// as a `DSFAppearanceManager.Changes` object
	internal static let AppearanceChangedNotification = NSNotification.Name("DSFAppearanceManager.AppearanceChangedNotification")

	/// Key for the notification containing the type(s) of changes that occured.
	internal static let AppearanceManagerChange = "DSFAppearanceManagerChange"

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

		/// Returns the string representation of the value
		public var name: String {
			switch self {
			case .theme: return "theme"
			case .accent: return "accent"
			case .aquaVariant: return "aquaVariant"
			case .systemColors: return "systemColors"
			case .finderLabelColorsChanged: return "finderLabelColorsChanged"
			case .accessibility: return "accessibility"
			}
		}
	}

	/// The aqua variant for older macOS versions
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

	/// Returns a string description of the current appearance settings
	@objc public static var Description: String {
		"""
		Current Theme:
		   isDark: \(Self.IsDark)
		   isDarkMenu: \(Self.IsDarkMenu)
		   accentColor: \(Self.AccentColor)
		   highlightColor: \(Self.HighlightColor)
		   aquaVariant: \(Self.AquaVariant.stringValue)
		   increaseContrast: \(Self.IncreaseContrast)
		   differentiateWithoutColor: \(Self.DifferentiateWithoutColor)
		   reduceTransparency: \(Self.ReduceTransparency)
		   invertColors: \(Self.InvertColors)
		   reduceMotion: \(Self.ReduceMotion)
		"""
	}

	// Private

	override internal init() {
		self.notificationCenter = NotificationCenter.default
		super.init()
		self.installNotificationListeners()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
		self.distributedNotificationCenter.removeObserver(self)
	}

	// A shared appearance manager
	@objc public static let shared = DSFAppearanceManager()

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

private extension DSFAppearanceManager {
	/// Map an integer value to a system color
	static func ColorForInt(_ value: Int) -> NSColor {
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
		if #available(macOS 11.0, *) {
			return NSColor.systemGray
		}
		else {
			return NSColor.systemBlue
		}
	}
}

// MARK: - Static theme values

@objc public extension DSFAppearanceManager {
	/// Is the user interface being displayed as dark (Mojave and later)
	static var IsDark: Bool {
		if #available(OSX 10.14, *) {
			// Fall back to the default NSApp.effectiveAppearance setting.
			// Note that this might not always be accurate as the app may have explicitly set the effective appearance.
			return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
//			// The UserDefaults doesn't always seem to be set when the appearance changes. For example, setting the
//			// mode via the Shortcuts app doesn't set it, but via System Preferences does. Don't know why.
//			if let style = UserDefaults.standard.string(forKey: DSFAppearanceManager.kInterfaceStyle) {
//				return style.lowercased().contains("dark")
//			}
		}
		return false
	}

	/// Are the menu bars and dock being displayed as dark (Yosemite and later)
	static var IsDarkMenu: Bool {
		if let style = UserDefaults.standard.string(forKey: DSFAppearanceManager.kInterfaceStyle) {
			return style.lowercased().contains("dark")
		}
		return Self.IsDark
	}

	/// Returns the user's current accent color
	static var AccentColor: NSColor {
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
	static var HighlightColor: NSColor {
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
	static var AquaVariant: AppleAquaColorVariant {
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
	/// This feature is available from macOS 10.10. For systems prior to 10.10, this property always returns false.
	///
	/// See: [`NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast`](https://developer.apple.com/documentation/appkit/nsworkspace/1526290-accessibilitydisplayshouldincrea).
	static var IncreaseContrast: Bool {
		if #available(macOS 10.10, *) {
			return NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
		}
		return false
	}

	/// Get the current accessibility display option for differentiate without color. If this is true, UI should not convey information using color alone and instead should use shapes or glyphs to convey information.
	///
	/// This feature is available from macOS 10.10. For systems prior to 10.10, this property always returns false.
	///
	/// See: [`NSWorkspace.shared.accessibilityDisplayShouldDifferentiateWithoutColor`](https://developer.apple.com/documentation/appkit/nsworkspace/1524656-accessibilitydisplayshoulddiffer).
	static var DifferentiateWithoutColor: Bool {
		if #available(macOS 10.10, *) {
			return NSWorkspace.shared.accessibilityDisplayShouldDifferentiateWithoutColor
		}
		return false
	}

	/// Get the current accessibility display option for reduce transparency. If this property's value is true, UI (mainly window) backgrounds should not be semi-transparent; they should be opaque.
	///
	/// This feature is available from macOS 10.10. For systems prior to 10.10, this property always returns false.
	///
	/// See: [`NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency`](https://developer.apple.com/documentation/appkit/nsworkspace/1533006-accessibilitydisplayshouldreduce)
	static var ReduceTransparency: Bool {
		if #available(macOS 10.10, *) {
			return NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
		}
		else {
			return false
		}
	}

	/// Get the current accessibility display option for invert colors. If this property's value is true then the display will be inverted. In these cases it may be needed for UI drawing to be adjusted to in order to display optimally when inverted.
	///
	/// This feature is available from macOS 10.12. For systems prior to 10.12, this property always returns false.
	///
	/// See: [`NSWorkspace.shared.accessibilityDisplayShouldInvertColors`](https://developer.apple.com/documentation/appkit/nsworkspace/1644068-accessibilitydisplayshouldinvert)
	static var InvertColors: Bool {
		if #available(macOS 10.12, *) {
			return NSWorkspace.shared.accessibilityDisplayShouldInvertColors
		}
		return false
	}

	/// Get the current accessibility display option for reduce motion. If this property's value is true, UI should avoid large animations, especially those that simulate the third dimension.
	///
	/// This feature is available from macOS 10.12. For systems prior to 10.12, this property always returns false.
	///
	/// See: [`NSWorkspace.shared.accessibilityDisplayShouldReduceMotion`](https://developer.apple.com/documentation/appkit/nsworkspace/1644069-accessibilitydisplayshouldreduce).
	static var ReduceMotion: Bool {
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
