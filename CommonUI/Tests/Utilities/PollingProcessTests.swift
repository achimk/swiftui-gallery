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
        let process: PollingProcess
        let scheduler: TestPollingScheduler
        let callbacks: PollingCallbacks
    }

    private func makeTestComponents(
        timeInterval: TimeInterval = 1
    ) -> TestComponents {
        let scheduler = TestPollingScheduler()
        let callbacks = PollingCallbacks()
        let process = PollingProcess(
            timeInterval: timeInterval,
            perform: callbacks.perform,
            pollingScheduler: scheduler.schedule(with:callback:)
        )

        return TestComponents(
            process: process,
            scheduler: scheduler,
            callbacks: callbacks
        )
    }
}

// MARK: - Helpers

private class TestPollingScheduler {
    private(set) var records: [PollingRecord] = []

    func schedule(
        with timeInterval: TimeInterval,
        callback: @escaping () -> PollingInvalidate
    ) -> PollingInvalidate {
        let record = PollingRecord(
            timeInterval: timeInterval,
            callback: callback
        )
        records.append(record)
        return record.cancel
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
    let timeInterval: TimeInterval
    private let callback: () -> PollingInvalidate
    private(set) var isCancelled: Bool = false
    private var cancellable: PollingInvalidate?

    init(
        timeInterval: TimeInterval,
        callback: @escaping () -> PollingInvalidate
    ) {
        self.timeInterval = timeInterval
        self.callback = callback
    }

    func run() {
        cancellable = callback()
    }

    func cancel() {
        cancellable?()
        cancellable = nil
        isCancelled = true
    }
}

private class PollingCallbacks {
    var onBeforePerform: (() -> Void)?
    var onPerform: (() -> Void)?
    var onAfterPerform: (() -> Void)?
    var onInvalidate: (() -> Void)?
    var shouldAutoComplete = true
    private var completion: PollingCompletion?

    func perform(_ completion: @escaping PollingCompletion) -> PollingInvalidate {
        self.completion = completion
        onBeforePerform?()
        onPerform?()
        onAfterPerform?()
        if shouldAutoComplete {
            complete()
        }
        return { [onInvalidate] in
            onInvalidate?()
        }
    }

    func complete() {
        completion?()
        completion = nil
    }
}
