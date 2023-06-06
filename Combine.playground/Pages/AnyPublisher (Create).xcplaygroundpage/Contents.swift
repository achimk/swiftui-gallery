import Combine
import Foundation

extension AnyPublisher {
    static func create(_ subscribe: @escaping (AnySubscriber<Output, Failure>) -> AnyCancellable) -> AnyPublisher<Output, Failure> {
        let subject = PassthroughSubject<Output, Failure>()
        var cancellable: AnyCancellable?

        let subscriber = AnySubscriber<Output, Failure> { _ in
            // noop
        } receiveValue: { input in
            subject.send(input)
            return .unlimited
        } receiveCompletion: { completion in
            subject.send(completion: completion)
        }

        cancellable = subscribe(subscriber)

        return subject.eraseToAnyPublisher()

//        return subject
//            .handleEvents(receiveSubscription: { _ in
//                let subscriber = AnySubscriber<Output, Failure> { _ in
//                    // noop
//                } receiveValue: { input in
//                    subject.send(input)
//                    return .unlimited
//                } receiveCompletion: { completion in
//                    subject.send(completion: completion)
//                }
//                cancellable = subscribe(subscriber)
//            }, receiveCompletion: { completion in
//                // noop
//            }, receiveCancel: {
//                cancellable?.cancel()
//            })
//            .eraseToAnyPublisher()
    }
}

let justOne = AnyPublisher<Int, Never>.create { subscriber in
    subscriber.receive(1)
//    subscriber.receive(completion: .finished)
    return AnyCancellable {}
}

var cancellables: Set<AnyCancellable> = []

justOne.sink { completion in
    print("1. receive completion: \(completion)")
} receiveValue: { value in
    print("1. receive value: \(value)")
}.store(in: &cancellables)

justOne.sink { completion in
    print("2. receive completion: \(completion)")
} receiveValue: { value in
    print("2. receive value: \(value)")
}.store(in: &cancellables)
