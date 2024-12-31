//
//  VirtusizeLoggerTests.swift
//  VirtusizeCore
//
//  Copyright (c) 2024 Virtusize KK
//

import Testing
@testable import VirtusizeCore

struct VirtusizeLoggerTests {
	@Test func logHandler() {
		var invoked = false
		VirtusizeLogger.logLevel = .debug
		VirtusizeLogger.logHandler = { logLevel, message in
			#expect(logLevel == VirtusizeLogLevel.debug)
			#expect(message == "hello")
			invoked = true
		}
		VirtusizeLogger.debug("hello")
		#expect(invoked == true)
	}
	
	@Test func respectLevel() {
		var invoked = false
		VirtusizeLogger.logLevel = .warning
		VirtusizeLogger.logHandler = { logLevel, message in
			invoked = true
		}
		VirtusizeLogger.debug("hello")
		#expect(invoked == false)
	}
}
