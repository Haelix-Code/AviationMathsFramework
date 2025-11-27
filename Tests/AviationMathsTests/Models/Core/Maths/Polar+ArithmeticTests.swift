import XCTest
@testable import AviationMaths

final class PolarVectorMathTests: XCTestCase {

    private func dv(_ angleRad: Double, _ meters: Double) -> DistanceVector {
        DistanceVector(
            angle: .init(value: angleRad, unit: .radians),
            magnitude: .init(meters: meters)
        )
    }

    func testPolarAddition() {
        let v1 = dv(0, 1)
        let v2 = dv(.pi / 2, 1)

        let result = v1.adding(v2)

        XCTAssertEqual(result.vector2D.x.meters, 1, accuracy: 1e-10)
        XCTAssertEqual(result.vector2D.y.meters, 1, accuracy: 1e-10)

        XCTAssertEqual(result.magnitude.meters, sqrt(2), accuracy: 1e-10)
        XCTAssertEqual(result.angle.radians, .pi / 4, accuracy: 1e-10)
    }

    func testPolarSubtraction() {
        let v1 = dv(0, 2)
        let v2 = dv(0, 1)

        let result = v1.subtracting(v2)

        XCTAssertEqual(result.magnitude.meters, 1, accuracy: 1e-10)
        XCTAssertEqual(result.angle.radians, .pi/2, accuracy: 1e-10)
    }

    func testPolarRotation() {
        let v = dv(0, 10)
        let r = v.rotated(by: .init(value: .pi/2, unit: .radians))

        XCTAssertEqual(r.angle.radians, .pi/2, accuracy: 1e-10)
        XCTAssertEqual(r.magnitude.meters, 10)
    }

    func testNormalization() {
        let v = dv(.pi/3, 25)
        let n = v.normalized

        XCTAssertEqual(n.magnitude.meters, 1, accuracy: 1e-10)
        XCTAssertEqual(n.angle.radians, v.angle.radians, accuracy: 1e-10)
    }

    func testDotProduct() {
        let v1 = dv(0, 10)
        let v2 = dv(.pi/2, 10)

        let dot = v1.dotProduct(v2)

        XCTAssertEqual(dot.value, 0, accuracy: 1e-10)
    }

    func testDotProduct_Angled() {
        let v1 = dv(0, 10)
        let v2 = dv(.pi/4, 10)

        let expected = 10 * 10 * cos(Swift.Double.pi/4)

        XCTAssertEqual(v1.dotProduct(v2).value, expected, accuracy: 1e-10)
    }

    func testAngleBetween_Orthogonal() {
        let v1 = dv(0, 10)
        let v2 = dv(.pi/2, 10)

        let angle = v1.angleBetween(v2)

        XCTAssertEqual(angle.radians, .pi/2, accuracy: 1e-10)
    }

    func testAngleBetween_Acute() {
        let v1 = dv(0, 10)
        let v2 = dv(.pi/4, 10)

        let angle = v1.angleBetween(v2)

        XCTAssertEqual(angle.radians, .pi/4, accuracy: 1e-10)
    }

    func testAngleBetween_ExactOpposite() {
        let v1 = dv(0, 5)
        let v2 = dv(.pi, 5)

        let angle = v1.angleBetween(v2)

        XCTAssertEqual(angle.radians, .pi, accuracy: 1e-10)
    }

    func testAngleBetween_ZeroOrNaNForZeroMagnitude() {
        let zero = dv(0, 0)
        let v = dv(.pi/2, 5)

        let angle = zero.angleBetween(v)

        XCTAssertTrue(angle.value.isNaN)
    }
}
