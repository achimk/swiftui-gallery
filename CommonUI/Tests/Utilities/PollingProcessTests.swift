import Combine
import CommonUI
import XCTest

class PollingProcessTests: XCTestCase {
    func test_initialise_shouldBeIdle() {
        let components = makeTestComponents()
        XCTAssertEqual(components.process.state, .idle)
    }

    func test_startPolling_shouldUpdateToRunning() {
        let components = makeTestComponents()
        components.process.start()
        XCTAssertEqual(components.process.state, .running)
    }

    func test_stopStartedPolling_shouldUpdateToCancelled() {
        let components = makeTestComponents()
        components.process.start()
        components.process.stop()
        XCTAssertEqual(components.process.state, .idle)
    }

    func test_stopDuringExecution_shouldUpdateToCancelled() {
        let components = makeTestComponents()
        let process = components.process
        components.callbacks.onPerform = {
            process.stop()
        }

        components.process.start()
        components.scheduler.fire()

        XCTAssertEqual(components.process.state, .idle)
    }

    func test_stopDuringExection_shouldInvokeSchedulerCancellation() {
        let components = makeTestComponents()
        let process = components.process
        components.callbacks.onPerform = {
            process.stop()
        }

        components.process.start()
        let record = components.scheduler.fire()

        XCTAssertTrue(record?.isCancelled ?? false)
    }

    func test_polling_shouldReturnCorrectState() {
        let components = makeTestComponents()
        var counter = 0
        components.callbacks.onPerform = {
            counter += 1
        }

        components.process.start()
        components.scheduler.fire()
        components.scheduler.fire()
        components.scheduler.fire()

        XCTAssertEqual(components.process.state, .running)
    }

    func test_polling_shouldInvokeCorrectCount() {
        let components = makeTestComponents()
        var counter = 0
        components.callbacks.onPerform = {
            counter += 1
        }

        components.process.start()
        components.scheduler.fire()
        components.scheduler.fire()
        components.scheduler.fire()

        XCTAssertEqual(counter, 3)
    }

    func test_pollingAndStop_shouldReturnCorrectState() {
        let components = makeTestComponents()
        var counter = 0
        components.callbacks.onPerform = {
            counter += 1
        }

        components.process.start()
        components.scheduler.fire()
        components.scheduler.fire()
        components.scheduler.fire()
        components.process.stop()

        XCTAssertEqual(components.process.state, .idle)
    }

    func test_pollingAndStop_shouldInvokeCorrectCount() {
        let components = makeTestComponents()
        var counter = 0
        components.callbacks.onPerform = {
            counter += 1
        }

        components.process.start()
        components.scheduler.fire()
        components.scheduler.fire()
        components.scheduler.fire()
        components.process.stop()

        XCTAssertEqual(counter, 3)
    }

    func test_startImmediately_shouldInvokeJustAfterStart() {
        let components = makeTestComponents()
        var counter = 0
        components.callbacks.onPerform = {
            counter += 1
        }

        components.process.start(immediately: true)

        XCTAssertEqual(counter, 1)
    }

    func test_startImmediately_shouldScheduleNextPoll() {
        let components = makeTestComponents()
        var counter = 0
        components.callbacks.onPerform = {
            counter += 1
        }

        components.process.start(immediately: true)
        components.scheduler.fire()

        XCTAssertEqual(counter, 2)
    }
}

extension PollingProcessTests {
    private struct TestComponents {
        let process: PollingProcess<Void>
        let scheduler: TestTimerScheduler
        let callbacks: PollingCallbacks<Void>
    }

    private func makeTestComponents(
        timeInterval: TimeInterval = 1
    ) -> TestComponents {
        let scheduler = TestTimerScheduler()
        let callbacks = PollingCallbacks<Void>(())
        let process = PollingProcess<Void>(
            timeInterval: timeInterval,
            timerScheduler: scheduler.schedule(with:callback:),
            operation: callbacks.perform
        )

        return TestComponents(
            process: process,
            scheduler: scheduler,
            callbacks: callbacks
        )
    }
}

// MARK: - Helpers

private class TestTimerScheduler {
    private(set) var records: [PollingRecord] = []

    func schedule(
        with timeInterval: TimeInterval,
        callback: @escaping () -> Void
    ) -> Cancellable {
        let record = PollingRecord(
            timeInterval: timeInterval,
            callback: callback
        )
        records.append(record)
        return AnyCancellable {
            record.cancel()
        }
    }

    @discardableResult
    func fire() -> PollingRecord? {
        guard let record = records.first else {
            return nil
        }
        records.remove(at: 0)
        record.run()
        return record
    }
}

private class PollingRecord {
    private let timeInterval: TimeInterval
    private let callback: () -> Void
    private(set) var isCancelled: Bool = false

    init(
        timeInterval: TimeInterval,
        callback: @escaping () -> Void
    ) {
        self.timeInterval = timeInterval
        self.callback = callback
    }

    func run() {
        if !isCancelled {
            callback()
        }
    }

    func cancel() {
        isCancelled = true
    }
}

private class PollingCallbacks<Value> {
    var onBeforePerform: (() -> Void)?
    var onPerform: (() -> Void)?
    var onAfterPerform: (() -> Void)?
    var onInvalidate: (() -> Void)?
    var shouldAutoComplete = true
    var value: Value
    private var completion: ((Value) -> Void)?

    init(_ value: Value) {
        self.value = value
    }

    func perform(_ completion: @escaping (Value) -> Void) -> Cancellable {
        self.completion = completion
        onBeforePerform?()
        onPerform?()
        onAfterPerform?()
        if shouldAutoComplete {
            complete()
        }
        return AnyCancellable { [onInvalidate] in
            onInvalidate?()
        }
    }

    func complete() {
        completion?(value)
        completion = nil
    }
}
