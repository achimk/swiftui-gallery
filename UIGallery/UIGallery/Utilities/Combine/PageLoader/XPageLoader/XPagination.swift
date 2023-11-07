import Foundation

final class XPagination {
    private let setHandler: (XPageOffset) -> Void
    private let getHandler: () -> XPageOffset

    private(set) var currentOffset: XPageOffset {
        get { getHandler() }
        set { setHandler(newValue) }
    }

    init(set: @escaping (XPageOffset) -> Void, get: @escaping () -> XPageOffset) {
        setHandler = set
        getHandler = get
    }

    init(offset: UInt = 0) {
        var currentOffset = XPageOffset.available(offset: offset)
        setHandler = { currentOffset = $0 }
        getHandler = { currentOffset }
    }

    func increment(by offset: UInt) {
        updateIfNotCompleted { currentOffset in
            .available(offset: currentOffset + offset)
        }
    }

    func decrement(by offset: UInt) {
        updateIfNotCompleted { currentOffset in
            let newOffset = currentOffset > offset ? (currentOffset - offset) : 0
            return .available(offset: newOffset)
        }
    }

    func update(to pageOffset: XPageOffset) {
        currentOffset = pageOffset
    }

    func reset() {
        currentOffset = .initial
    }

    private func updateIfNotCompleted(_ builder: (UInt) -> XPageOffset) {
        switch currentOffset {
        case .completed:
            break
        case let .available(offset):
            currentOffset = builder(offset)
        }
    }
}
