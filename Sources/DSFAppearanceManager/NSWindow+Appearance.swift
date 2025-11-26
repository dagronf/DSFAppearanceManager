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
	else {
		block()
	}
}

// MARK: - window appearance toggle

extension NSWindow {
	/// Add a popup button to the title of this window to allow changing the appearance.
	public func addDarkModeToggleAccessory() {
		guard #available(macOS 10.14, *) else { return }
		let vc = NSTitlebarAccessoryViewController()
		vc.layoutAttribute = .right

		let b = NSPopUpButton(frame: .init(x: 0, y: 0, width: 60, height: 30)) // .zero)
		b.translatesAutoresizingMaskIntoConstraints = false

		b.controlSize = .mini
		b.isBordered = false
		b.alignment = .right
		b.addItem(withTitle: "light")
		b.item(at: 0)?.target = self
		b.item(at: 0)?.action = #selector(setLightMode)
		b.item(at: 0)?.attributedTitle = NSAttributedString(string: "light", attributes: [.font: NSFont.menuFont(ofSize: 10)])
		b.addItem(withTitle: "dark")
		b.item(at: 1)?.target = self
		b.item(at: 1)?.action = #selector(setDarkMode)
		b.item(at: 1)?.attributedTitle = NSAttributedString(string: "dark", attributes: [.font: NSFont.menuFont(ofSize: 10)])
		b.addItem(withTitle: "system")
		b.item(at: 2)?.target = self
		b.item(at: 2)?.action = #selector(setSystemDarkMode)
		b.item(at: 2)?.attributedTitle = NSAttributedString(string: "system", attributes: [.font: NSFont.menuFont(ofSize: 10)])

		if self.appearance == nil {
			b.selectItem(at: 2)
		}
		else {
			let dark = self.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
			b.selectItem(at: dark ? 1 : 0)
		}

		vc.view = b
		self.addTitlebarAccessoryViewController(vc)
	}

	@available(macOS 10.14, *)
	@objc private func setDarkMode() {
		self.appearance = NSAppearance(named: .darkAqua)
	}

	@available(macOS 10.14, *)
	@objc private func setLightMode() {
		self.appearance = NSAppearance(named: .aqua)
	}

	@available(macOS 10.14, *)
	@objc private func setSystemDarkMode() {
		self.appearance = nil
	}

	@available(macOS 10.14, *)
	@objc private func toggleDarkMode(_ sender: NSButton) {
		if sender.state == .on {
			self.appearance = NSAppearance(named: .darkAqua)
			sender.title = "🌑"
		}
		else if sender.state == .mixed {
			self.appearance = nil
			sender.title = "🌓"
		}
		else {
			self.appearance = NSAppearance(named: .aqua)
			sender.title = "🌕"
		}
	}
}

#endif
