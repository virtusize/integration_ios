//
//  VirtusizeViewEventProtocol.swift
//
//  Copyright (c) 2021-present Virtusize KK
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
internal protocol VirtusizeViewEventProtocol {}

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
