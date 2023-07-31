import Foundation

public enum Once {
    public final class Lock {
        private let lock = NSLock()
        public private(set) var isSealed = false

        public init() {}

        public func lock(_ block: () -> Void = {}) {
            toggle(true, block)
        }

        public func unlock(_ block: () -> Void = {}) {
            toggle(false, block)
        }

        private func toggle(_ sealed: Bool, _ block: () -> Void) {
            if isSealed == sealed {
                return
            }

            lock.lock()
            defer { lock.unlock() }

            if isSealed == sealed {
                return
            }

            block()
            isSealed = sealed
        }
    }

    public final class Token {
        private let lock = NSLock()
        public private(set) var isSealed = false

        public init() {}

        public func run(_ block: () -> Void) {
            if isSealed {
                return
            }

            lock.lock()
            defer { lock.unlock() }

            if isSealed {
                return
            }

            block()
            isSealed = true
        }
    }
}
