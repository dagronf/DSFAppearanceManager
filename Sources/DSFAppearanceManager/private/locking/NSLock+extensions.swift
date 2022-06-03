//
//  NSLock+extensions.swift
//
//  Created by Darren Ford on 18/3/2022.
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

// NOTES:
//
//  NSLock is NOT a recursive (re-entrant) lock. Use NSRecursiveLock() to get a re-entrant lock

extension NSLock {
	/// A block based 'try' method
	@discardableResult
	@inlinable func tryBlock(_ block: () throws -> Void) rethrows -> Bool {
		if self.try() {
			defer { self.unlock() }
			try block()
			return true
		}
		return false
	}

	/// A block-based locking method.
	@discardableResult
	@inlinable func whileLocked<ValueType>(_ block: () throws -> ValueType) rethrows -> ValueType {
		self.lock()
		defer { self.unlock() }
		return try block()
	}
}

extension NSRecursiveLock {
	/// A block based 'try' method
	@discardableResult
	@inlinable func tryBlock(_ block: () throws -> Void) rethrows -> Bool {
		if self.try() {
			defer { self.unlock() }
			try block()
			return true
		}
		return false
	}

	/// A block-based locking method.
	@discardableResult
	@inlinable func whileLocked<ValueType>(_ block: () throws -> ValueType) rethrows -> ValueType {
		self.lock()
		defer { self.unlock() }
		return try block()
	}
}
