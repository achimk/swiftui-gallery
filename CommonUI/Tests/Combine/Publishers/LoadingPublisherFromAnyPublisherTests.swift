import Combine
import CommonUI
import XCTest

class LoadingPublisherFromAnyPublisherTests: LoadingPublisherTests {
    override func makeTestComponents<Value>(
        for type: Value.Type,
        isSendAllowed: @escaping (LoadingPublisherTests.Event<Value>, LoadingState<Value, Error>) -> Bool = { !$1.isLoading }
    ) -> LoadingPublisherTests.TestComponents<Value> where Value: Equatable {
        let publisher = LoadingPublisher(
            queue: nil,
            operation: withEvent(type),
            isAllowed: isSendAllowed
        )

        let statePublisher: AnyPublisher<LoadingState<Value, String>, Never> = publisher
            .map { Self.mapEquatable($0.state) }
            .eraseToAnyPublisher()

        let stateRecorder = ValueRecoder(statePublisher)

        return TestComponents(
            publisher: publisher,
            stateRecorder: stateRecorder
        )
    }

    private func withEvent<T>(_: T.Type) -> (_ event: Event<T>) -> AnyPublisher<T, Error> {
        { event in
            switch event {
            case let .success(value):
                return Just(value)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            case let .throwError(error):
                return Fail(error: error).eraseToAnyPublisher()
            case .uncomplete:
                return Empty().eraseToAnyPublisher()
            case let .sleep(nanoseconds, result):
                let timeInterval = TimeInterval(nanoseconds / NSEC_PER_SEC)
                switch result {
                case let .success(value):
                    return Just(value)
                        .setFailureType(to: Error.self)
                        .delay(for: RunLoop.SchedulerTimeType.Stride(timeInterval), scheduler: RunLoop.main)
                        .eraseToAnyPublisher()
                case let .failure(error):
                    return Fail(error: error).eraseToAnyPublisher()
                        .delay(for: RunLoop.SchedulerTimeType.Stride(timeInterval), scheduler: RunLoop.main)
                        .eraseToAnyPublisher()
                }
            }
        }
    }
}
