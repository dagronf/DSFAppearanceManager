//
//  PThreadLock.swift
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

/// A non-reentrant pthread-based lock
class PThreadLock: Lockable {
	init(isReentrant: Bool = false) {
		let mutexAttributes: UnsafeMutablePointer<pthread_mutexattr_t> = UnsafeMutablePointer.allocate(capacity: 1)
		defer {
			pthread_mutexattr_destroy(mutexAttributes)
			mutexAttributes.deallocate()
		}

		var err = pthread_mutexattr_init(mutexAttributes)
		precondition(err == 0, "pthread_mutexattr_init failed with error '\(err)'")
		err = pthread_mutexattr_settype(mutexAttributes, isReentrant ? PTHREAD_MUTEX_RECURSIVE : PTHREAD_MUTEX_DEFAULT)
		precondition(err == 0, "pthread_mutexattr_settype failed with error '\(err)'")
		err = pthread_mutex_init(self._mutex, mutexAttributes)
		precondition(err == 0, "pthread_mutex_init failed with error '\(err)'")
	}

	deinit {
		let err = pthread_mutex_destroy(self._mutex)
		precondition(err == 0, "pthread_mutex_destroy failed with error \(err)")
		self._mutex.deallocate()
	}

	/// Lock, then perform the specified block
	func whileLocked<ReturnValueType>(_ contentBlock: () throws -> ReturnValueType) rethrows -> ReturnValueType {
		let err = pthread_mutex_lock(self._mutex)
		precondition(err == 0, "pthread_mutex_lock: Unable to lock (\(err))")
		defer { pthread_mutex_unlock(self._mutex) }
		return try contentBlock()
	}

	/// Performs the specified block If the lock can be aquired
	func performIfLockable(_ contentBlock: () throws -> Void) rethrows -> Bool {
		if pthread_mutex_trylock(self._mutex) == 0 {
			defer { pthread_mutex_unlock(self._mutex) }
			try contentBlock()
			return true
		}
		return false
	}

	// private
	private let _mutex: UnsafeMutablePointer<pthread_mutex_t> = UnsafeMutablePointer.allocate(capacity: 1)
}
