//
//  ExpiringCacheTests.swift
//  VirtusizeCore
//
//  Copyright (c) 2025 Virtusize KK
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

import Testing
@testable import VirtusizeCore

struct ExpiringCacheTests {
	init() async {
		ExpiringCache.shared.clearAll()
	}

	@Test func returnEmptySync() {
		let result = ExpiringCache.shared.get("foo")
		#expect(result == nil)
	}

	@Test func hitCachedSync() {
		ExpiringCache.shared.set("bar", forKey: "foo")
		let result: String? = ExpiringCache.shared.get("foo")
		#expect(result == "bar")
	}

	@Test func hitCached() {
		ExpiringCache.shared.set("bar", forKey: "foo")
		let result = ExpiringCache.shared.getOrFetch("foo", ttl: 1) {
			return "baz"
		}
		#expect(result == "bar")
	}

	@Test func fetchExpired() async throws {
		// put task in cache queue
		_ = ExpiringCache.shared.getOrFetch("foo", ttl: 1) {
			return "bar"
		}

		try await Task.sleep(nanoseconds: 50 * 1000_000) // wait for 50 ms - let some time pass

		let result = ExpiringCache.shared.getOrFetch("foo", ttl: 0) {
			return "baz"
		}
		#expect(result == "baz")
	}

	@Test func fetchWhenEmpty() {
		let result = ExpiringCache.shared.getOrFetch("foo", ttl: .short) {
			return "bar"
		}
		#expect(result == "bar")
	}

	@Test func typeMismatch() {
		ExpiringCache.shared.set(1, forKey: "foo")
		let result = ExpiringCache.shared.getOrFetch("foo", ttl: .short) {
			return "bar"
		}
		#expect(result == nil)
	}
}
