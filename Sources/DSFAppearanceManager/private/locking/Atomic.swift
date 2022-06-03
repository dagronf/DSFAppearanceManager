//
//  Atomic.swift
//
//  Atomic class from https://www.objc.io/blog/2018/12/18/atomic-variables/
//  Created by Darren Ford on 28/11/19.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import Foundation

/// Providing locked access to a resource
class Atomic<WrappedValue> {
	/// Create an Atomic object
	/// - Parameters:
	///   - resource: The resource to protect
	///   - lockable: The locking mechanism to use
	init(_ resource: WrappedValue, lockable: Lockable? = nil) {
		if #available(macOS 10.12, *) {
			self.lock = lockable ?? UnfairLock()
		} else {
			// Basic NSLock (slower)
			self.lock = lockable ?? BasicLock()
		}
		self._resource = resource
	}

	/// Set the resource to a new value, and returns the previous value
	@discardableResult @inlinable func swap(_ newValue: WrappedValue) -> WrappedValue {
		self.lock.whileLocked {
			let oldValue = self._resource
			self._resource = newValue
			return oldValue
		}
	}

	/// Modify the resource value via a locked block, returning the previous value
	@discardableResult @inlinable func modify(_ modifyBlock: (WrappedValue) throws -> WrappedValue) rethrows -> WrappedValue {
		return try self.lock.whileLocked {
			let oldValue = self._resource
			self._resource = try modifyBlock(self._resource)
			return oldValue
		}
	}

	/// Unlock the resource, and perform a block with the locked resource.
	@inlinable func unlocking<ReturnType>(_ accessBlock: (WrappedValue) throws -> ReturnType) rethrows -> ReturnType {
		return try self.lock.whileLocked {
			return try accessBlock(self._resource)
		}
	}

	private let lock: Lockable
	private var _resource: WrappedValue
}
