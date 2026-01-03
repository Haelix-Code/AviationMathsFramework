import XCTest
@testable import AviationMaths

final class PolarVectorAdvancedMathTests: XCTestCase {

    func testRotated_wrapsAndPreservesMagnitude() {
        let v = PolarVector(bearing: .init(degrees: 350), magnitude: .init(meters: 10))
        let r = v.rotated(by: .init(degrees: 20))

        XCTAssertEqual(r.bearing.degrees, 10, accuracy: 1e-12)
        XCTAssertEqual(r.magnitude.meters, 10, accuracy: 1e-12)
    }

    func testNormalized_setsMagnitudeToOne_preservesUnit() {
        let v = PolarVector(bearing: .init(degrees: 123), magnitude: .init(meters: 99))
        let n = v.normalized

        XCTAssertEqual(n.bearing.degrees, 123, accuracy: 1e-12)
        XCTAssertEqual(n.magnitude.meters, 1.0, accuracy: 1e-12)
    }

    func testDotProduct_knownCase() {
        // Two unit vectors: 0° and 60° => dot = cos(60) = 0.5
        let a = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 1))
        let b = PolarVector(bearing: .init(degrees: 60), magnitude: .init(meters: 1))

        let dot = a.dotProduct(b)
        XCTAssertEqual(dot.meters, 0.5, accuracy: 1e-12)
    }

    func testAngleBetween_knownCase() {
        let a = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 2))
        let b = PolarVector(bearing: .init(degrees: 90), magnitude: .init(meters: 3))

        let angle = a.angleBetween(b)
        XCTAssertEqual(angle.degrees, 90, accuracy: 1e-12)
    }

    func testAngleBetween_zeroMagnitude_returnsNaN() {
        let a = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 0))
        let b = PolarVector(bearing: .init(degrees: 90), magnitude: .init(meters: 1))

        let angle = a.angleBetween(b)
        XCTAssertTrue(angle.radians.isNaN)
    }
}
