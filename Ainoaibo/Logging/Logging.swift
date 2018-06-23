//
//  Logging.swift
//  Ainoaibo
//
//  Created by Zheng Li on 2018/6/6.
//  Copyright © 2018 ain. All rights reserved.
//

import CocoaLumberjack

public var AIBOAsynchronousLogging = false

enum LogCategory: String, OSLoggerIndexable {
    case `default`
    case settings
    case network

    var description: String {
        return self.rawValue
    }

    var loggerIndex: String {
        return description
    }
}

enum LogSubsystem: String, OSLoggerIndexable {
    case `default`
    var description: String {
        return self.rawValue
    }

    var loggerIndex: String {
        return description
    }
}

class LoggerTag: OSLoggerTag {
    let subsystem: LogSubsystem
    let category: LogCategory

    var rawSubsystem: OSLoggerIndexable { return subsystem }
    var rawCategory: OSLoggerIndexable { return category }

    init(subsystem: LogSubsystem, category: LogCategory) {
        self.subsystem = subsystem
        self.category = category
    }
}

func LogDebug(
    _ message: @autoclosure () -> String,
    level: DDLogLevel = defaultDebugLevel,
    context: Int = 0,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    category: LogCategory = .default,
    subsystem: LogSubsystem = .default,
    asynchronous async: Bool = AIBOAsynchronousLogging,
    ddlog: DDLog = DDLog.sharedInstance
) {
    _DDLogMessage(
        message,
        level: level,
        flag: .debug,
        context: context,
        file: file,
        function: function,
        line: line,
        tag: LoggerTag(subsystem: subsystem, category: category),
        asynchronous: async,
        ddlog: ddlog
    )
}

func LogInfo(
    _ message: @autoclosure () -> String,
    level: DDLogLevel = defaultDebugLevel,
    context: Int = 0,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    category: LogCategory = .default,
    subsystem: LogSubsystem = .default,
    asynchronous async: Bool = AIBOAsynchronousLogging,
    ddlog: DDLog = DDLog.sharedInstance
) {
    _DDLogMessage(
        message,
        level: level,
        flag: .info,
        context: context,
        file: file,
        function: function,
        line: line,
        tag: LoggerTag(subsystem: subsystem, category: category),
        asynchronous: async,
        ddlog: ddlog
    )
}

func LogWarn(
    _ message: @autoclosure () -> String,
    level: DDLogLevel = defaultDebugLevel,
    context: Int = 0,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    category: LogCategory = .default,
    subsystem: LogSubsystem = .default,
    asynchronous async: Bool = AIBOAsynchronousLogging,
    ddlog: DDLog = DDLog.sharedInstance
) {
    _DDLogMessage(
        message,
        level: level,
        flag: .warning,
        context: context,
        file: file,
        function: function,
        line: line,
        tag: LoggerTag(subsystem: subsystem, category: category),
        asynchronous: async,
        ddlog: ddlog
    )
}

func LogVerbose(
    _ message: @autoclosure () -> String,
    level: DDLogLevel = defaultDebugLevel,
    context: Int = 0,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    category: LogCategory = .default,
    subsystem: LogSubsystem = .default,
    asynchronous async: Bool = AIBOAsynchronousLogging,
    ddlog: DDLog = DDLog.sharedInstance
) {
    _DDLogMessage(
        message,
        level: level,
        flag: .verbose,
        context: context,
        file: file,
        function: function,
        line: line,
        tag: LoggerTag(subsystem: subsystem, category: category),
        asynchronous: async,
        ddlog: ddlog
    )
}

func LogError(
    _ message: @autoclosure () -> String,
    level: DDLogLevel = defaultDebugLevel,
    context: Int = 0,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    category: LogCategory = .default,
    subsystem: LogSubsystem = .default,
    asynchronous async: Bool = false,
    ddlog: DDLog = DDLog.sharedInstance
) {
    _DDLogMessage(
        message,
        level: level,
        flag: .error,
        context: context,
        file: file,
        function: function,
        line: line,
        tag: LoggerTag(subsystem: subsystem, category: category),
        asynchronous: async,
        ddlog: ddlog
    )
}
