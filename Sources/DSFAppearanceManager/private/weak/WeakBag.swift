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

import Foundation

/// An unordered 'bag' of weak elements
///
/// By default, the bag is not protected against changes from different threads.
/// You can optionally specify a Lockable which will be used to make the bag thread-safe.
class WeakBag<Element: AnyObject> {
	// Returns the count of the valid elements in the bag
	@inlinable var validCount: Int {
		self.validElements.count
	}

	// Returns the valid elements in the bag
	@inlinable var validElements: [Element] {
		self._lockable.whileLocked {
			return self._elements.compactMap { $0.wrapped }
		}
	}

	// Add an element to the bag
	@inlinable func add(_ item: Element) {
		self._lockable.whileLocked {
			// Cleanup first - remove any invalid objects
			self._elements.removeAll { $0.invalid }
			self._elements.append(WeakBox(item))
		}
	}

	// Remove an element from the bag
	@inlinable func remove(_ item: Element) {
		self._lockable.whileLocked {
			self._elements.removeAll { $0.wrapped === item || $0.invalid }
		}
	}

	// Remove all the objects from the bag
	@inlinable func removeAll() {
		self._lockable.whileLocked {
			self._elements.removeAll()
		}
	}

	// Remove any weakly held bag elements that have gone away
	@inlinable func compact() {
		self._lockable.whileLocked {
			self._elements.removeAll { $0.invalid }
		}
	}

	deinit {
		self.removeAll()
	}

	private let _lockable = DSFSimpleLock()
	private var _elements: [WeakBox<Element>] = []
}
