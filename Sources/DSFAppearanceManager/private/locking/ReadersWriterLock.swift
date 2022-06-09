//
//  ReadersWriterLock.swift
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
//  https://github.com/apple/swift-metrics/blob/main/Sources/CoreMetrics/Locks.swift
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
final class ReadersWriterLock {
	/// Create an empty ReadersWriterLock object.
	///
	/// Calling `whileReading` or `whileModifying` before calling `setValue` will result in an assertion failure
	init() {
		let err = pthread_rwlock_init(self._rwlock, nil)
		precondition(err == 0, "pthread_rwlock_init: failed with error \(err)")
	}

	deinit {
		let err = pthread_rwlock_destroy(self._rwlock)
		precondition(err == 0, "pthread_rwlock_destroy: failed with error \(err)")
		self._rwlock.deallocate()
	}

	/// A method for safely accessing the resource within a scoped block.
	/// - Parameter accessBlock: The block to call using a read lock.
	///
	/// You should keep the functionality defined in `accessBlock` to a minimum in order to reduce lock times.
	func whileReading<ResultType>(_ accessBlock: () throws -> ResultType) rethrows -> ResultType {
		pthread_rwlock_rdlock(_rwlock)
		defer { pthread_rwlock_unlock(_rwlock) }
		return try accessBlock()
	}

	/// A method for safely modifying the resource within a scoped block.
	/// - Parameter accessBlock: The block to call while using the write lock.
	///
	/// You should keep the functionality defined in `modifyBlock` to a minimum in order to reduce lock times
	func whileWriting<ResultType>(_ accessBlock: () throws -> ResultType) rethrows -> ResultType {
		pthread_rwlock_wrlock(_rwlock)
		defer { pthread_rwlock_unlock(_rwlock) }
		return try accessBlock()
	}

	private let _rwlock: UnsafeMutablePointer<pthread_rwlock_t> = UnsafeMutablePointer.allocate(capacity: 1)
}
