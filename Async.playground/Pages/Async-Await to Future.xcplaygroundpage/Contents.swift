import _Concurrency
import Combine
import Foundation
import PlaygroundSupport

// MARK: - Utilities

func currentThread() -> Thread {
    Thread.current
}

func nanosecondsInOneSecond() -> UInt64 {
    NSEC_PER_SEC
}

func logCurrentThread(_ message: String? = nil) {
    log(currentThread(), message)
}

func log(_ thread: Thread, _ message: String? = nil) {
    let formatted = (message.flatMap { $0 + "\n" }) ?? ""
    print("\(formatted)Thread", thread, "is main:", thread.isMainThread)
}

func logIfChanged(_ current: Thread, _ message: String? = nil) {
    if current != Thread.current {
        let formatted = (message.flatMap { $0 + "\n" }) ?? ""
        print("\(formatted)Thread changed from", current, "to", Thread.current, "is main:", Thread.current.isMainThread)
    }
}

// MARK: - Future

// typealias Single<Success, Failure: Error> = Deferred<Future<Success, Failure>, Failure>

func withThrowingPublisher<Output>(_ operation: @escaping () async throws -> Output) -> AnyPublisher<Output, Error> {
    Deferred {
        var cancellation: (() -> Void)? = nil
        return Future<Output, Error> { promise in
            let task = Task { @MainActor in
                do {
                    try await promise(.success(operation()))
                } catch {
                    promise(.failure(error))
                }
            }
            cancellation = {
                print("$ received cancel - cancel task!")
                task.cancel()
            }
        }.handleEvents(receiveCancel: {
            cancellation?()
        })
    }
    .eraseToAnyPublisher()
}

extension Future where Failure == Error {
    convenience init(operation: @escaping () async throws -> Output) {
        self.init { promise in
            Task { @MainActor in
                do {
                    let output = try await operation()
                    promise(.success(output))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}

protocol Repository {
    func load() async throws -> String
}

class MockRepository: Repository {
    var loadResult: String = "test"

    @MainActor
    func load() async throws -> String {
        try await withTaskCancellationHandler {
            print("=> Repository: before sleep")
            try await Task.sleep(nanoseconds: nanosecondsInOneSecond() * 1)
            print("=> Repository: after sleep")
            try Task.checkCancellation()
            print("=> Repository: after check cancellation")
            return loadResult
        } onCancel: {
            print("=> Repository: cancel")
        }
    }
}

var cancellables = Set<AnyCancellable>()
func testRunFuture(shouldCancel: Bool = false, completion: @escaping () -> Void) {
//    let loadPublisher: AnyPublisher<String, Error> = Future(operation: MockRepository().load).eraseToAnyPublisher()
    let loadPublisher: AnyPublisher<String, Error> = withThrowingPublisher(MockRepository().load)

    loadPublisher.sink { state in
        switch state {
        case .finished:
            logCurrentThread("Finished:")
            print("-> load finished")
            completion()
        case let .failure(error):
            logCurrentThread("Failure:")
            print("-> load failed: \(error)")
        }
    } receiveValue: { value in
        logCurrentThread("Received value:")
        print("-> load received value: \(value)")
    }.store(in: &cancellables)

    if shouldCancel {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("# Invoke cancel")
            cancellables.forEach {
                $0.cancel()
            }
            cancellables = Set<AnyCancellable>()
            print("# Cancel finished")
        }
    }
}

Task { @MainActor in
    let completion: () -> Void = {
        PlaygroundPage.current.finishExecution()
    }

    testRunFuture(shouldCancel: true, completion: completion)
}

PlaygroundPage.current.needsIndefiniteExecution = true
