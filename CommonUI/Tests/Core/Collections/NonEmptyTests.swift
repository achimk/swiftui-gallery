import CommonUI
import XCTest

final class NonEmptyTests: XCTestCase {
    func test_whenInitializedWithEmptyCollection_shouldReturnNil() {
        let empty: [Int] = []
        let result = NonEmpty(empty)
        XCTAssertEqual(result.isPresent, false)
    }

    func test_whenInitializedWithNonEmptyCollection_shouldReturnNonEmpty() {
        let nonEmpty = [1]
        let result = NonEmpty(nonEmpty)
        XCTAssertEqual(result.isPresent, true)
    }

    func test_whenInitializedWithNonEmptyCollection_shouldReturnFirstElement() {
        let nonEmpty: [Int] = [1, 2, 3]
        let result = NonEmpty(nonEmpty)
        XCTAssertEqual(result?.head, 1)
    }
}
