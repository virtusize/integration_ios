//
//  VirtusizeError.swift
//
//  Copyright (c) 2018-20 Virtusize KK
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

/// This enum contains all available errors in Virtusize library
public enum VirtusizeError: Error {
    case deserializationError
    case encodingError
    case invalidPayload
    case invalidProduct
    case invalidRequest
    case invalidVsParamScript
    case navigationError(Error)
    case jsonDecodingFailed(String, Error)
    case apiRequestError(URL?, String?)
}

extension VirtusizeError: CustomDebugStringConvertible {

    /// Gets the error message for the VirtusizeError
    public var debugDescription: String {
        switch self {
        case .invalidRequest:
            return "Virtusize: Invalid Request - Malformed query"
        case .deserializationError:
            return "Virtusize: Failed to deserialize given event payload"
        case .encodingError:
            return "Virtusize: Failed to convert given string to UTF-8 data"
        case .invalidPayload:
            return "Virtusize: Event payload does not contain a value for 'name'"
        case .invalidProduct:
            return "Virtusize: Product is not available for comparison"
        case .invalidVsParamScript:
            return "Virtusize: Failed to fetch the Virtusize parameter script"
        case .navigationError(let error):
            return "Virtusize: Navigation blocked – \(error)"
        case .jsonDecodingFailed(let structName, let error):
            return "Virtusize: Failed to decode the data response to the struct \(structName). \(error)"
        case .apiRequestError(let url, let errorDebugDescription):
            return "Virtusize: API Request \(url?.absoluteString ?? "") - \(errorDebugDescription ?? "")"
        }
    }
}
