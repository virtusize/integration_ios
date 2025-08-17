//
//  Virtusize.swift
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
import UIKit

public class VirtusizeFlutter: Virtusize {
    
    private static var flutterHandler: VirtusizeFlutterProductEventHandler?

    /// A set to cache the product data check data of all the visited products
    private static var storeProductSet: Set<VirtusizeProduct> = []

    /// A set to cache the store product information of all the visited products
    private static var serverStoreProductSet: Set<VirtusizeServerProduct> = []
    
    /// Opens the Virtusize web view
    public static func openVirtusizeWebView(
        externalId: String,
        messageHandler: VirtusizeMessageHandler? = nil
    ) {
        let serverProduct = serverStoreProductSet.first { $0.externalId == externalId}
        VirtusizeRepository.shared.lastProductOnVirtusizeWebView = serverProduct
        
        let product = storeProductSet.first { $0.externalId == externalId}
        if let viewController = VirtusizeWebViewController(
            product: product,
            messageHandler: messageHandler,
            eventHandler: self.virtusizeEventHandler,
            processPool: self.processPool
        ) {
            if let windowScene = UIApplication.safeShared?.connectedScenes.first as? UIWindowScene {
                let rootViewController = windowScene.windows.first { $0.isKeyWindow }?.rootViewController
                rootViewController?.present(viewController, animated: true)
            }
        }
    }
    
    public static func sendOrder(
        _ orderDict: [String : Any?],
        onSuccess: (() -> Void)? = nil,
        onError: ((VirtusizeError) -> Void)? = nil) {
            guard let order = VirtusizeOrder.convertToObjectBy(dictionary: orderDict) else {
                onError?(VirtusizeError.encodingError)
                return
            }
            
            sendOrder(order, onSuccess: onSuccess, onError: onError)
    }
    
    public static func getPrivacyPolicyLink() -> String {
        return Localization.shared.localize("privacy_policy_link")
    }
    
    public static func initNotificationObserver(
        flutterHandler: VirtusizeFlutterProductEventHandler? = nil
    ) {
        self.flutterHandler = flutterHandler
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveProductCheckData(_:)),
            name: .productCheckData,
            object: Virtusize.self
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveStoreProduct(_:)),
            name: .storeProduct,
            object: Virtusize.self
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveSizeRecommendationData(_:)),
            name: .sizeRecommendationData,
            object: Virtusize.self
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveSetLanguageEvent(_:)),
            name: .setLanguage,
            object: Virtusize.self
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveInPageError(_:)),
            name: .inPageError,
            object: Virtusize.self
        )
    }

    @objc private static func didReceiveProductCheckData(_ notification: Notification) {
        guard let notificationData = notification.userInfo as? [String: Any],
              let productWithPDCData = notificationData[NotificationKey.productCheckData] as? VirtusizeProduct else {
            return
        }
        storeProductSet.insert(productWithPDCData)
        flutterHandler?.onProductCheckData(
            externalId: productWithPDCData.externalId,
            isValid: productWithPDCData.productCheckData?.validProduct ?? false
        )
    }

    @objc private static func didReceiveStoreProduct(_ notification: Notification) {
        guard let notificationData = notification.userInfo as? [String: Any],
              let storeProduct = notificationData[NotificationKey.storeProduct] as? VirtusizeServerProduct else {
            return
        }
        serverStoreProductSet.insert(storeProduct)
    }
    
    @objc private static func didReceiveSizeRecommendationData(_ notification: Notification) {
        guard let notificationData = notification.userInfo as? [String: Any],
              let sizeRecData = notificationData[NotificationKey.sizeRecommendationData] as? Virtusize.SizeRecommendationData else {
            return
        }
        
        let serverProduct = sizeRecData.serverProduct
        let clientProductImageURL = self.storeProductSet.first(where: {product in product.externalId == serverProduct.externalId})?.imageURL
        
        let bestUserProduct = sizeRecData.sizeComparisonRecommendedSize?.bestUserProduct
        let recommendationText = serverProduct.getRecommendationText(
            VirtusizeRepository.shared.i18nLocalization!,
            sizeRecData.sizeComparisonRecommendedSize,
            sizeRecData.bodyProfileRecommendedSize?.getSizeName,
            VirtusizeI18nLocalization.TrimType.MULTIPLELINES
        )
        flutterHandler?.onSizeRecommendationData(
            externalId: serverProduct.externalId,
            clientProductImageURL: clientProductImageURL?.absoluteString,
            storeProduct: serverProduct,
            bestUserProduct: bestUserProduct,
            recommendationText: recommendationText
        )
    }
    
    @objc private static func didReceiveSetLanguageEvent(_ notification: Notification) {
        guard let notificationData = notification.userInfo as? [String: Any],
              let language = notificationData[NotificationKey.setLanguage] as? VirtusizeLanguage else {
            return
        }
        flutterHandler?.onLanguageClick(language: language)
        Task {
            await VirtusizeRepository.shared.fetchDataForInPageRecommendation(shouldUpdateUserProducts: false)
        }
    }
    
    @objc private static func didReceiveInPageError(_ notification: Notification) {
        guard let notificationData = notification.userInfo as? [String: Any],
              let inPageError = notificationData[NotificationKey.inPageError] as? Virtusize.InPageError else {
            return
        }
        flutterHandler?.onInPageError(externalId: inPageError.externalProductId)
    }
}
