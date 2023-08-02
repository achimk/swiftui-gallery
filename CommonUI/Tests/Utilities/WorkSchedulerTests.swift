import CommonUI
import XCTest

class WorkSchedulerTests: XCTestCase {
    func test_scheduleWorkOnImmediateDispatcher_shouldCallInCorrectOrder() {
        var order: [Int] = []
        let scheduler = WorkScheduler(workDispatcher: makeImmediateScheduler())

        scheduler
            .schedule(at: .seconds(1)) {
                order.append(1)
            }
            .schedule(at: .seconds(1)) {
                order.append(2)
            }
            .schedule(at: .seconds(1)) {
                order.append(3)
            }
            .start()

        XCTAssertEqual(order, [1, 2, 3])
    }

    func test_scheduleWorkOnMainDispatcher_shouldCallInCorrectOrder() {
        var order: [Int] = []
        let expectation = XCTestExpectation()
        let scheduler = WorkScheduler()

        scheduler
            .schedule(at: .milliseconds(1)) {
                order.append(1)
            }
            .schedule(at: .milliseconds(1)) {
                order.append(2)
            }
            .schedule(at: .milliseconds(1)) {
                order.append(3)
            }
            .schedule(at: .milliseconds(1)) {
                expectation.fulfill()
            }
            .start()

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(order, [1, 2, 3])
    }
}

extension WorkSchedulerTests {
    private func makeImmediateScheduler() -> WorkScheduler.WorkDispatcher {
        { _, workItem in
            workItem.perform()
        }
    }
}
