import Foundation

final class Pagination {
    private let setHandler: (PageOffset) -> Void
    private let getHandler: () -> PageOffset

    private(set) var currentOffset: PageOffset {
        get { getHandler() }
        set { setHandler(newValue) }
    }

    init(set: @escaping (PageOffset) -> Void, get: @escaping () -> PageOffset) {
        setHandler = set
        getHandler = get
    }

    init(offset: UInt = 0) {
        var currentOffset = PageOffset.available(offset: offset)
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

    func update(to pageOffset: PageOffset) {
        currentOffset = pageOffset
    }

    func reset() {
        currentOffset = .initial
    }

    private func updateIfNotCompleted(_ builder: (UInt) -> PageOffset) {
        switch currentOffset {
        case .completed:
            break
        case let .available(offset):
            currentOffset = builder(offset)
        }
    }
}
