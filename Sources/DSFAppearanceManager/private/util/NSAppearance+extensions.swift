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

#if os(macOS)

import AppKit

internal extension NSAppearance {
	/// Is the appearance dark aqua?
	@inlinable var isDarkMode: Bool {
		if #available(macOS 10.14, *), self.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
			return true
		}
		return false
	}

	/// Sets the appearance to be the active drawing appearance and perform the specified block.
	@inlinable func usingAsDrawingAppearance(perform block: () -> Void) {
		if #available(macOS 11.0, *) {
			self.performAsCurrentDrawingAppearance {
				block()
			}
		}
		else {
			let saved = NSAppearance.current
			defer { NSAppearance.current = saved }
			NSAppearance.current = self
			block()
		}
	}
}

#endif
