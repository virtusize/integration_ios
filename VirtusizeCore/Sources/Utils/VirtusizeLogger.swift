//
//  InternalLogger.swift
//  VirtusizeCore
//
//  Copyright (c) 2024 Virtusize KK
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

public enum VirtusizeLogLevel: Int, CustomStringConvertible {
	case none = 0
	case error
	case warning
	case debug

	public var description: String {
		switch self {
		case .none:
			return "None"
		case .error:
			return "Error"
		case .warning:
			return "Warning"
		case .debug:
			return "Debug"
		}
	}
}

public class VirtusizeLogger {
	public static var logLevel: VirtusizeLogLevel = .none
	public static var logHandler: ((VirtusizeLogLevel, String) -> Void)?

	public static func debug(_ message: String) {
		log(level: .debug, message: message)
	}

	public static func warn(_ message: String) {
		log(level: .warning, message: message)
	}

	public static func error(_ message: String) {
		log(level: .error, message: message)
	}

	static func log(level: VirtusizeLogLevel, message: String) {
		if level == VirtusizeLogLevel.none {
			return
		}
		guard level.rawValue <= logLevel.rawValue else {
			return
		}

		if let handler = logHandler {
			handler(level, message)
		} else {
			let logMessage = "[Virtusize] \(level.description): \(message)"
			print(logMessage)
		}
	}
}
