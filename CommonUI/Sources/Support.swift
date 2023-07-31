import Foundation

public func assertMainThread(file: StaticString = #file, line: UInt = #line) {
    assert(Thread.isMainThread, "Should be called on main thread!", file: file, line: line)
}

public func abstractMethod(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("Subclasses should override method!", file: file, line: line)
}

public func undefined<T>(_ message: String? = nil, file: StaticString = #file, line: UInt = #line) -> T {
    fatalError(message ?? "Undefined \(T.self)!", file: file, line: line)
}
