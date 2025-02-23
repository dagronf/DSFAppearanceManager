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
	///
	/// You can also set these in Xcode via launch arguments for the scheme
	@objc public static var SimulatedHardwareColor: NSColor? {
		// This logic works because if the key isn't found it returns 0, which isn't in the dictionary
		let hardwareType = UserDefaults.standard.integer(forKey: "NSColorSimulatedHardwareEnclosureNumber")
		return hardwareColorMap__[hardwareType]
	}
}

// Built-in hardware color (approximation)
private let hardwareColorMap__: [Int: NSColor] = [
	3: #colorLiteral(red: 0.954, green: 0.690, blue: 0.213, alpha: 1.000), 4: #colorLiteral(red: 0.219, green: 0.481, blue: 0.502, alpha: 1.000), 5: #colorLiteral(red: 0.181, green: 0.402, blue: 0.599, alpha: 1.000), 6: #colorLiteral(red: 0.825, green: 0.223, blue: 0.227, alpha: 1.000), 7: #colorLiteral(red: 0.335, green: 0.309, blue: 0.623, alpha: 1.000), 8: #colorLiteral(red: 0.957, green: 0.394, blue: 0.123, alpha: 1.000)
]

#endif
