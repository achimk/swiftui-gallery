import _Concurrency
import Combine
import Foundation
import PlaygroundSupport

final class InvokeCountdown {
    private let completion: () -> Void
    private(set) var counter: Int
    private(set) var isSealed = false

    init(counter: Int, completion: @escaping () -> Void) {
        self.counter = max(0, counter)
        self.completion = completion
    }

    func decrement() {
        guard counter > 0 else {
            completeIfNeeded()
            return
        }
        counter -= 1
        if counter == 0 {
            completeIfNeeded()
        }
    }

    private func completeIfNeeded() {
        if !isSealed {
            isSealed = true
            completion()
        }
    }
}

func makeSample<Error: Swift.Error>(
    from publisher: AnyPublisher<some Any, Error>,
    cancellables: inout [AnyCancellable],
    completion: @escaping (Result<[Int], Error>) -> Void
) {
    var order: [Int] = []
    publisher.sink { _ in
        // ...
    } receiveValue: { _ in
        order.append(1)
    }.store(in: &cancellables)

    publisher.sink { _ in
        // ...
    } receiveValue: { _ in
        order.append(2)
    }.store(in: &cancellables)

    publisher.sink { receivedCompletion in
        switch receivedCompletion {
        case .finished:
            completion(.success(order))
        case let .failure(error):
            completion(.failure(error))
        }
    } receiveValue: { _ in
        order.append(3)
    }.store(in: &cancellables)
}

func testRun(round: Int, completion: @escaping () -> Void) {
    var cancellables = [AnyCancellable]()
//    let subject = PassthroughSubject<Void, Never>()
    let subject = CurrentValueSubject<Void?, Never>(nil)
    makeSample(
        from: subject.receive(on: DispatchQueue.main).compactMap { $0 }.eraseToAnyPublisher(),
        cancellables: &cancellables,
        completion: { result in
            cancellables.removeAll()
            handleTestResult(result, for: round)
            completion()
        }
    )
    subject.send(())
    subject.send(completion: .finished)
}

func testRun(count: Int, completion: @escaping () -> Void) {
    var countdown = InvokeCountdown(counter: count, completion: completion)
    (0 ..< count).forEach { round in
        print("-> Starting \(round)...")
        testRun(round: round) {
            countdown.decrement()
        }
    }
}

func handleTestResult<Error: Swift.Error>(_ result: Result<[Int], Error>, for round: Int) {
    switch result {
    case let .success(order):
        if order != [1, 2, 3] {
            print("-> [\(round)] Invalid order!", order)
        } else {
            print("-> [\(round)] Completed")
        }
    case let .failure(error):
        print("-> [\(round)] Subscription received error: \(error)")
    }
}

Task { @MainActor in
    let completion: () -> Void = {
        PlaygroundPage.current.finishExecution()
    }

    testRun(count: 100, completion: completion)
}

PlaygroundPage.current.needsIndefiniteExecution = true
