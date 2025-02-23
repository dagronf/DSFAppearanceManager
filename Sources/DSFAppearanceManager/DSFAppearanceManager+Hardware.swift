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

// Routines for handling hardware-specific color settings (iMac 2021-)

#if os(macOS)

import AppKit

@objc extension DSFAppearanceManager {
	/// Is the user using the hardware color as the accent color?
	///
	/// For iMac M1 (2021) with color variants, is the user using the hardware color variant for the accent color?
	@objc public static var IsUsingSimulatedHardwareColor: Bool {
		UserDefaults.standard.bool(forKey: "NSColorSimulateHardwareAccent")
	}

	/// Return the current hardware's simulated color
	/// - Returns: NSColor, or `nil` if no simulated hardware color was found
	///
	/// This function determines the current Mac Accent Color using the system-defined UserDefaults values.
	///
	/// You can enable this on any Mac using the following Terminal commands:
	///
	/// * `defaults write -g NSColorSimulateHardwareAccent -bool YES`
	/// * `defaults write -g NSColorSimulatedHardwareEnclosureNumber -int 3`
	@objc public static var SimulatedHardwareColor: NSColor? {
		guard
			let n = UserDefaults.standard.string(forKey: "NSColorSimulatedHardwareEnclosureNumber"),
			let type = Int(n)
		else {
			return nil
		}

		switch type {
		case 3:
			return NSColor.systemYellow
		case 4:
			return NSColor.systemGreen
		case 5:
			return NSColor.systemBlue
		case 6:
			return NSColor.systemPink
		case 7:
			return NSColor.systemPurple
		case 8:
			return NSColor.systemOrange
		default:
			return nil
		}
	}
}

#endif
