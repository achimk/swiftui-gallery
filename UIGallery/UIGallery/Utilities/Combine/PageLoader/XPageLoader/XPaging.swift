import Combine
import Foundation

enum XPageRequest: Equatable {
    case load
    case loadMore
}

enum XPageActivityStatus: Equatable {
    case initial
    case loading
    case success
    case failure
}

extension XPageActivityStatus {
    func toActivityState() -> ActivityState {
        switch self {
        case .initial: return .initial
        case .loading: return .loading
        case .success: return .success
        case .failure: return .failure
        }
    }
}

enum XPageOffset: Equatable {
    case available(offset: UInt)
    case completed

    var isAvailable: Bool {
        switch self {
        case .available: return true
        case .completed: return false
        }
    }

    var isCompleted: Bool {
        switch self {
        case .available: return false
        case .completed: return true
        }
    }

    static let initial = XPageOffset.available(offset: 0)
}

struct XPageResult<Data> {
    let data: Data
    let offset: XPageOffset
}

struct XPagingState<Data> {
    var request: XPageRequest
    var offset: XPageOffset
    var status: XPageActivityStatus
    var data: Data
    var error: Error?

    static func from(_ pageResult: XPageResult<Data>) -> XPagingState<Data> {
        XPagingState(
            request: .load,
            offset: pageResult.offset,
            status: .initial,
            data: pageResult.data,
            error: nil
        )
    }
}

// MARK: - XPageDataLoader

enum XPageDataLoaderEvent: Equatable {
    case loadDataFailed
    case loadMoreDataFailed
}

final class XPageDataLoader<Query, Data>: Publisher {
    typealias Output = XPagingState<Data>
    typealias Failure = Never
    typealias Offset = UInt

    private enum Event {
        case loadRequested
        case loadMoreRequested
    }

    private let stateSubject: CurrentValueSubject<XPagingState<Data>, Never>
    private let emptyData: () -> Data
    private let operation: (Query, Offset) async throws -> XPageResult<Data>
    private var operationTask: Task<XPageResult<Data>, Error>? {
        willSet {
            operationTask?.cancel()
        }
    }

    var state: XPagingState<Data> {
        stateSubject.value
    }

    convenience init<Item>(
        _ operation: @escaping (Query, Offset) async throws -> XPageResult<[Item]>
    ) where Data == [Item] {
        self.init(emptyData: { [] }, operation: operation)
    }

    init(
        emptyData: @escaping () -> Data,
        operation: @escaping (Query, Offset) async throws -> XPageResult<Data>
    ) {
        self.emptyData = emptyData
        self.operation = operation
        stateSubject = CurrentValueSubject(.from(XPageResult(data: emptyData(), offset: .initial)))
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        stateSubject.receive(subscriber: subscriber)
    }
}

extension XPageDataLoader {
    func start(with result: XPageResult<Data>) {
        operationTask = nil
        stateSubject.value = .from(result)
    }

    func reset() {
        operationTask = nil
        stateSubject.value = .from(XPageResult(data: emptyData(), offset: .initial))
    }

    func load(with query: Query) {
        dispatch(.loadRequested, with: query)
    }

    func loadMore(with query: Query) {
        dispatch(.loadMoreRequested, with: query)
    }

    @MainActor
    func load(with query: Query) async {
        await dispatch(.loadRequested, with: query).value
    }

    @MainActor
    func loadMore(with query: Query) async {
        await dispatch(.loadMoreRequested, with: query).value
    }
}

extension XPageDataLoader {
    @discardableResult
    private func dispatch(_ event: Event, with query: Query) -> Task<Void, Never> {
        Task { @MainActor in
            switch event {
            case .loadRequested:
                await handleLoad(with: query)
            case .loadMoreRequested:
                await handleLoadMore(with: query)
            }
        }
    }

    @MainActor
    private func handleLoad(with query: Query) async {
        do {
            updateState {
                $0.request = .load
                $0.status = .loading
                $0.offset = .available(offset: 0)
                $0.data = emptyData()
                $0.error = nil
            }
            let result = try await handleLoadPage(with: query, offset: 0)
            updateState {
                $0.status = .success
                $0.offset = result.offset
                $0.data = result.data
            }
        } catch {
            if Task.isCancelled {
                return
            }
            updateState {
                $0.status = .failure
                $0.error = error
            }
        }
    }

    @MainActor
    private func handleLoadMore(with query: Query) async {
        guard let offset = currentOffset() else {
            return
        }
        do {
            updateState {
                $0.request = .loadMore
                $0.status = .loading
                $0.data = emptyData()
                $0.error = nil
            }
            let result = try await handleLoadPage(with: query, offset: offset)
            updateState {
                $0.status = .success
                $0.offset = result.offset
                $0.data = result.data
            }
        } catch {
            if Task.isCancelled {
                return
            }
            updateState {
                $0.status = .failure
                $0.offset = .completed
                $0.error = error
            }
        }
    }

    @MainActor
    private func handleLoadPage(with query: Query, offset: Offset) async throws -> XPageResult<Data> {
        let task = Task {
            try await operation(query, offset)
        }
        operationTask = task
        return try await task.value
    }

    private func canLoadMore() -> Bool {
        state.status != .loading && state.offset != .completed && state.offset != .initial
    }

    private func currentOffset() -> UInt? {
        switch state.offset {
        case let .available(offset): return canLoadMore() ? offset : nil
        case .completed: return nil
        }
    }

    private func updateState(_ builder: (inout XPagingState<Data>) -> Void) {
        var state = stateSubject.value
        builder(&state)
        stateSubject.value = state
    }
}

extension XPageDataLoader {
    var eventPublisher: AnyPublisher<XPageDataLoaderEvent, Never> {
        stateSubject
            .dropFirst()
            .compactMap(makeEventMapper())
            .eraseToAnyPublisher()
    }

    func asPagination() -> XPagination {
        XPagination(
            set: { offset in
                self.updateState {
                    $0.offset = offset
                }
            },
            get: {
                self.state.offset
            }
        )
    }
}

extension XPageDataLoader {
    private func makeEventMapper() -> (XPagingState<Data>) -> XPageDataLoaderEvent? {
        { pageState in
            switch pageState.status {
            case .failure:
                switch pageState.request {
                case .load: return .loadDataFailed
                case .loadMore: return .loadMoreDataFailed
                }
            default:
                return nil
            }
        }
    }
}

// MARK: - XPageDataListCollection

struct XPageDataListCollection<Item>: Publisher {
    typealias Output = XPagingState<[Item]>
    typealias Failure = Never

    private let stateSubject: CurrentValueSubject<Output, Never>
    private let pagePublisher: AnyPublisher<Output, Never>
    private let cancellable: Cancellable

    var state: Output {
        stateSubject.value
    }

    init(pagePublisher: AnyPublisher<Output, Never>) {
        self.pagePublisher = pagePublisher
        stateSubject = CurrentValueSubject(
            XPagingState(
                request: .load,
                offset: .initial,
                status: .initial,
                data: []
            )
        )
        cancellable = pagePublisher
            .map(Self.makeStateReducer())
            .assign(to: \.value, on: stateSubject)
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        stateSubject.receive(subscriber: subscriber)
    }

    private static func makeStateReducer() -> (XPagingState<[Item]>) -> XPagingState<[Item]> {
        var items: [Item] = []
        return { pageState in
            var newState = pageState
            switch pageState.request {
            case .load:
                if pageState.status == .success {
                    items = pageState.data
                }
            case .loadMore:
                if pageState.status == .success {
                    items = items + pageState.data
                }
            }
            newState.data = items
            return newState
        }
    }
}

// MARK: - XPageDataMutableListCollection

final class XPageDataMutableListCollection<Item>: Publisher {
    typealias Output = XPagingState<[Item]>
    typealias Failure = Never

    private let pagination: XPagination
    private let stateSubject: CurrentValueSubject<Output, Never>
    private let pagePublisher: AnyPublisher<Output, Never>
    private var cancellables = Set<AnyCancellable>()

    var state: Output {
        stateSubject.value
    }

    init(pagination: XPagination, pagePublisher: AnyPublisher<Output, Never>) {
        self.pagination = pagination
        self.pagePublisher = pagePublisher
        stateSubject = CurrentValueSubject(
            XPagingState(
                request: .load,
                offset: .initial,
                status: .initial,
                data: []
            )
        )
        setupBindings()
    }

    func insert(_ item: Item, at index: Int) {
        batchUpdate {
            $0.insert(item, at: index)
        }
    }

    func update(_ item: Item, at index: Int) {
        batchUpdate {
            $0[index] = item
        }
    }

    func remove(at index: Int) {
        batchUpdate {
            $0.remove(at: index)
        }
    }

    func batchUpdate(_ builder: (inout [Item]) -> Void) {
        var data = stateSubject.value.data
        builder(&data)
        let offset = data.count - stateSubject.value.data.count
        updatePagination(with: offset)
        updateState {
            $0.data = data
        }
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        stateSubject.receive(subscriber: subscriber)
    }
}

extension XPageDataMutableListCollection {
    private func updatePagination(with offset: Int) {
        guard offset != 0 else { return }
        if offset > 0 {
            pagination.increment(by: UInt(offset))
        } else {
            pagination.decrement(by: UInt(abs(offset)))
        }
    }

    private func setupBindings() {
        pagePublisher.sink { [weak self] pageState in
            self?.handleStateUpdate(pageState)
        }.store(in: &cancellables)
    }

    private func handleStateUpdate(_ pageState: XPagingState<[Item]>) {
        updateState {
            switch pageState.request {
            case .load:
                $0.data = pageState.data
            case .loadMore:
                if pageState.status == .success {
                    $0.data = $0.data + pageState.data
                }
            }
        }
    }

    private func updateState(_ builder: (inout Output) -> Void) {
        var state = stateSubject.value
        builder(&state)
        stateSubject.value = state
    }
}

// MARK: - XPagedListLoader

final class XPagedListLoader<Query, Item: Equatable> {
    private let pageDataLoader: XPageDataLoader<Query, [Item]>
    private let pageListCollection: XPageDataListCollection<Item>
    private var cancellables = Set<AnyCancellable>()

    var state: XPagingState<[Item]> {
        pageListCollection.state
    }

    init(_ operation: @escaping (Query, UInt) async throws -> XPageResult<[Item]>) {
        let pageDataLoader = XPageDataLoader(operation)
        let pageListCollection = XPageDataListCollection(pagePublisher: pageDataLoader.eraseToAnyPublisher())
        self.pageDataLoader = pageDataLoader
        self.pageListCollection = pageListCollection
    }

    // MARK: Inputs

    func load(with query: Query) {
        pageDataLoader.load(with: query)
    }

    func loadMore(with query: Query) {
        pageDataLoader.loadMore(with: query)
    }

    @MainActor
    func load(with query: Query) async {
        await pageDataLoader.load(with: query)
    }

    @MainActor
    func loadMore(with query: Query) async {
        await pageDataLoader.loadMore(with: query)
    }

    func reset() {
        pageDataLoader.reset()
    }

    // MARK: Output

    var statePublisher: AnyPublisher<XPagingState<[Item]>, Never> {
        pageListCollection.eraseToAnyPublisher()
    }

    var eventPublisher: AnyPublisher<XPageDataLoaderEvent, Never> {
        pageDataLoader.eventPublisher
    }
}
