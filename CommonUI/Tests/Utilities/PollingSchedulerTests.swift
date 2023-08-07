import Combine
import CommonUI
import XCTest

class PollingSchedulerTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables = Set()
        super.tearDown()
    }

    func test_cirtcularQueue_shouldInvokeInCorrectOrder() {
        let queue = CircularPollingQueue<Int>()
        queue.schedule(at: .milliseconds(10), action: { 1 })
        queue.schedule(at: .milliseconds(10), action: { 2 })
        queue.schedule(at: .milliseconds(10), action: { 3 })

        let scheduler = PollingScheduler(queue: queue)

        var order: [Int] = []
        let expectation = XCTestExpectation()
        scheduler.observePollingValue { [weak scheduler] value in
            order.append(value)
            if order.count == 9 {
                scheduler?.stop()
            }
        }.store(in: &cancellables)

        scheduler.observePollingState { state in
            if state == .idle {
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        scheduler.start()

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(order, [1, 2, 3, 1, 2, 3, 1, 2, 3])
    }

    func test_listQueue_shouldInvokeInCorrectOrder() {
        let queue = ListPollingQueue<Int>()
        queue.schedule(at: .milliseconds(10), action: { 1 })
        queue.schedule(at: .milliseconds(10), action: { 2 })
        queue.schedule(at: .milliseconds(10), action: { 3 })

        let scheduler = PollingScheduler(queue: queue)

        let expectation = XCTestExpectation()

        var order: [Int] = []
        scheduler.observePollingValue { value in
            order.append(value)
        }.store(in: &cancellables)

        scheduler.observePollingState { state in
            if state == .idle {
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        scheduler.start()

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(order, [1, 2, 3])
    }

    func test_zeroTimeIntervals_shouldInvokeAllActions() {
        let queue = ListPollingQueue<Int>()
        queue.schedule(at: 0, action: { 1 })
        queue.schedule(at: 0, action: { 2 })
        queue.schedule(at: 0, action: { 3 })

        let scheduler = PollingScheduler(queue: queue)

        let expectation = XCTestExpectation()

        var order: [Int] = []
        scheduler.observePollingValue { value in
            order.append(value)
        }.store(in: &cancellables)

        scheduler.observePollingState { state in
            if state == .idle {
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        scheduler.start()

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(order, [1, 2, 3])
    }
}
