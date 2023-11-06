import Combine
import Foundation

typealias PagePublisher<Data> = AnyPublisher<PageState<Data>, Never>

struct PageState<Data> {
    enum Request {
        case load
        case loadMore
    }

    var request: Request?
    var loadState: LoadingState<PageResult<Data>, Error> = .initial
    var offset: PageOffset = .initial
}

final class PageLoader<Query, Data>: Publisher {
    typealias Output = PageState<Data>
    typealias Failure = Never

    private enum Event {
        case loadRequested
        case loadMoreRequested
    }

    private let stateSubject = CurrentValueSubject<PageState<Data>, Never>(PageState())
    private let operation: (Query) async throws -> PageResult<Data>
    private var operationTask: Task<PageResult<Data>, Error>? {
        willSet {
            operationTask?.cancel()
        }
    }

    var state: PageState<Data> {
        stateSubject.value
    }

    init(_ operation: @escaping (Query) async throws -> PageResult<Data>) {
        self.operation = operation
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        stateSubject.receive(subscriber: subscriber)
    }
}

extension PageLoader {
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
            updateState {
                $0.loadState = .loading
                $0.request = .load
                $0.offset = .available(offset: 0)
            }
            let result = try await handleLoadPage(with: query)
            updateState {
                $0.loadState = .success(result)
                $0.offset = result.nextOffset
            }
        } catch {
            if Task.isCancelled {
                return
            }
            updateState {
                $0.loadState = .failure(error)
            }
        }
    }

    @MainActor
    private func handleLoadMore(with query: Query) async {
        guard canLoadMore() else {
            return
        }
        do {
            updateState {
                $0.loadState = .loading
                $0.request = .loadMore
            }
            let result = try await handleLoadPage(with: query)
            updateState {
                $0.loadState = .success(result)
                $0.offset = result.nextOffset
            }
        } catch {
            if Task.isCancelled {
                return
            }
            updateState {
                $0.loadState = .failure(error)
                $0.offset = .completed
            }
        }
    }

    @MainActor
    private func handleLoadPage(with query: Query) async throws -> PageResult<Data> {
        let task = Task {
            try await operation(query)
        }
        operationTask = task
        return try await task.value
    }

    private func canLoadMore() -> Bool {
        !state.loadState.isLoading && state.offset != .completed && state.offset != .initial
    }

    private func updateState(_ builder: (inout PageState<Data>) -> Void) {
        var state = stateSubject.value
        builder(&state)
        stateSubject.value = state
    }
}

extension PageLoader {
    func asPagination() -> Pagination {
        Pagination(set: { offset in
            self.updateState {
                $0.offset = offset
            }
        }, get: {
            self.state.offset
        })
    }
}
