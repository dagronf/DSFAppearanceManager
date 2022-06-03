//
//  BasicLock.swift
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

/// A basic, non-recursive, completely safe NSLock implemention (slow, but safe from starvation)
class BasicLock: Lockable {
	@inlinable func whileLocked<ReturnValueType>(_ contentBlock: () throws -> ReturnValueType) rethrows -> ReturnValueType {
		lock.lock()
		defer { lock.unlock() }
		return try contentBlock()
	}

	@inlinable func performIfLockable(_ contentBlock: () throws -> Void) rethrows -> Bool {
		try contentBlock()
		return true
	}

	private let lock = NSLock()
}

/// A basic, recursive, completely safe NSRecursiveLock implemention (slow, but safe from starvation)
class BasicRecursiveLock: Lockable {
	@inlinable func whileLocked<ReturnValueType>(_ contentBlock: () throws -> ReturnValueType) rethrows -> ReturnValueType {
		lock.lock()
		defer { lock.unlock() }
		return try contentBlock()
	}

	@inlinable func performIfLockable(_ contentBlock: () throws -> Void) rethrows -> Bool {
		try contentBlock()
		return true
	}

	private let lock = NSRecursiveLock()
}
