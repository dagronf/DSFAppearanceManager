//
//  DSFDebounce.swift
//
//  Created by Darren Ford on 23/10/20.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Dispatch
import Foundation

class DSFDebounce {
	private let queue = DispatchQueue.main
	private var workItem = DispatchWorkItem(block: {})
	private var interval: TimeInterval

	// MARK: - Initializer
	init(seconds: TimeInterval) {
		self.interval = seconds
	}

	func debounce(action: @escaping (() -> Void)) {
		self.workItem.cancel()
		self.workItem = DispatchWorkItem(block: { action() })
		self.queue.asyncAfter(deadline: .now() + self.interval, execute: self.workItem)
	}
}

public extension DispatchQueue {
	/**
	 - parameters:
	 - target: Object used as the sentinel for de-duplication.
	 - delay: The time window for de-duplication to occur
	 - work: The work item to be invoked on the queue.
	 Performs work only once for the given target, given the time window. The last added work closure
	 is the work that will finally execute.
	 Note: This is currently only safe to call from the main thread.
	 Example usage:
	 ```
	 DispatchQueue.main.asyncDeduped(target: self, after: 1.0) { [weak self] in
	 self?.doTheWork()
	 }
	 ```
	 */
	func asyncDeduped(target: AnyObject, after delay: TimeInterval, execute work: @escaping @convention(block) () -> Void) {
		let dedupeIdentifier = DispatchQueue.dedupeIdentifierFor(target)
		if let existingWorkItem = DispatchQueue.workItems.removeValue(forKey: dedupeIdentifier) {
			existingWorkItem.cancel()
			NSLog("Deduped work item: \(dedupeIdentifier)")
		}
		let workItem = DispatchWorkItem {
			DispatchQueue.workItems.removeValue(forKey: dedupeIdentifier)

			for ptr in DispatchQueue.weakTargets.allObjects {
				if dedupeIdentifier == DispatchQueue.dedupeIdentifierFor(ptr as AnyObject) {
					work()
					NSLog("Ran work item: \(dedupeIdentifier)")
					break
				}
			}
		}

		DispatchQueue.workItems[dedupeIdentifier] = workItem
		DispatchQueue.weakTargets.addPointer(Unmanaged.passUnretained(target).toOpaque())

		asyncAfter(deadline: .now() + delay, execute: workItem)
	}
}

// MARK: - Static Properties for De-Duping

private extension DispatchQueue {
	static var workItems = [AnyHashable: DispatchWorkItem]()

	static var weakTargets = NSPointerArray.weakObjects()

	static func dedupeIdentifierFor(_ object: AnyObject) -> String {
		return "\(Unmanaged.passUnretained(object).toOpaque())." + String(describing: object)
	}
}
