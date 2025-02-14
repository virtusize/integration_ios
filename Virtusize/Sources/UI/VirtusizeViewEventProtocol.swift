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
internal protocol VirtusizeViewEventProtocol {
	var virtusizeEventHandler: VirtusizeEventHandler? { get set }
}

extension VirtusizeViewEventProtocol {
	public func handleUserOpenedWidget() {
		Task {
			await VirtusizeRepository.shared.fetchDataForInPageRecommendation(
				shouldUpdateUserProducts: false,
				shouldUpdateBodyProfile: false
			)
			VirtusizeRepository.shared.updateInPageRecommendation()
		}
	}

	public func handleUserAuthData(bid: String?, auth: String?) {
		VirtusizeRepository.shared.updateUserAuthData(bid: bid, auth: auth)
	}

	public func handleUserSelectedProduct(userProductId: Int?) {
		Task {
			await VirtusizeRepository.shared.fetchDataForInPageRecommendation(
				selectedUserProductId: userProductId,
				shouldUpdateUserProducts: false,
				shouldUpdateBodyProfile: false
			)
			VirtusizeRepository.shared.updateInPageRecommendation(type: .compareProduct)
		}
	}

	public func handleUserAddedProduct() {
		Task {
			await VirtusizeRepository.shared.fetchDataForInPageRecommendation(
				shouldUpdateUserProducts: true,
				shouldUpdateBodyProfile: false
			)
			VirtusizeRepository.shared.updateInPageRecommendation(type: .compareProduct)
		}
	}

	public func handleUserDeletedProduct(userProductId: Int?) {
		Task {
			VirtusizeRepository.shared.deleteUserProduct(userProductId)
			await VirtusizeRepository.shared.fetchDataForInPageRecommendation(
				shouldUpdateUserProducts: false,
				shouldUpdateBodyProfile: false
			)
			VirtusizeRepository.shared.updateInPageRecommendation()
		}
	}

	public func handleUserChangedRecommendationType(changedType: SizeRecommendationType?) {
		Task {
			VirtusizeRepository.shared.updateInPageRecommendation(type: changedType)
		}
	}

	public func handleUserUpdatedBodyMeasurements(recommendedSize: String?) {
		Task {
			VirtusizeRepository.shared.updateUserBodyRecommendedSize(recommendedSize)
			VirtusizeRepository.shared.updateInPageRecommendation(type: .body)
		}
	}

	public func handleUserLoggedIn() {
		Task {
			await VirtusizeRepository.shared.updateUserSession(forceUpdate: true)
			await VirtusizeRepository.shared.fetchDataForInPageRecommendation()
			VirtusizeRepository.shared.updateInPageRecommendation()
		}
	}

	public func handleClearUserData() {
		Task {
			await VirtusizeRepository.shared.clearUserData()
			await VirtusizeRepository.shared.updateUserSession(forceUpdate: true)
			await VirtusizeRepository.shared.fetchDataForInPageRecommendation()
			VirtusizeRepository.shared.updateInPageRecommendation()
		}
	}

    public func handleUserClosedWidget() {
        Task {
			await VirtusizeRepository.shared.updateUserSession(forceUpdate: true)
        }
    }
}
