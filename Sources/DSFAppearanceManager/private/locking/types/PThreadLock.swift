//
//  PThreadLock.swift
//
//  Created by Darren Ford on 27/12/2021.
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

	enum LockError: Error {
		case UnableToLock(Int32)
	}

	@inlinable func whileLocked<ReturnValueType>(_ contentBlock: () throws -> ReturnValueType) rethrows -> ReturnValueType {
		let err = pthread_mutex_lock(&self._mutex)
		if err != 0 {
			fatalError("Unable to lock (\(err))")
		}
		defer { pthread_mutex_unlock(&self._mutex) }
		return try contentBlock()
	}

	@inlinable func performIfLockable(_ contentBlock: () throws -> Void) rethrows -> Bool {
		if pthread_mutex_trylock(&self._mutex) == 0 {
			defer { pthread_mutex_unlock(&self._mutex) }
			try contentBlock()
			return true
		}
		return false
	}

	init() {
		var attr = pthread_mutexattr_t()
		var err = pthread_mutexattr_init(&attr)
		guard err == 0 else { fatalError("pthread_mutexattr_init failed with error '\(err)'") }

		// Make sure that our thread is NOT reentrant
		err = pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_DEFAULT)
		guard err == 0 else { fatalError("pthread_mutexattr_settype failed with error '\(err)'") }

		err = pthread_mutex_init(&self._mutex, &attr)
		guard err == 0 else { fatalError("pthread_mutex_init failed with error '\(err)'") }
		pthread_mutexattr_destroy(&attr)
	}

	deinit {
		assert(pthread_mutex_trylock(&self._mutex) == 0 && pthread_mutex_unlock(&self._mutex) == 0, "deinitialization of a locked mutex results in undefined behavior!")
		pthread_mutex_destroy(&self._mutex)
	}

	// private

	private var _mutex: pthread_mutex_t = pthread_mutex_t()
}

/// A revursive (reentrant) pthread-based lock
class PThreadRecursiveLock: Lockable {

	enum LockError: Error {
		case UnableToLock(Int32)
	}

	@inlinable func whileLocked<ReturnValueType>(_ contentBlock: () throws -> ReturnValueType) rethrows -> ReturnValueType {
		let err = pthread_mutex_lock(&self._mutex)
		if err != 0 {
			fatalError("Unable to lock (\(err))")
		}
		defer { pthread_mutex_unlock(&self._mutex) }
		return try contentBlock()
	}

	@inlinable func performIfLockable(_ contentBlock: () throws -> Void) rethrows -> Bool {
		if pthread_mutex_trylock(&self._mutex) == 0 {
			defer { pthread_mutex_unlock(&self._mutex) }
			try contentBlock()
			return true
		}
		return false
	}

	init() {
		var attr = pthread_mutexattr_t()
		var err = pthread_mutexattr_init(&attr)
		guard err == 0 else { fatalError("pthread_mutexattr_init failed with error '\(err)'") }

		// Make sure we set recursive
		err = pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
		guard err == 0 else { fatalError("pthread_mutexattr_settype failed with error '\(err)'") }

		err = pthread_mutex_init(&self._mutex, &attr)
		guard err == 0 else { fatalError("pthread_mutex_init failed with error '\(err)'") }
		pthread_mutexattr_destroy(&attr)
	}

	deinit {
		assert(pthread_mutex_trylock(&self._mutex) == 0 && pthread_mutex_unlock(&self._mutex) == 0, "deinitialization of a locked mutex results in undefined behavior!")
		pthread_mutex_destroy(&self._mutex)
	}

	// private

	private var _mutex: pthread_mutex_t = pthread_mutex_t()
}


