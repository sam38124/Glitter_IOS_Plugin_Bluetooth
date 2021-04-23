import XCTest
@testable import Glitter_BLE

final class Glitter_BLETests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Glitter_BLE().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
