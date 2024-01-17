//
//  AutoplayAnimatedImages.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
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

#if os(macOS)

import Foundation
import Accessibility

#if swift(>=5.9)

// AXAnimatedImagesEnabled is only available in macOS 14

@inlinable internal func ShouldAutoplayAnimatedImages() -> Bool {
	if #available(macOS 14.0, *) {
		return AXAnimatedImagesEnabled()
	} else {
		return !DSFAppearanceManager.ReduceMotion
	}
}

#else

internal extension NSNotification.Name {
	static let AXAnimatedImagesEnabledDidChange = NSNotification.Name("AXAnimatedImagesEnabledDidChange")
}

func ShouldAutoplayAnimatedImages() -> Bool { !DSFAppearanceManager.ReduceMotion }

#endif

#endif
