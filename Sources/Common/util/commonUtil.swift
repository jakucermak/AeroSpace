import Foundation
import AppKit

public let mainModeId = "main"
private var recursionDetectorDuringFailure: Bool = false

public func errorT<T>(
    _ message: String = "",
    file: String = #file,
    line: Int = #line,
    column: Int = #column,
    function: String = #function
) -> T {
    let message =
        """
        Please report to:
            https://github.com/nikitabobko/AeroSpace/issues/new

        Message: \(message)
        Version: \(aeroSpaceAppVersion)
        Git hash: \(gitHash)
        Coordinate: \(file):\(line):\(column) \(function)
        recursionDetectorDuringFailure: \(recursionDetectorDuringFailure)
        cli: \(isCli)

        Stacktrace:
        \(getStringStacktrace())
        """
    if !isUnitTest && isServer {
        showMessageInGui(
            filenameIfConsoleApp: recursionDetectorDuringFailure
                ? "aerospace-runtime-error-recursion.txt"
                : "aerospace-runtime-error.txt",
            title: "AeroSpace Runtime Error",
            message: message
        )
    }
    if !recursionDetectorDuringFailure {
        recursionDetectorDuringFailure = true
        terminationHandler.beforeTermination()
    }
    fatalError("\n" + message)
}

public func throwT<T>(_ error: Error) throws -> T {
    throw error
}

public func printStacktrace() { print(getStringStacktrace()) }
public func getStringStacktrace() -> String { Thread.callStackSymbols.joined(separator: "\n") }

@inlinable public func error(
    _ message: String = "",
    file: String = #file,
    line: Int = #line,
    column: Int = #column,
    function: String = #function
) -> Never {
    errorT(message, file: file, line: line, column: column, function: function)
}

public func check(
    _ condition: Bool,
    _ message: String = "",
    file: String = #file,
    line: Int = #line,
    column: Int = #column,
    function: String = #function
) {
    if !condition {
        error(message, file: file, line: line, column: column, function: function)
    }
}

@inlinable public func tryCatch<T>(
    file: String = #file,
    line: Int = #line,
    column: Int = #column,
    function: String = #function,
    body: () throws -> T
) -> Result<T, Error> {
    Result(catching: body)
}

public var isUnitTest: Bool { NSClassFromString("XCTestCase") != nil }

public extension CaseIterable where Self: RawRepresentable, RawValue == String {
    static var unionLiteral: String {
        "(" + allCases.map(\.rawValue).joined(separator: "|") + ")"
    }
}

public extension Int {
    func toDouble() -> Double { Double(self) }
}

public func + <K, V>(lhs: [K: V], rhs: [K: V]) -> [K: V] {
    lhs.merging(rhs) { _, r in r }
}

public extension String {
    func removePrefix(_ prefix: String) -> String {
        hasPrefix(prefix) ? String(dropFirst(prefix.count)) : self
    }

    func prependLines(_ prefix: String) -> String {
        split(separator: "\n").map { prefix + $0 }.joined(separator: "\n")
    }
}

public extension Double {
    var squared: Double { self * self }
}

public extension Slice {
    func toArray() -> [Base.Element] { Array(self) }
}

public extension URL {
    func open(with url: URL) {
        NSWorkspace.shared.open([self], withApplicationAt: url, configuration: NSWorkspace.OpenConfiguration())
    }
}

private var stderr = FileHandle.standardError
public func printStderr(_ msg: String) {
    print(msg, to: &stderr)
}
extension FileHandle: TextOutputStream {
    public func write(_ string: String) {
        let data = Data(string.utf8)
        self.write(data)
    }
}
