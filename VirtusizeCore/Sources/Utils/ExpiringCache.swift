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

private enum CacheEntry {
	case inProgress(Task<Any, Error>)
	case ready(Date, Any)
}

public actor ExpiringCache {
	public static let shared = ExpiringCache()

	private var cache = [String: CacheEntry]()

	/// Remove all cached values
	internal func clearAll() {
		cache.removeAll()
	}

	/// Remove value for specified key
	internal func clear(_ key: String) {
		cache.removeValue(forKey: key)
	}

	/// Put value into cache by specified key
	internal func set(_ value: Any, forKey key: String) {
		cache[key] = .ready(Date(), value)
	}

	/// Return cached value if exists, no matter if it's expired or not
	internal func get(_ key: String) async throws -> Any? {
		switch cache[key] {
		case .inProgress(let task):
			return try await task.value
		case .ready(_, let value):
			return value
		case .none:
			return nil
		}
	}

	/// Return cached value if it's withing defind TTL (Time To Live) value
	/// Return "in progress" task, if it's already in progress for the same key
	/// Fetch, return and cache value, if it's is expired or not yet cached
	internal func getOrFetch(
		_ key: String,
		ttl: TimeInterval,
		fetch: @escaping @Sendable () async throws -> Any
	) async throws -> Any {
		if let cached = cache[key] {
			switch cached {
			case .inProgress(let task):
				return try await task.value
			case .ready(let createdAt, let value):
				let lifeTime = Date().timeIntervalSince(createdAt)
				if lifeTime < ttl {
					return value
				}
				// keep loading
			}
		}

		let task = Task<Any, Error> {
			try await fetch()
		}
		cache[key] = .inProgress(task)

		do {
			let result = try await task.value
			cache[key] = .ready(Date(), result)
			return result
		} catch {
			cache[key] = nil
			throw error
		}
	}
}

extension ExpiringCache {
	/// Return cached value or load and cache
	/// - Parameters:
	///   - key: a string key to lookup and store the value
	///   - ttl: Time To Live in seconds. If the cached value is too old, the new value is loaded using `fetch` action
	///   - fetch: a function to execute if no value found or expired. Loaded result is stored into the cache
	internal func getOrFetch<Value>(
		_ key: String,
		ttl: TimeInterval,
		fetch: @escaping @Sendable () async throws -> Value
	) async throws -> Value? {
		let resultObj: Any = try await getOrFetch(key, ttl: ttl) { try await fetch() }
		guard let result = resultObj as? Value else {
			VirtusizeLogger.warn("Type mismatch: Expected \(Value.self), but got \(type(of: resultObj))")
			return nil
		}
		return result
	}

	/// Return cached value or load and cache
	/// - Parameters:
	///   - key: a type key to lookup and store the value. Key is a string representation of the type
	///   - ttl: Time To Live in seconds. If the cached value is too old, the new value is loaded using `fetch` action
	///   - fetch: a function to execute if no value found or expired. Loaded result is stored into the cache
	public func getOrFetch<Value>(
		_ typeAsKey: Any.Type,
		ttl: TimeInterval,
		fetch: @escaping @Sendable () async throws -> Value
	) async throws -> Value? {
		let key = String(describing: typeAsKey)
		return try await getOrFetch(key, ttl: ttl, fetch: fetch)
	}

	/// Return cached value if exists, irrelevant of expiration date
	internal func get<Value>(_ key: String) async throws -> Value? {
		return try await get(key) as? Value
	}

	public func clear(_ typeAsKey: Any.Type) {
		let key = String(describing: typeAsKey)
		clear(key)
	}

	internal func set<Value>(_ value: Value, forKey typeAsKey: Any.Type) {
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
