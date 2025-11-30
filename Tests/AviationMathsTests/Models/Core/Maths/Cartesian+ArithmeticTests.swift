import XCTest
@testable import AviationMaths

final class CartesianVectorArithmeticTests: XCTestCase {

    private func v(_ x: Double, _ y: Double) -> CartesianVector<UnitLength> {
        CartesianVector(
            x: .init(meters: x),
            y: .init(meters: y)
        )
    }

    func testAddition() {
        let a = v(1, 2)
        let b = v(3, 4)

        let result = a + b

        XCTAssertEqual(result.x.meters, 4)
        XCTAssertEqual(result.y.meters, 6)
    }

    func testSubtraction() {
        let a = v(5, 7)
        let b = v(2, 3)

        let result = a - b

        XCTAssertEqual(result.x.meters, 3)
        XCTAssertEqual(result.y.meters, 4)
    }

    func testUnaryMinus() {
        let a = v(3, -4)

        let result = -a

        XCTAssertEqual(result.x.meters, -3)
        XCTAssertEqual(result.y.meters, 4)
    }

    func testScalarMultiplication() {
        let a = v(2, -3)

        let result = a * 4

        XCTAssertEqual(result.x.meters, 8)
        XCTAssertEqual(result.y.meters, -12)
    }

    func testScalarMultiplicationReverse() {
        let a = v(2, -3)

        let result = 4 * a

        XCTAssertEqual(result.x.meters, 8)
        XCTAssertEqual(result.y.meters, -12)
    }

    func testScalarDivision() {
        let a = v(8, -6)

        let result = a / 2

        XCTAssertEqual(result.x.meters, 4)
        XCTAssertEqual(result.y.meters, -3)
    }

    func testPlusEqual() {
        var a = v(1, 1)
        a += v(2, 3)

        XCTAssertEqual(a.x.meters, 3)
        XCTAssertEqual(a.y.meters, 4)
    }

    func testMinusEqual() {
        var a = v(5, 5)
        a -= v(2, 1)

        XCTAssertEqual(a.x.meters, 3)
        XCTAssertEqual(a.y.meters, 4)
    }

    func testTimesEqual() {
        var a = v(2, 3)
        a *= 3

        XCTAssertEqual(a.x.meters, 6)
        XCTAssertEqual(a.y.meters, 9)
    }

    func testDivideEqual() {
        var a = v(10, 20)
        a /= 2

        XCTAssertEqual(a.x.meters, 5)
        XCTAssertEqual(a.y.meters, 10)
    }
}
