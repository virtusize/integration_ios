//
//  VirtusizeSentryTracker.swift
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

import Foundation
import Sentry

/// Utility for Sentry metrics and structured logs tracking in the Virtusize SDK.
internal enum VirtusizeSentryTracker {

    // MARK: - Session Management

    /// The current active session ID, set by Virtusize.load.
    static var currentSessionId: String = ""

    /// Generates a new UUID session ID, stores it as the current session, and returns it.
    /// Also configures the Sentry scope so all subsequent logs are tagged with the new session ID.
    @discardableResult
    static func generateSessionId() -> String {
        currentSessionId = UUID().uuidString
        SentrySDK.configureScope { scope in
            scope.setTag(value: currentSessionId, key: "session_id")
        }
        return currentSessionId
    }

    // MARK: - Metrics (Counters)

    static func increment(_ key: String, tags: [String: String] = [:]) {
        SentrySDK.metrics.count(
            key: key,
            value: 1,
            attributes: tags
        )
    }

    // MARK: - Logs

    static func logInfo(_ message: String, attributes: [String: String] = [:]) {
        SentrySDK.logger.info(message, attributes: attributes)
    }

    static func logWarning(_ message: String, attributes: [String: String] = [:]) {
        SentrySDK.logger.warn(message, attributes: attributes)
    }

    static func logError(_ message: String, attributes: [String: String] = [:]) {
        SentrySDK.logger.error(message, attributes: attributes)
    }

    // MARK: - Product Check

    static func trackProductCheck(externalProductId: String, isValid: Bool, storeId: String? = nil) {
        var tags: [String: String] = ["external_product_id": externalProductId, "is_valid": String(isValid)]
        if let storeId { tags["store_id"] = storeId }

        logInfo("product-check", attributes: tags)
    }

    static func trackLoadCancelled(step: String, externalProductId: String, storeId: String? = nil) {
        var tags: [String: String] = ["external_product_id": externalProductId, "step": step]
        if let storeId { tags["store_id"] = storeId }

        logWarning("load-cancelled", attributes: tags)
    }

    // MARK: - WebView Events

    static func trackWebViewEvent(
        eventName: String,
        storeId: String? = nil
    ) {
        var tags = ["event_name": eventName]
        if let storeId { tags["store_id"] = storeId }

        logInfo("webview-\(eventName)", attributes: tags)
    }

    static func trackUserSawProduct(externalProductId: String? = nil, storeId: String? = nil) {
        var tags: [String: String] = [:]
        if let storeId { tags["store_id"] = storeId }
        if let externalProductId { tags["external_product_id"] = externalProductId }

        increment("user.saw.product", tags: tags)
        logInfo("user-saw-product", attributes: tags)
    }

    // MARK: - Order

    static func trackSendOrder(order: VirtusizeOrder, storeId: String? = nil) {
        var baseTags: [String: String] = [:]
        if let storeId { baseTags["store_id"] = storeId }
        if order.items.isEmpty {
            increment("order.sent", tags: baseTags)
        } else {
            for item in order.items {
                var tags = baseTags
                tags["external_product_id"] = item.externalProductId
                increment("order.sent", tags: tags)
            }
        }

        logInfo("order-sent", attributes: baseTags)
    }

    // MARK: - API Request

    static func trackAPIRequest(endpoint: String, storeId: String? = nil) {
        var tags = ["endpoint": endpoint]
        if let storeId { tags["store_id"] = storeId }

        logInfo("api-request", attributes: tags)
    }

    // MARK: - Error

    static func trackError(
        _ error: Error,
        storeId: String? = nil
    ) {
        var tags = ["error_type": String(describing: type(of: error))]
        if let storeId { tags["store_id"] = storeId }

        increment("error", tags: tags)
        logError(error.localizedDescription, attributes: tags)
    }
}
