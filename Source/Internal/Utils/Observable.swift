//
//  Observable.swift
//
//  Copyright (c) 2018-present Virtusize KK
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

// The class warps a value in `AnyObject` to make it observable
internal final class Observable<Value> {

	struct Observer<Value> {
		weak var observer: AnyObject?
		let block: (Value) -> Void
	}

	private var observers = [Observer<Value>]()

	var value: Value {
		didSet { notifyObservers() }
	}

	init(_ value: Value) {
		self.value = value
	}

	func observe(on observer: AnyObject, observerBlock: @escaping (Value) -> Void) {
		observers.append(Observer(observer: observer, block: observerBlock))
		observerBlock(self.value)
	}

	func remove(observer: AnyObject) {
		observers = observers.filter { $0.observer !== observer }
	}

	private func notifyObservers() {
		for observer in observers {
			DispatchQueue.main.async { observer.block(self.value) }
		}
	}
}
