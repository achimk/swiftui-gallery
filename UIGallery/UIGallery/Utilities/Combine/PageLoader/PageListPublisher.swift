import Combine
import Foundation

struct PageListPublisher<Item>: Publisher {
    typealias Output = [Item]
    typealias Failure = Never

    private let stateSubject = CurrentValueSubject<[Item], Never>([])
    private let pagePublisher: AnyPublisher<PagingState<[Item]>, Never>
    private let cancellable: Cancellable

    var items: [Item] {
        stateSubject.value
    }

    init(pagePublisher: AnyPublisher<PagingState<[Item]>, Never>) {
        self.pagePublisher = pagePublisher
        cancellable = pagePublisher
            .map(Self.makeStateReducer())
            .sink(receiveValue: { [stateSubject] items in
                stateSubject.value = items
            })
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        stateSubject.receive(subscriber: subscriber)
    }

    private static func makeStateReducer() -> (PagingState<[Item]>) -> [Item] {
        var items: [Item] = []
        return { pageState in
            switch pageState {
            case .initial:
                items = []
            case let .success(request, chunk):
                switch request {
                case .load:
                    items = chunk
                case .loadMore:
                    items = items + chunk
                }
            default:
                break
            }
            return items
        }
    }
}
