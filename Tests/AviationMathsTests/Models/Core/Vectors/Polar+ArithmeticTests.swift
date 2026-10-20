import XCTest
@testable import AviationMaths
import Foundation

final class PolarArithmeticVectorTests: XCTestCase {

    func testAdding_PerpendicularVectors() {
        // 3m North + 4m East = 5m at bearing ~53°
        let north = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 3))
        let east = PolarVector(bearing: .init(degrees: 90), magnitude: .init(meters: 4))

        let result = north.adding(east)

        XCTAssertEqual(result.magnitude.meters, 5, accuracy: 0.0001)
        XCTAssertEqual(result.bearing.degrees, 53.13, accuracy: 0.01)  // atan(4/3)
    }

    func testAdding_SameDirection() {
        // 3m North + 4m North = 7m North
        let v1 = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 3))
        let v2 = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 4))

        let result = v1.adding(v2)

        XCTAssertEqual(result.magnitude.meters, 7, accuracy: 0.0001)
        XCTAssertEqual(result.bearing.degrees, 0, accuracy: 0.0001)
    }

    func testAdding_OppositeDirections() {
        // 5m North + 3m South = 2m North
        let north = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 5))
        let south = PolarVector(bearing: .init(degrees: 180), magnitude: .init(meters: 3))

        let result = north.adding(south)

        XCTAssertEqual(result.magnitude.meters, 2, accuracy: 0.0001)
        XCTAssertEqual(result.bearing.degrees, 0, accuracy: 0.0001)
    }

    func testAdding_CancelOut() {
        // Equal opposite vectors cancel
        let north = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 10))
        let south = PolarVector(bearing: .init(degrees: 180), magnitude: .init(meters: 10))

        let result = north.adding(south)

        XCTAssertEqual(result.magnitude.meters, 0, accuracy: 0.0001)
    }

    func testSubtracting_PerpendicularVectors() {
        // 5m North - 3m East
        let north = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 5))
        let east = PolarVector(bearing: .init(degrees: 90), magnitude: .init(meters: 3))

        let result = north.subtracting(east)

        // Result: 5m North + 3m West = √(25+9) = 5.83m at bearing ~329°
        XCTAssertEqual(result.magnitude.meters, 5.831, accuracy: 0.001)
        XCTAssertEqual(result.bearing.degrees, 329.04, accuracy: 0.01)  // NW quadrant
    }

    func testSubtracting_SameVector() {
        let v = PolarVector(bearing: .init(degrees: 45), magnitude: .init(meters: 10))

        let result = v.subtracting(v)

        XCTAssertEqual(result.magnitude.meters, 0, accuracy: 0.0001)
    }

    func testRotated_Clockwise90() {
        // North rotated 90° clockwise = East
        let north = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 10))

        let result = north.rotated(by: .init(degrees: 90))

        XCTAssertEqual(result.magnitude.meters, 10, accuracy: 0.0001)
        XCTAssertEqual(result.bearing.degrees, 90, accuracy: 0.0001)
    }

    func testRotated_Clockwise180() {
        // NE rotated 180° = SW
        let ne = PolarVector(bearing: .init(degrees: 45), magnitude: .init(meters: 10))

        let result = ne.rotated(by: .init(degrees: 180))

        XCTAssertEqual(result.magnitude.meters, 10, accuracy: 0.0001)
        XCTAssertEqual(result.bearing.degrees, 225, accuracy: 0.0001)
    }

    func testRotated_CounterClockwise() {
        // East rotated -90° (CCW) = North
        let east = PolarVector(bearing: .init(degrees: 90), magnitude: .init(meters: 10))

        let result = east.rotated(by: .init(degrees: -90))

        XCTAssertEqual(result.magnitude.meters, 10, accuracy: 0.0001)
        XCTAssertEqual(result.bearing.degrees, 0, accuracy: 0.0001)
    }

    func testRotated_FullCircle() {
        let v = PolarVector(bearing: .init(degrees: 45), magnitude: .init(meters: 5))

        let result = v.rotated(by: .init(degrees: 360))

        XCTAssertEqual(result.bearing.degrees, 45, accuracy: 0.0001)
    }

    func testRotated_Wrapping() {
        // 300° + 90° = 390° → 30°
        let v = PolarVector(bearing: .init(degrees: 300), magnitude: .init(meters: 10))

        let result = v.rotated(by: .init(degrees: 90))

        XCTAssertEqual(result.bearing.degrees, 30, accuracy: 0.0001)
    }

    func testNormalized() {
        let v = PolarVector(bearing: .init(degrees: 135), magnitude: .init(meters: 50))

        let result = v.normalized

        XCTAssertEqual(result.magnitude.meters, 1, accuracy: 0.0001)
        XCTAssertEqual(result.bearing.degrees, 135, accuracy: 0.0001)
    }

    func testNormalized_PreservesBearing() {
        let bearings: [Double] = [0, 45, 90, 180, 270, 315]

        for bearing in bearings {
            let v = PolarVector(bearing: .init(degrees: bearing), magnitude: .init(meters: 100))
            let result = v.normalized

            XCTAssertEqual(result.bearing.degrees, bearing, accuracy: 0.0001,
                          "Failed for bearing \(bearing)")
        }
    }

    func testDotProduct_Perpendicular() {
        // Perpendicular vectors have dot product = 0
        let north = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 10))
        let east = PolarVector(bearing: .init(degrees: 90), magnitude: .init(meters: 10))

        let result = north.dotProduct(east)

        XCTAssertEqual(result.meters, 0, accuracy: 0.0001)
    }

    func testDotProduct_Parallel() {
        // Parallel vectors: dot = m1 * m2
        let v1 = PolarVector(bearing: .init(degrees: 45), magnitude: .init(meters: 3))
        let v2 = PolarVector(bearing: .init(degrees: 45), magnitude: .init(meters: 4))

        let result = v1.dotProduct(v2)

        XCTAssertEqual(result.meters, 12, accuracy: 0.0001)
    }

    func testDotProduct_Opposite() {
        // Opposite vectors: dot = -m1 * m2
        let north = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 5))
        let south = PolarVector(bearing: .init(degrees: 180), magnitude: .init(meters: 4))

        let result = north.dotProduct(south)

        XCTAssertEqual(result.meters, -20, accuracy: 0.0001)
    }

    func testDotProduct_45Degrees() {
        // 45° apart: dot = m1 * m2 * cos(45°)
        let v1 = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 10))
        let v2 = PolarVector(bearing: .init(degrees: 45), magnitude: .init(meters: 10))

        let result = v1.dotProduct(v2)

        XCTAssertEqual(result.meters, 70.71, accuracy: 0.01)  // 100 * cos(45°)
    }

    func testAngleBetween_Perpendicular() {
        let north = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 10))
        let east = PolarVector(bearing: .init(degrees: 90), magnitude: .init(meters: 10))

        let result = north.angleBetween(east)

        XCTAssertEqual(result.degrees, 90, accuracy: 0.0001)
    }

    func testAngleBetween_Parallel() {
        let v1 = PolarVector(bearing: .init(degrees: 45), magnitude: .init(meters: 5))
        let v2 = PolarVector(bearing: .init(degrees: 45), magnitude: .init(meters: 10))

        let result = v1.angleBetween(v2)

        XCTAssertEqual(result.degrees, 0, accuracy: 0.0001)
    }

    func testAngleBetween_Opposite() {
        let north = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 10))
        let south = PolarVector(bearing: .init(degrees: 180), magnitude: .init(meters: 10))

        let result = north.angleBetween(south)

        XCTAssertEqual(result.degrees, 180, accuracy: 0.0001)
    }

    func testAngleBetween_45Degrees() {
        let v1 = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 10))
        let v2 = PolarVector(bearing: .init(degrees: 45), magnitude: .init(meters: 10))

        let result = v1.angleBetween(v2)

        XCTAssertEqual(result.degrees, 45, accuracy: 0.0001)
    }

    func testAngleBetween_AcrossNorth() {
        // 350° and 10° are 20° apart
        let v1 = PolarVector(bearing: .init(degrees: 350), magnitude: .init(meters: 10))
        let v2 = PolarVector(bearing: .init(degrees: 10), magnitude: .init(meters: 10))

        let result = v1.angleBetween(v2)

        XCTAssertEqual(result.degrees, 20, accuracy: 0.0001)
    }

    /// `angleBetween` now returns 0 for a zero-magnitude vector, matching
    /// `Vector.angle(to:)`'s existing convention, instead of NaN.
    func testAngleBetween_ZeroMagnitude() {
        let v1 = PolarVector(bearing: .init(degrees: 0), magnitude: .init(meters: 0))
        let v2 = PolarVector(bearing: .init(degrees: 90), magnitude: .init(meters: 10))

        let result = v1.angleBetween(v2)

        XCTAssertEqual(result.value, 0)
    }
}
