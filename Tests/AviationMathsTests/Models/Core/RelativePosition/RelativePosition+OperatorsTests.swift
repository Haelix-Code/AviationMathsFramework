import XCTest

@testable import AviationMaths

final class RelativePositionOperatorTests: XCTestCase {

    private func makePosition(x: Double, y: Double) -> RelativePosition {
        return RelativePosition(vector2D: Vector2D(x: .init(meters: x), y: .init(meters: y)))
    }

    func testAdditionOperator() {
        let p1 = makePosition(x: 1, y: 2)
        let p2 = makePosition(x: 3, y: 4)

        let result = p1 + p2
        XCTAssertEqual(result.vector2D.x.meters, 4, accuracy: 0.001)
        XCTAssertEqual(result.vector2D.y.meters, 6)
    }

    func testSubtractionOperator() {
        let p1 = makePosition(x: 5, y: 7)
        let p2 = makePosition(x: 2, y: 3)

        let result = p1 - p2
        XCTAssertEqual(result.vector2D.x.meters, 3, accuracy: 0.00001)
        XCTAssertEqual(result.vector2D.y.meters, 4, accuracy: 0.00001)
    }

    func testPrefixNegationOperator() {
        let p = makePosition(x: 2, y: -3)
        let result = -p
        XCTAssertEqual(result.vector2D.x.meters, -2, accuracy: 0.00001)
        XCTAssertEqual(result.vector2D.y.meters, 3, accuracy: 0.00001)
    }

    func testMultiplicationWithScalar() {
        let p = makePosition(x: 2, y: 3)
        let result = p * 2.0
        XCTAssertEqual(result.vector2D.x.meters, 4, accuracy: 0.00001)
        XCTAssertEqual(result.vector2D.y.meters, 6, accuracy: 0.00001)
    }

    func testMultiplicationScalarOnLeft() {
        let p = makePosition(x: 1, y: -1)
        let result = 3.0 * p
        XCTAssertEqual(result.vector2D.x.meters, 3, accuracy: 0.00001)
        XCTAssertEqual(result.vector2D.y.meters, -3, accuracy: 0.00001)
    }

    func testDivisionWithScalar() {
        let p = makePosition(x: 6, y: 9)
        let result = p / 3.0
        XCTAssertEqual(result.vector2D.x.meters, 2, accuracy: 0.00001)
        XCTAssertEqual(result.vector2D.y.meters, 3, accuracy: 0.00001)
    }

    func testCompoundAdditionAssignment() {
        var p1 = makePosition(x: 1, y: 1)
        let p2 = makePosition(x: 2, y: 3)
        p1 += p2
        XCTAssertEqual(p1.vector2D.x.meters, 3, accuracy: 0.00001)
        XCTAssertEqual(p1.vector2D.y.meters, 4, accuracy: 0.00001)
    }

    func testCompoundSubtractionAssignment() {
        var p1 = makePosition(x: 5, y: 5)
        let p2 = makePosition(x: 2, y: 1)
        p1 -= p2
        XCTAssertEqual(p1.vector2D.x.meters, 3, accuracy: 0.00001)
        XCTAssertEqual(p1.vector2D.y.meters, 4, accuracy: 0.00001)
    }

    func testCompoundMultiplicationAssignment() {
        var p = makePosition(x: 2, y: 3)
        p *= 2
        XCTAssertEqual(p.vector2D.x.meters, 4, accuracy: 0.00001)
        XCTAssertEqual(p.vector2D.y.meters, 6, accuracy: 0.00001)
    }

    func testCompoundDivisionAssignment() {
        var p = makePosition(x: 10, y: 20)
        p /= 5
        XCTAssertEqual(p.vector2D.x.meters, 2, accuracy: 0.00001)
        XCTAssertEqual(p.vector2D.y.meters, 4, accuracy: 0.00001)
    }
}
