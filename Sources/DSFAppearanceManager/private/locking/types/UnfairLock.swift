//
//  UnfairLock.swift
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

/// A basic wrapper around `os_unfair_lock` (a non-FIFO, high performance lock that offers safety against priority inversion).
///
/// See: [https://developer.apple.com/documentation/os/1646466-os_unfair_lock_lock](https://developer.apple.com/documentation/os/1646466-os_unfair_lock_lock)
///
/// A lock must be unlocked only from the same thread in which it was locked. Attempting to unlock from a different
/// thread causes a runtime error.
///
/// A lock must not be accessed from multiple processes or threads via shared or multiply-mapped memory, because the
/// lock implementation relies on the address of the lock value and owning process.
@available(macOS 10.12, iOS 10, tvOS 10, *)
class UnfairLock: Lockable {
	init() {
		self._underlyingLock.initialize(to: os_unfair_lock())
	}

	deinit {
		self._underlyingLock.deinitialize(count: 1)
		self._underlyingLock.deallocate()
	}

	/// Obtain the lock and perform the block
	@inlinable func whileLocked<ReturnValueType>(_ contentBlock: () throws -> ReturnValueType) rethrows -> ReturnValueType {
		self.unbalancedLock()
		defer { self.unbalancedUnlock() }
		return try contentBlock()
	}

	/// Try to obtain the lock, and if successful perform the contentBlock and return true.
	/// If the lock is unavailable, return false
	@discardableResult @inlinable func performIfLockable(_ contentBlock: () throws -> Void) rethrows -> Bool {
		if self.unbalancedTryLock() {
			defer { self.unbalancedUnlock() }
			try contentBlock()
			return true
		}
		return false
	}

	// Private
	private let _underlyingLock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
}

@available(macOS 10.12, iOS 10, tvOS 10, *)
extension UnfairLock {
	/// Lock the lock
	@inlinable @inline(__always) func unbalancedLock() {
		os_unfair_lock_lock(self._underlyingLock)
	}

	/// Returns true if the lock was succesfully locked and false if the lock was already locked.
	@inlinable @inline(__always) func unbalancedTryLock() -> Bool {
		return os_unfair_lock_trylock(self._underlyingLock)
	}

	/// Unlock the lock
	@inlinable @inline(__always) func unbalancedUnlock() {
		os_unfair_lock_unlock(self._underlyingLock)
	}
}
