//
//  LockedResource.swift
//
//  Copyright © 2022 Darren Ford. All rights reserved.
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

/// A value wrapped by a readers/writers lock
class LockedResource<ResourceType> {
	/// Create a locked resource with an initial value
	init(initialValue: ResourceType) {
		self._value = initialValue
	}

	/// Block the calling of value() with a class type.
	@inlinable func value() -> ResourceType where ResourceType: AnyObject {
		fatalError("calling value() for a class-type resource is inherently unsafe. Use whileReading() instead")
	}

	/// Returns the current value of the resource
	@inlinable func value() -> ResourceType {
		self._rwlock.whileReading { self._value }
	}

	/// Replace the resource with a new value.
	/// - Parameter newValue: The new value
	/// - Returns: The old value
	func setValue(_ newValue: ResourceType) -> ResourceType {
		return self._rwlock.whileWriting {
			let oldValue = self._value
			self._value = newValue
			return oldValue
		}
	}

	/// Lock the resource for reading only, then perform the block
	/// - Parameter accessBlock: The block to call, passing the current value
	/// - Returns: The result of the access block
	func whileReading<ResultType>(_ accessBlock: (ResourceType) throws -> ResultType) rethrows -> ResultType {
		return try self._rwlock.whileReading {
			return try accessBlock(self._value)
		}
	}

	/// Lock the resource for writing, then perform the block to retrieve the new value of the resource
	/// - Parameter updateBlock: The block to call, passing the existing value as an inout parameter
	/// - Returns: The old value
	func whileWriting(_ updateBlock: (inout ResourceType) throws -> Void) rethrows -> ResourceType {
		return try self._rwlock.whileWriting {
			let oldValue = self._value
			try updateBlock(&self._value)
			return oldValue
		}
	}

	// private

	private var _value: ResourceType
	private let _rwlock = ReadersWriterLock()
}
