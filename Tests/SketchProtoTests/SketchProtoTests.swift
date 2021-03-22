import XCTest
@testable import SketchProto

final class SketchProtoTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SketchProto().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
