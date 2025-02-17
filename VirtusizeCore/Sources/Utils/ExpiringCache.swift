//
//  SessionCache.swift
//  VirtusizeCore
//
//  Copyright (c) 2025-present Virtusize KK
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

private struct CacheEntry {
	let createdAt: Date
	let value: Any
	init(_ value: Any) {
		self.createdAt = Date()
		self.value = value
	}
}

public class ExpiringCache {
	public static let shared = ExpiringCache()

	private var cache = [String: CacheEntry]()

	/// Remove all cached values
	public func clearAll() {
		cache.removeAll()
	}

	/// Remove value for specified key
	public func clear(_ key: String) {
		cache.removeValue(forKey: key)
	}

	/// Put value into cache by specified key
	public func set(_ value: Any, forKey key: String) {
		cache[key] = CacheEntry(value)
	}

	/// Return cached value if exists, no matter if it's expired or not
	public func get(_ key: String) -> Any? {
		guard let cached = cache[key] else {
			return nil
		}
		return cached.value
	}

	/// Return cached value if it's within defind TTL (Time To Live) value
	/// Return "in progress" task, if it's already in progress for the same key
	/// Fetch, return and cache value, if it's is expired or not yet cached
	public func getOrFetch(_ key: String, ttl: TimeInterval, fetch: @escaping @Sendable () -> Any) -> Any {
		if let cached = cache[key] {
			let lifeTime = Date().timeIntervalSince(cached.createdAt)
			if lifeTime < ttl {
				print("> hit cache: .ready for '\(key)' (to live or another \(ttl - lifeTime) sec)")
				return cached.value
			} else {
				print("> hit cache: .expired for '\(key)' (outdated for \(lifeTime - ttl) sec)")
			}
		}

		let value = fetch()
		cache[key] = CacheEntry(value)
		return value
	}
}

extension ExpiringCache {
	/// Return cached value or load and cache
	/// - Parameters:
	///   - key: a string key to lookup and store the value
	///   - ttl: Time To Live in seconds. If the cached value is too old, the new value is loaded using `fetch` action
	///   - fetch: a function to execute if no value found or expired. Loaded result is stored into the cache
	public func getOrFetch<Value>(_ key: String, ttl: TimeInterval, fetch: @escaping @Sendable () -> Value) -> Value {
		let resultObj: Any = getOrFetch(key, ttl: ttl) { fetch() }
		return resultObj as! Value // swiftlint:disable:this force_cast
	}

	/// Return cached value or load and cache
	/// - Parameters:
	///   - key: a type key to lookup and store the value. Key is a string representation of the type
	///   - ttl: Time To Live in seconds. If the cached value is too old, the new value is loaded using `fetch` action
	///   - fetch: a function to execute if no value found or expired. Loaded result is stored into the cache
	public func getOrFetch<Value>(
		_ typeAsKey: Any.Type,
		ttl: TimeInterval,
		fetch: @escaping @Sendable () -> Value) -> Value {
			let key = String(describing: typeAsKey)
			return getOrFetch(key, ttl: ttl, fetch: fetch)
	}

	/// Return cached value if exists, irrelevant of expiration date
	public func get<Value>(_ key: String) -> Value? {
		return get(key) as? Value
	}

	public func clear(_ typeAsKey: Any.Type) {
		let key = String(describing: typeAsKey)
		clear(key)
	}

	public func set<Value>(_ value: Value, forKey typeAsKey: Any.Type) {
		let key = String(describing: typeAsKey)
		set(value, forKey: key)
	}
}

/// Helper for TimeInterval standard SDK values
extension TimeInterval {
	/// Forces value update
	public static var zero: TimeInterval {
		return 0
	}

	public static var short: TimeInterval {
		return 1800 // 30 minutes
	}

	public static var normal: TimeInterval {
		return 14400 // 4 hours
	}

	public static var day: TimeInterval {
		return 86400 // 24 hours
	}
}
