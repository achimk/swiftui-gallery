import CommonUI
import XCTest

final class LoadingStateTests: XCTestCase {
    typealias State = LoadingState<Int, String>

    struct TestError: Error, Equatable {}

    func testIsInitial() {
        let state = State.initial
        XCTAssertTrue(state.isInitial == true)
    }

    func testInvokedInitial() {
        var invoked = false
        let state = State.initial
        state.ifInitial { invoked = true }
        XCTAssertTrue(invoked == true)
    }

    func testInitialValue() {
        let state = State.initial
        XCTAssertTrue(state.value == nil)
    }

    func testInitialError() {
        let state = State.initial
        XCTAssertTrue(state.error == nil)
    }

    func testIsLoading() {
        let state = State.loading
        XCTAssertTrue(state.isLoading == true)
    }

    func testInvokedLoading() {
        var invoked = false
        let state = State.loading
        state.ifLoading { invoked = true }
        XCTAssertTrue(invoked == true)
    }

    func testLoadingValue() {
        let state = State.loading
        XCTAssertTrue(state.value == nil)
    }

    func testLoadingError() {
        let state = State.loading
        XCTAssertTrue(state.error == nil)
    }

    func testIsSuccess() {
        let state = State.success(1)
        XCTAssertTrue(state.isSuccess == true)
    }

    func testInvokedSuccess() {
        var invokedValue: Int?
        let state = State.success(1)
        state.ifSuccess { invokedValue = $0 }
        XCTAssertTrue(invokedValue == 1)
    }

    func testSuccessValue() {
        let state = State.success(1)
        XCTAssertTrue(state.value == 1)
    }

    func testSuccessError() {
        let state = State.success(1)
        XCTAssertTrue(state.error == nil)
    }

    func testIsFailure() {
        let state = State.failure("test")
        XCTAssertTrue(state.isFailure == true)
    }

    func testInvokedFailure() {
        var invokedValue: String?
        let state = State.failure("test")
        state.ifFailure { invokedValue = $0 }
        XCTAssertTrue(invokedValue == "test")
    }

    func testFailureValue() {
        let state = State.failure("test")
        XCTAssertTrue(state.value == nil)
    }

    func testFailureError() {
        let state = State.failure("test")
        XCTAssertTrue(state.error == "test")
    }

    func testEquatable() {
        let initial = State.initial
        let loading = State.loading
        let success = State.success(1)
        let failure = State.failure("test")

        XCTAssertTrue(initial == initial)
        XCTAssertTrue(loading == loading)
        XCTAssertTrue(success == success)
        XCTAssertTrue(failure == failure)
    }

    func testNotEquatable() {
        let initial = State.initial
        let loading = State.loading
        let success = State.success(1)
        let failure = State.failure("test")

        XCTAssertTrue(initial != loading)
        XCTAssertTrue(initial != success)
        XCTAssertTrue(initial != failure)
        XCTAssertTrue(loading != initial)
        XCTAssertTrue(loading != success)
        XCTAssertTrue(loading != failure)
        XCTAssertTrue(success != initial)
        XCTAssertTrue(success != loading)
        XCTAssertTrue(success != failure)
        XCTAssertTrue(failure != initial)
        XCTAssertTrue(failure != loading)
        XCTAssertTrue(failure != success)
    }

    func testResultConversion() {
        let initial = LoadingState<Int, TestError>.initial
        let loading = LoadingState<Int, TestError>.loading
        let success = LoadingState<Int, TestError>.success(1)
        let failure = LoadingState<Int, TestError>.failure(TestError())

        XCTAssertTrue(initial.toResult() == nil)
        XCTAssertTrue(loading.toResult() == nil)
        XCTAssertTrue(success.toResult() != nil)
        XCTAssertTrue(failure.toResult() != nil)

        XCTAssertTrue(success.value == 1)
        XCTAssertTrue(failure.error == TestError())
    }
}

extension LoadingStateTests {
    func testRaw() {
        let items: [LoadingStateRaw] = [
            .success,
            .success,
            .failure,
            .success,
            .success,
        ]

        let reduced = items.reduce(LoadingStateRaw.initial, reduce(_:_:))

        print(reduced)
    }
}

public extension LoadingState where Success == Void {
    static var success: LoadingState { LoadingState.success(()) }
}

public extension LoadingState where Failure == Void {
    static var failure: LoadingState { LoadingState.failure(()) }
}

public typealias LoadingStateRaw = LoadingState<Void, Void>

public func reduce(_ lhs: LoadingStateRaw, _ rhs: LoadingStateRaw) -> LoadingStateRaw {
    switch (lhs, rhs) {
    case (.initial, .loading): return .loading
    case (.loading, .initial): return .loading

    case (.initial, _): return .initial
    case (_, .initial): return .initial

    case (.loading, _): return .loading
    case (_, .loading): return .loading

    case (.failure, _): return .failure
    case (_, .failure): return .failure

    case (.success, .success): return .success
    }
}
