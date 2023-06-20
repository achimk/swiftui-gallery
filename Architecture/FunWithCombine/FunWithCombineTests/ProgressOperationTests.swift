import Foundation
@testable import FunWithCombine
import XCTest

class ProgressOperationTests: XCTestCase {
    func test_initialise_shouldInitWithValidValues() {
        let operation = ProgressOperation(numberOfSteps: 1, stepDuration: 1.0)
        XCTAssertEqual(operation.state, .initial)
        XCTAssertEqual(operation.currentStep, 0)
    }

    func test_start_shouldUpdateStateToRunning() {
        let components = makeTestComponents(numberOfSteps: 3)

        components.operation.start()

        XCTAssertEqual(components.operation.state, .running)
    }

    func test_start_shouldNotUpdateCurrentStep() {
        let components = makeTestComponents(numberOfSteps: 3)

        components.operation.start()

        XCTAssertEqual(components.operation.currentStep, 0)
    }

    func test_startAndProgress_shouldKeepRunningState() {
        let components = makeTestComponents(numberOfSteps: 3)

        components.operation.start()
        components.timerScheduler.timeElapsed()

        XCTAssertEqual(components.operation.state, .running)
    }

    func test_startAndProgress_shouldUpdateCurrentStep() {
        let components = makeTestComponents(numberOfSteps: 3)

        components.operation.start()
        components.timerScheduler.timeElapsed()

        XCTAssertEqual(components.operation.currentStep, 1)
    }

    func test_startAndProgressToLastStep_shouldUpdateStateToFinished() {
        let components = makeTestComponents(numberOfSteps: 3)

        components.operation.start()
        components.timerScheduler.timeElapsed()
        components.timerScheduler.timeElapsed()
        components.timerScheduler.timeElapsed()

        XCTAssertEqual(components.operation.state, .finished)
    }

    func test_startAndProgressToLastStep_shouldUpdateCurrentStep() {
        let components = makeTestComponents(numberOfSteps: 3)

        components.operation.start()
        components.timerScheduler.timeElapsed()
        components.timerScheduler.timeElapsed()
        components.timerScheduler.timeElapsed()

        XCTAssertEqual(components.operation.currentStep, 3)
    }

    func test_startAndProgressOutOfBounds_shouldNotUpdateFinishState() {
        let components = makeTestComponents(numberOfSteps: 1)

        components.operation.start()
        components.timerScheduler.timeElapsed()
        components.timerScheduler.timeElapsed()
        components.timerScheduler.timeElapsed()

        XCTAssertEqual(components.operation.state, .finished)
    }

    func test_startAndProgressOutOfBounds_shouldNotUpdateCurrentStep() {
        let components = makeTestComponents(numberOfSteps: 1)

        components.operation.start()
        components.timerScheduler.timeElapsed()
        components.timerScheduler.timeElapsed()
        components.timerScheduler.timeElapsed()

        XCTAssertEqual(components.operation.currentStep, 1)
    }

    func test_startForZeroSteps_shouldCompletedImmediately() {
        let components = makeTestComponents(numberOfSteps: 0)

        components.operation.start()

        XCTAssertEqual(components.operation.state, .finished)
    }

    func test_startForZeroSteps_shouldCompletedImmediatelyWithZeroSteps() {
        let components = makeTestComponents(numberOfSteps: 0)

        components.operation.start()

        XCTAssertEqual(components.operation.currentStep, 0)
    }

    func test_cancelWhenNotStarted_shouldUpdateToCancelled() {
        let components = makeTestComponents(numberOfSteps: 3)

        components.operation.cancel()

        XCTAssertEqual(components.operation.state, .cancelled)
    }

    func test_cancelWhenNotStarted_shouldNotUpdateCurrentStep() {
        let components = makeTestComponents(numberOfSteps: 3)

        components.operation.cancel()

        XCTAssertEqual(components.operation.currentStep, 0)
    }

    func test_cancelAfterStart_shouldUpdateToCancelled() {
        let components = makeTestComponents(numberOfSteps: 3)

        components.operation.start()
        components.operation.cancel()

        XCTAssertEqual(components.operation.state, .cancelled)
    }

    func test_cancelAfterStart_shouldNotUpdateCurrentStep() {
        let components = makeTestComponents(numberOfSteps: 3)

        components.operation.start()
        components.operation.cancel()

        XCTAssertEqual(components.operation.currentStep, 0)
    }

    func test_cancelAfterStartAndProgress_shouldUpdateToCancelled() {
        let components = makeTestComponents(numberOfSteps: 3)

        components.operation.start()
        components.timerScheduler.timeElapsed()
        components.operation.cancel()

        XCTAssertEqual(components.operation.state, .cancelled)
    }

    func test_cancelAfterStartAndProgress_shouldUpdateCurrentStep() {
        let components = makeTestComponents(numberOfSteps: 3)

        components.operation.start()
        components.timerScheduler.timeElapsed()
        components.operation.cancel()

        XCTAssertEqual(components.operation.currentStep, 1)
    }

    func test_cancelAfterFinish_shouldNotUpdateState() {
        let components = makeTestComponents(numberOfSteps: 3)

        components.operation.start()
        components.timerScheduler.timeElapsed()
        components.timerScheduler.timeElapsed()
        components.timerScheduler.timeElapsed()
        components.operation.cancel()

        XCTAssertEqual(components.operation.state, .finished)
    }

    func test_cancelAfterFinish_shouldNotUpdateCurrentStep() {
        let components = makeTestComponents(numberOfSteps: 3)

        components.operation.start()
        components.timerScheduler.timeElapsed()
        components.timerScheduler.timeElapsed()
        components.timerScheduler.timeElapsed()
        components.operation.cancel()

        XCTAssertEqual(components.operation.currentStep, 3)
    }
}

extension ProgressOperationTests {
    private struct TestComponents {
        let timerScheduler: TestTimerScheduler
        let operation: ProgressOperation
    }

    private func makeTestComponents(numberOfSteps: Int) -> TestComponents {
        let timerScheduler = TestTimerScheduler()
        let operation = ProgressOperation(
            numberOfSteps: numberOfSteps,
            stepDuration: 1.0,
            timerScheduler: timerScheduler.schedule(with:block:)
        )
        return TestComponents(
            timerScheduler: timerScheduler,
            operation: operation
        )
    }
}

private final class TestTimerScheduler {
    private(set) var scheduleInvoked = false
    private(set) var invalidateInvoked = false
    private var demands: [Bool] = []
    private var invokeBlocks: [() -> Void] = []

    func schedule(with _: TimeInterval, block: @escaping () -> Void) -> TimerInvalidate {
        scheduleInvoked = true
        invokeBlocks.append(block)
        dequeueAndRunIfNeeded()
        return { [weak self] in
            self?.invalidate()
        }
    }

    func timeElapsed() {
        demands.append(true)
        dequeueAndRunIfNeeded()
    }

    func invalidate() {
        invalidateInvoked = true
    }

    func reset() {
        scheduleInvoked = false
        invalidateInvoked = false
        invokeBlocks = []
        demands = []
    }

    private func dequeueAndRunIfNeeded() {
        zip(demands, invokeBlocks).enumerated().forEach { data in
            demands[data.offset] = false
            if data.element.0 {
                data.element.1()
            }
        }
    }
}
