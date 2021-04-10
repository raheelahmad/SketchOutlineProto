import XCTest
@testable import Sketcher

final class AutoLayoutTests: XCTestCase {
    func testExample() {
        let point = CGRect.linkPoints(
            from: CGRect(x: 0, y: 0, width: 200, height: 300),
            to: CGRect(x: 0, y: 0, width: 200, height: 300)
        )
        XCTAssertEqual(point.0, point.1)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
