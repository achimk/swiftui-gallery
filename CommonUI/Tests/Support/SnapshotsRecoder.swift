import Combine
import Foundation
import XCTest

final class SnapshotsRecoder<Value> {
    private let snapshotPublisher = PassthroughSubject<Snapshot, Never>()
    private(set) var snapshots: [Snapshot] = []
    private var publishers = [AnyPublisher<Value, Never>]()
    private var cancellables = Set<AnyCancellable>()

    init(initialValues: [Value] = []) {
        snapshots.append(contentsOf: initialValues.map { Snapshot($0) })
    }

    var values: [Value] {
        snapshots.map(\.value)
    }

    func append(_ value: Value) {
        let snapshot = Snapshot(value)
        snapshots.append(snapshot)
        snapshotPublisher.send(snapshot)
    }

    func clear() {
        snapshots = []
    }
}

extension SnapshotsRecoder {
    func observeSnapshotAppend(_ callback: @escaping (Snapshot) -> Void) -> Cancellable {
        snapshotPublisher.sink(receiveValue: callback)
    }

    func observeValueAppend(_ callback: @escaping (Value) -> Void) -> Cancellable {
        snapshotPublisher.map(\.value).sink(receiveValue: callback)
    }
}

extension SnapshotsRecoder {
    func append(from publisher: AnyPublisher<Value, some Error>) {
        let publisher = publisher
            .catch { _ in Empty() }
            .setFailureType(to: Never.self)
            .eraseToAnyPublisher()
        publishers.append(publisher)
        publisher.sink(receiveValue: { [weak self] value in
            self?.append(value)
        }).store(in: &cancellables)
    }

    func cancelObservations() {
        cancellables.forEach { $0.cancel() }
        cancellables = Set()
        publishers = []
    }
}

extension SnapshotsRecoder {
    func count() -> Int {
        snapshots.count
    }

    func count(where included: (Value) -> Bool) -> Int {
        var counter = 0
        snapshots.forEach {
            if included($0.value) {
                counter += 1
            }
        }
        return counter
    }
}

extension SnapshotsRecoder {
    func waitUntil(
        _ condition: @escaping (Value) -> Bool,
        waiter: XCTWaiter? = nil,
        timeout seconds: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let expecation = XCTestExpectation(description: "SnapshotsRecoder is waiting for condition expecation.")
        let cancellation = observeValueAppend { value in
            if condition(value) {
                expecation.fulfill()
            }
        }

        let waiter = waiter ?? XCTWaiter()
        let result = waiter.wait(for: [expecation], timeout: seconds)
        switch result {
        case .completed:
            cancellation.cancel()
        default:
            cancellation.cancel()
            XCTFail(file: file, line: line)
        }
    }
}

extension SnapshotsRecoder {
    struct Snapshot {
        let value: Value
        let date: Date

        init(_ value: Value) {
            self.value = value
            date = Date()
        }
    }
}
