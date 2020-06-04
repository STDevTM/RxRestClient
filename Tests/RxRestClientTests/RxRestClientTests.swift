import XCTest
@testable import RxRestClient

final class RxRestClientTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RxRestClient().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
