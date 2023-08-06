import Combine
import CommonUI
import XCTest

class PublisherPollingProcessTests: XCTestCase {
    enum Const {
        static let sleepTime: UInt64 = 100

        static func sleepTimeInterval() -> TimeInterval {
            TimeInterval(sleepTime / NSEC_PER_SEC)
        }
    }

    private let eventRecorder = SnapshotsRecoder<Event>()
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        eventRecorder.cancelObservations()
        eventRecorder.clear()
        cancellables = Set()
        super.tearDown()
    }

    func test_pollOneTimeAndStop_shouldReceiveEventsInCorrectOrder() {
        let components = makeTestComponents(operation: { [weak self] in
            self?.makePublisher() ?? Empty().eraseToAnyPublisher()
        })

        components.process.start()
        components.scheduler.fire()
        eventRecorder.waitUntil { $0 == .pollValueReceived }
        components.process.stop()

        XCTAssertEqual(eventRecorder.values, [
            .pollingStarted,
            .handleStarted,
            .handleFinished,
            .pollValueReceived,
            .pollingFinished,
        ])
    }
}

extension PublisherPollingProcessTests {
    private enum Event {
        case pollingStarted
        case pollingFinished
        case handleStarted
        case handleFinished
        case pollValueReceived
    }

    private struct TestComponents<Value> {
        let scheduler: TestTimerScheduler
        let process: PollingProcess<Value>
    }

    private func makeTestComponents<Value>(
        timeInterval: TimeInterval = 1,
        operation: @escaping () -> AnyPublisher<Value, Never>
    ) -> TestComponents<Value> {
        let scheduler = TestTimerScheduler()
        let process = PollingProcess<Value>(
            timeInterval: timeInterval,
            timerScheduler: scheduler.schedule(with:callback:),
            operation: operation
        )

        bind(process)

        return TestComponents(
            scheduler: scheduler,
            process: process
        )
    }

    private func bind(_ process: PollingProcess<some Any>) {
        var oldState = process.state
        process.observePollingState { [eventRecorder] state in
            let newState = state
            switch (oldState, newState) {
            case (.idle, .running):
                eventRecorder.append(.pollingStarted)
            case (.running, .idle):
                eventRecorder.append(.pollingFinished)
            default:
                break
            }
            oldState = state
        }.store(in: &cancellables)

        process.observePollingValue { [eventRecorder] _ in
            eventRecorder.append(.pollValueReceived)
        }.store(in: &cancellables)
    }

    private func makePublisher() -> AnyPublisher<Void, Never> {
        eventRecorder.append(.handleStarted)
        return Just(())
            .setFailureType(to: Never.self)
            .delay(for: RunLoop.SchedulerTimeType.Stride(Const.sleepTimeInterval()), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
            .handleEvents(receiveOutput: { [eventRecorder] in
                eventRecorder.append(.handleFinished)
            })
            .eraseToAnyPublisher()
    }
}
