import Foundation

final class Pagination {
    private let setHandler: (PageOffset) -> Void
    private let getHandler: () -> PageOffset
    
    private(set) var currentOffset: PageOffset {
        set { setHandler(newValue) }
        get { getHandler() }
    }
    
    init(set: @escaping (PageOffset) -> Void, get: @escaping () -> PageOffset) {
        self.setHandler = set
        self.getHandler = get
    }
    
    init(offset: UInt = 0) {
        var currentOffset = PageOffset.available(offset: offset)
        self.setHandler = { currentOffset = $0 }
        self.getHandler = { currentOffset }
    }
    
    func increment(by offset: UInt) {
        updateIfNotCompleted { currentOffset in
            return .available(offset: currentOffset + offset)
        }
    }
    
    func decrement(by offset: UInt) {
        updateIfNotCompleted { currentOffset in
            let newOffset = currentOffset > offset ? (currentOffset - offset) : 0
            return .available(offset: newOffset)
        }
    }
    
    func update(to pageOffset: PageOffset) {
        updateIfNotCompleted { _ in
            pageOffset
        }
    }
    
    private func updateIfNotCompleted(_ builder: (UInt) -> PageOffset) {
        switch currentOffset {
        case .completed:
            break
        case .available(let offset):
            currentOffset = builder(offset)
        }
    }
}
