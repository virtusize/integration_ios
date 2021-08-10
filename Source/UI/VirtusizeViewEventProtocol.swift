//
//  VirtusizeViewEventProtocol.swift
//  Virtusize
//
//  Created by Kuei-Jung Hu on 2021/08/10.
//  Copyright © 2021 Virtusize AB. All rights reserved.
//

internal protocol VirtusizeViewEventProtocol {
	var virtusizeEventHandler: VirtusizeEventHandler? { get set }
}

extension VirtusizeViewEventProtocol {
	public func handleUserOpenedWidget() {
		VirtusizeRepository.shared.fetchDataForInPageRecommendation(
			shouldUpdateUserProducts: false,
			shouldUpdateBodyProfile: false
		)
		VirtusizeRepository.shared.updateInPageRecommendation()
	}

	public func handleUserAuthData(bid: String?, auth: String?) {
		VirtusizeRepository.shared.updateUserAuthData(bid: bid, auth: auth)
	}

	public func handleUserSelectedProduct(userProductId: Int?) {
		Virtusize.dispatchQueue.async {
			VirtusizeRepository.shared.fetchDataForInPageRecommendation(
				selectedUserProductId: userProductId,
				shouldUpdateUserProducts: false,
				shouldUpdateBodyProfile: false
			)
			VirtusizeRepository.shared.updateInPageRecommendation(type: .compareProduct)
		}
	}

	public func handleUserAddedProduct() {
		Virtusize.dispatchQueue.async {
			VirtusizeRepository.shared.fetchDataForInPageRecommendation(
				shouldUpdateUserProducts: true,
				shouldUpdateBodyProfile: false
			)
			VirtusizeRepository.shared.updateInPageRecommendation(type: .compareProduct)
		}
	}

	public func handleUserDeletedProduct(userProductId: Int?) {
		Virtusize.dispatchQueue.async {
			VirtusizeRepository.shared.deleteUserProduct(userProductId)
			VirtusizeRepository.shared.fetchDataForInPageRecommendation(
				shouldUpdateUserProducts: false,
				shouldUpdateBodyProfile: false
			)
			VirtusizeRepository.shared.updateInPageRecommendation()
		}
	}

	public func handleUserChangedRecommendationType(changedType: SizeRecommendationType?) {
		Virtusize.dispatchQueue.async {
			VirtusizeRepository.shared.updateInPageRecommendation(type: changedType)
		}
	}

	public func handleUserUpdatedBodyMeasurements(recommendedSize: String?) {
		Virtusize.dispatchQueue.async {
			VirtusizeRepository.shared.updateUserBodyRecommendedSize(recommendedSize)
			VirtusizeRepository.shared.updateInPageRecommendation(type: .body)
		}
	}

	public func handleUserLoggedIn() {
		Virtusize.dispatchQueue.async {
			VirtusizeRepository.shared.updateUserSession()
			VirtusizeRepository.shared.fetchDataForInPageRecommendation()
			VirtusizeRepository.shared.updateInPageRecommendation()
		}
	}

	public func handleClearUserData() {
		Virtusize.dispatchQueue.async {
			VirtusizeRepository.shared.clearUserData()
			VirtusizeRepository.shared.updateUserSession()
			VirtusizeRepository.shared.fetchDataForInPageRecommendation(
				shouldUpdateUserProducts: false,
				shouldUpdateBodyProfile: false
			)
			VirtusizeRepository.shared.updateInPageRecommendation()
		}
	}
}
