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

// * AXAnimatedImagesEnabled/AXAnimatedImagesEnabledDidChange is available in macOS 14, but DEPRECATED (and
//   UNAVAILABLE) in macOS 15.
// * If we COMPILE with Xcode 16 beta, but TARGET macOS 14, we crash during runtime on macOS 14 when we access
//   either of these symbols.
//
// So, we have to put in a special case for this case (compile on Xcode 16 beta, but deploy for macOS 14).

func AutoplayAnimatedImagesNotificationName() -> Notification.Name? {
	if #available(macOS 15.0, *) {
		#if compiler(>=6)
		return AccessibilitySettings.animatedImagesEnabledDidChangeNotification
		#endif
	}
	else if #available(macOS 14.0, *) {
		#if compiler(<6)
		// This crashes during runtime if we compile using Xcode 16 (beta). 
		// Seems like the only way to work around it is to drop support for animate images for macOS 14 IF
		// compiling with Xcode 16 beta
		return NSNotification.Name.AXAnimatedImagesEnabledDidChange
		#endif
	}
	return nil
}

@inlinable internal func ShouldAutoplayAnimatedImages() -> Bool {
	if #available(macOS 15.0, *) {
		#if compiler(>=6)
		return AccessibilitySettings.animatedImagesEnabled
		#endif
	}
	else if #available(macOS 14.0, *) {
		#if compiler(<6)
		// This crashes during runtime if we compile using Xcode 16 (beta).
		// Seems like the only way to work around it is to drop support for animate images for macOS 14 IF
		// compiling with Xcode 16 beta
		return AXAnimatedImagesEnabled()
		#endif
	}
	return !DSFAppearanceManager.ReduceMotion
}

#else

internal extension NSNotification.Name {
	static let AXAnimatedImagesEnabledDidChange = NSNotification.Name("AXAnimatedImagesEnabledDidChange")
}

func ShouldAutoplayAnimatedImages() -> Bool { !DSFAppearanceManager.ReduceMotion }
func AutoplayAnimatedImagesNotificationName() -> Notification.Name? { NSNotification.Name.AXAnimatedImagesEnabledDidChange }

#endif

#endif
