//
//  ReadersWriterLock.swift
//
//  Created by Darren Ford on 18/4/2022.
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

/// A readers/writer lock object.
///
/// This lock allows multiple simultaneous readers, but only a single writer.
///
/// Be careful with class type `ValueType`s bleeding outside the access blocks (mostly, its bad)
///
/// **Q: Why not a concurrent DispatchQueue and use `.barrier` for the writes?**
///
/// Calling 'queue.sync {}' on a concurrent DispatchQueue creates a new thread (well, it
/// allocates one from the processes thread pool) in order to perform the locked block.
/// And given that a process has a limited number of threads it can access, if there's a high
/// number of concurrent accesses a queue can deadlock.
///
/// I didn't want to have thread(s) used for each and every rw lock object access, so I fell down to a lower level
/// and used pthread rwlock objects instead.
///
/// Note that for ValueType == class types:
/// This class only restricts access to the _value_. If `ValueType` is a class, once you have access
/// to the value (the class object) you can modify its _members_ as much as you want.
/// The user is responsible for verifying that class type member access is read-only as well.
///
public class ReadersWriterLock<ValueType> {
	/// Create an empty ReadersWriterLock object.
	///
	/// Calling `whileReading` or `whileModifying` before calling `setValue` will result in an assertion failure
	public init() {
		pthread_rwlock_init(&_rwlock, nil)
	}

	/// Create a ReadersWriterLock object
	/// - Parameters:
	///   - value: The initial value stored in the object
	///   - changeBlock: The block to call when `value` changes, or nil for no callback
	public init(
		_ value: ValueType,
		_ changeBlock: ((ValueType) -> Void)? = nil
	) {
		pthread_rwlock_init(&_rwlock, nil)
		self._value = value
		self.valueDidChange = changeBlock
	}

	/// An optional block to call when the value changes, passing the current wrapped value.
	///
	/// The value passed _may_ be different than the value that was originally set IF another thread has modified
	/// the value inbetween the locking mutate and the call to the block (which is valid!)
	///
	/// Called using a 'read' lock
	public var valueDidChange: ((ValueType) -> Void)?

	/// Set a new value
	/// - Parameter newValue: The new value
	@inlinable public func setValue(_ newValue: ValueType) {
		self.whileModifying { existingValue in
			existingValue = newValue
		}
	}

	/// A method for safely accessing the resource within a scoped block.
	/// - Parameter accessBlock: The block to call using a read lock.
	///
	/// You should keep the functionality defined in `accessBlock` to a minimum in order to reduce lock times.
		public func whileReading<ResultType>(_ accessBlock: (ValueType) throws -> ResultType) rethrows -> ResultType {
		assert(_value != nil, "ERROR: Resource is empty. You must call 'setResource()' before use if it has not set during initialization")
		// Lock as a reader only
		pthread_rwlock_rdlock(&_rwlock)
		defer { pthread_rwlock_unlock(&_rwlock) }
		return try accessBlock(_value)
	}

	/// A method for safely modifying the resource within a scoped block.
	/// - Parameter modifyBlock: The block to call while using the write lock.
	///
	/// You should keep the functionality defined in `modifyBlock` to a minimum in order to reduce lock times
	public func whileModifying(_ modifyBlock: (inout ValueType) throws -> Void) rethrows {
		assert(_value != nil, "ERROR: Resource is empty. You must call 'setResource()' before use if it has not set during initialization")
		do {
			// Lock the writer...
			pthread_rwlock_wrlock(&_rwlock)
			defer { pthread_rwlock_unlock(&_rwlock) }

			// ... and call modifyBlock to perform the update
			try modifyBlock(&_value)
		}

		// If a change block has been specified, call it outside of the writer lock scope
		if let cb = valueDidChange {
			self.whileReading { currentValue in
				cb(currentValue)
			}
		}
	}

	deinit {
		pthread_rwlock_destroy(&_rwlock)
	}

	private var _value: ValueType!
	private var _rwlock = pthread_rwlock_t()
}
