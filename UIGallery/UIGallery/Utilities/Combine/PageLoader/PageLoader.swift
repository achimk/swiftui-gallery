import Combine
import Foundation

enum PageLoaderEvent: Equatable {
    case loadFailed
    case loadMoreFailed
}

final class PageLoader<Query, Data>: Publisher {
    typealias Output = PagingState<Data>
    typealias Failure = Never

    private let stateSubject = CurrentValueSubject<PagingState<Data>, Never>(.initial)
    private let operation: (Query, UInt) async throws -> PageResult<Data>
    private var operationTask: Task<PageResult<Data>, Error>? {
        willSet {
            operationTask?.cancel()
        }
    }

    let pagination = Pagination()
    private(set) var state: PagingState<Data> {
        get { stateSubject.value }
        set { stateSubject.value = newValue }
    }

    init(_ operation: @escaping (Query, UInt) async throws -> PageResult<Data>) {
        self.operation = operation
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        stateSubject.receive(subscriber: subscriber)
    }
}

extension PageLoader {
    private enum Event {
        case loadRequested
        case loadMoreRequested
    }

    func start(with pageResult: PageResult<Data>) {
        operationTask = nil
        pagination.update(to: pageResult.offset)
        stateSubject.value = .success(.load, pageResult.data)
    }

    func reset() {
        operationTask = nil
        pagination.reset()
        stateSubject.value = .initial
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

extension PageLoader {
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
            pagination.update(to: .initial)
            state = .loading(.load)
            let result = try await handleLoadPage(with: query, offset: 0)
            pagination.update(to: result.offset)
            state = .success(.load, result.data)
        } catch is CancellationError {
            // ignored
        } catch {
            if Task.isCancelled {
                return
            }
            state = .failure(.load, error)
        }
    }

    @MainActor
    private func handleLoadMore(with query: Query) async {
        guard let offset = currentOffset() else {
            return
        }
        do {
            state = .loading(.loadMore)
            let result = try await handleLoadPage(with: query, offset: offset)
            pagination.update(to: result.offset)
            state = .success(.loadMore, result.data)
        } catch is CancellationError {
            // ignored
        } catch {
            if Task.isCancelled {
                return
            }
            pagination.update(to: .completed)
            state = .failure(.loadMore, error)
        }
    }

    @MainActor
    private func handleLoadPage(with query: Query, offset: UInt) async throws -> PageResult<Data> {
        let task = Task {
            try await operation(query, offset)
        }
        operationTask = task
        return try await task.value
    }

    private func canLoadMore() -> Bool {
        state.toPagingActivityStatus() != .loading && pagination.currentOffset != .completed && pagination.currentOffset != .initial
    }

    private func currentOffset() -> UInt? {
        switch pagination.currentOffset {
        case let .available(offset): return canLoadMore() ? offset : nil
        case .completed: return nil
        }
    }
}

extension PageLoader {
    var eventPublisher: AnyPublisher<PageLoaderEvent, Never> {
        stateSubject
            .dropFirst()
            .compactMap(makeEventMapper())
            .eraseToAnyPublisher()
    }

    private func makeEventMapper() -> (PagingState<Data>) -> PageLoaderEvent? {
        { pageState in
            switch pageState {
            case let .failure(request, _):
                switch request {
                case .load: return .loadFailed
                case .loadMore: return .loadMoreFailed
                }
            default:
                return nil
            }
        }
    }
}
