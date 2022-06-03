//
//  WeakBox.swift
//
//  Created by Darren Ford on 28/2/20.
//  Copyright © 2022 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

// A simple weak object wrapper

import Foundation

// A wrapper object for a weakly-held object
class WeakBox<Element> where Element: AnyObject {

	/// The wrapped element
	private(set) weak var wrapped: Element?

	/// Create a boxed element
	init(_ value: Element) { wrapped = value }

	/// Is the wrapped object still available?
	@inlinable var valid: Bool { wrapped != nil }

	/// Has the wrapped object gone away?
	@inlinable var invalid: Bool { wrapped == nil }

	/// Returns this object if the wrapped object is not nil, otherwise nil
	@inlinable var item: WeakBox<Element>? { valid ? self : nil }
}
