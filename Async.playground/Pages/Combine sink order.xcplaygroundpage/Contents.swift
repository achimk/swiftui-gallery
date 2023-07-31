import Combine
import Foundation

func testSubscriptionOrder(round: Int) {
    let publisher = PassthroughSubject<Void, Never>()
    var cancellables = [AnyCancellable]()

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

    publisher.sink { _ in
        // ...
    } receiveValue: { _ in
        order.append(3)
    }.store(in: &cancellables)

    publisher.send(())
    publisher.send(completion: .finished)

    if order != [1, 2, 3] {
        print("[\(round)] Invalid order!", order)
    } else {
        print("[\(round)] Correct order.")
    }
}

(1 ... 100).forEach { round in
    testSubscriptionOrder(round: round)
}
