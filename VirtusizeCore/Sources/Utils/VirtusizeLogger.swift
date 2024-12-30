//
//  InternalLogger.swift
//  VirtusizeCore
//
//  Copyright (c) 2024 Virtusize KK
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
