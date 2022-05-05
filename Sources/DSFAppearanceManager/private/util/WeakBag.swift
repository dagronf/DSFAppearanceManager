//
//  WeakBag.swift
//
//  Created by Darren Ford on 21/2/2022.
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

import Foundation

/// A thread-safe unordered collection of weak elements. An item can be added multiple times
class WeakBag<Element: AnyObject> {
	/// Returns an array containing the current elements in the bag
	var items: [Element] {
		self._lock.whileLocked {
			self._items.compact()
			return self._items.allObjects.compactMap { $0 as? Element }
		}
	}

	/// Add an item to the bag
	func add(_ object: Element) {
		self._lock.whileLocked {
			self._items.compact()
			let pointer = Unmanaged.passUnretained(object).toOpaque()
			self._items.addPointer(pointer)
		}
	}

	/// Remove an item from the bag
	func remove(_ object: Element) {
		self._lock.whileLocked {
			// Remove nil objects
			self._items.compact()

			self._items.allObjects
				.compactMap { $0 as? Element } // All elements
				.enumerated() // All indexed elements [ (index, element) ]
				.filter { object === $0.1 } // Filter for the matching elements
				.map { $0.0 } // Indexes of matching items
				.sorted(by: >) // Sort indexes in descending order
				.forEach {
					// And for each index in descending order, remove it from the
					// pointer array to preserve indexing as we remove
					self._items.removePointer(at: $0)
				}
		}
	}

	/// Remove all the items from the bag
	@inlinable func removeAll() {
		self._lock.whileLocked {
			self._items = NSPointerArray.weakObjects()
		}
	}

	deinit {
		// Not required, just for cleanliness
		self.removeAll()
	}

	// Private
	private let _lock = NSLock()
	private var _items = NSPointerArray.weakObjects()
}
