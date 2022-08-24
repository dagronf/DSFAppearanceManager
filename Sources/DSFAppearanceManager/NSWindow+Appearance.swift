//
//  NSView+Appearance.swift
//
//  Copyright © 2022 Darren Ford. All rights reserved.
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

#if os(macOS)

import AppKit

public extension NSWindow {
	/// Is the window displaying in dark mode?
	@objc var isDarkMode: Bool {
		return self.effectiveAppearance.isDarkMode
	}

	/// Perform the supplied block using the effective appearance of the window
	@objc func usingEffectiveAppearance(_ block: () -> Void) {
		self.effectiveAppearance.usingAsDrawingAppearance {
			block()
		}
	}
}

/// Perform the supplied block using the effective appearance of the window, or the application if the window is nil
public func UsingEffectiveAppearance(
	ofWindow window: NSWindow? = nil,
	perform block: () -> Void
) {
	let saved = NSAppearance.current
	defer { NSAppearance.current = saved }
	if #available(macOS 10.14, *) {
		// Adopt the color of the window we're attached tom or if the window is nil the application appearance
		let appearance = window?.effectiveAppearance ?? NSApplication.shared.effectiveAppearance
		appearance.usingAsDrawingAppearance {
			block()
		}
	}
	block()
}


#endif
