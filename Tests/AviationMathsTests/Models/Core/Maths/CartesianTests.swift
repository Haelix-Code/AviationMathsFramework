import XCTest
@testable import AviationMaths

final class CartesianVectorTests: XCTestCase {

    func testInitAndMagnitude() {
        // 3-4-5 triangle
        let v = CartesianVector(x: .init(meters: 3), y: .init(meters: 4))
        XCTAssertEqual(v.magnitude.meters, 5, accuracy: 1e-10)
    }

    func testInitWithVectorsArray() {
        let v1 = CartesianVector(x: .init(meters: 1), y: .init(meters: 2))
        let v2 = CartesianVector(x: .init(meters: 3), y: .init(meters: 4))
        let sum = CartesianVector(vectors: [v1, v2])
        XCTAssertEqual(sum.x.meters, 4)
        XCTAssertEqual(sum.y.meters, 6)
    }

    func testZeroVector() {
        let v = CartesianVector(x: .init(meters: 0), y: .init(meters: 0))
        XCTAssertEqual(v.magnitude.value, 0, accuracy: 1e-10)
        // Bearing of zero vector is technically undefined, but atan2(0,0) = 0
        XCTAssertEqual(v.bearing.degrees, 0, accuracy: 1e-10)
    }

    func testBearing_North() {
        // Pure North: x=0, y=+1 → bearing 0°
        let v = CartesianVector(x: .init(meters: 0), y: .init(meters: 1))
        XCTAssertEqual(v.bearing.degrees, 0, accuracy: 1e-10)
        XCTAssertEqual(v.magnitude.meters, 1, accuracy: 1e-10)
    }

    func testBearing_East() {
        // Pure East: x=+1, y=0 → bearing 90°
        let v = CartesianVector(x: .init(meters: 1), y: .init(meters: 0))
        XCTAssertEqual(v.bearing.degrees, 90, accuracy: 1e-10)
    }

    func testBearing_South() {
        // Pure South: x=0, y=-1 → bearing 180°
        let v = CartesianVector(x: .init(meters: 0), y: .init(meters: -1))
        XCTAssertEqual(v.bearing.degrees, 180, accuracy: 1e-10)
    }

    func testBearing_West() {
        // Pure West: x=-1, y=0 → bearing 270°
        let v = CartesianVector(x: .init(meters: -1), y: .init(meters: 0))
        XCTAssertEqual(v.bearing.degrees, 270, accuracy: 1e-10)
    }

    func testBearing_NorthEast() {
        // Q1: x > 0, y > 0 → bearing 45° (NE)
        let v = CartesianVector(x: .init(meters: 1), y: .init(meters: 1))
        XCTAssertEqual(v.bearing.degrees, 45, accuracy: 1e-10)
    }

    func testBearing_SouthEast() {
        // Q2: x > 0, y < 0 → bearing 135° (SE)
        let v = CartesianVector(x: .init(meters: 1), y: .init(meters: -1))
        XCTAssertEqual(v.bearing.degrees, 135, accuracy: 1e-10)
    }

    func testBearing_SouthWest() {
        // Q3: x < 0, y < 0 → bearing 225° (SW)
        let v = CartesianVector(x: .init(meters: -1), y: .init(meters: -1))
        XCTAssertEqual(v.bearing.degrees, 225, accuracy: 1e-10)
    }

    func testBearing_NorthWest() {
        // Q4: x < 0, y > 0 → bearing 315° (NW)
        let v = CartesianVector(x: .init(meters: -1), y: .init(meters: 1))
        XCTAssertEqual(v.bearing.degrees, 315, accuracy: 1e-10)
    }

    func testPolarRoundTrip_AllCardinals() {
        struct TestCase {
            let bearing: Double
            let expectedX: Double
            let expectedY: Double
        }

        let testCases: [TestCase] = [
            TestCase(bearing: 0, expectedX: 0, expectedY: 1),    // North
            TestCase(bearing: 90, expectedX: 1, expectedY: 0),   // East
            TestCase(bearing: 180, expectedX: 0, expectedY: -1), // South
            TestCase(bearing: 270, expectedX: -1, expectedY: 0)  // West
        ]

        for tc in testCases {
            // Create Polar Vector
            let polar = PolarVector(bearing: .init(degrees: tc.bearing),
                                    magnitude: Measurement<UnitLength>(meters: 1))

            // Convert to Cartesian coordinates
            let cart = polar.asCartesianVector

            // Test conversion to Cartesian
            XCTAssertEqual(cart.x.meters, tc.expectedX, accuracy: 1e-10,
                          "Failed x for bearing \(tc.bearing)")
            XCTAssertEqual(cart.y.meters, tc.expectedY, accuracy: 1e-10,
                          "Failed y for bearing \(tc.bearing)")

            // Test round-trip conversion back to Polar
            let recovered = cart.asPolar
            XCTAssertEqual(recovered.bearing.degrees, tc.bearing, accuracy: 1e-10,
                          "Failed round-trip for bearing \(tc.bearing)")
        }
    }

    func testPolarRoundTrip_IntermediateBearings() {
        let bearings: [Double] = [30, 60, 120, 150, 210, 240, 300, 330]

        for bearing in bearings {
            let polar = PolarVector(bearing: .init(degrees: bearing),
                                   magnitude: Measurement<UnitLength>(meters: 10))
            let cart = polar.asCartesianVector
            let recovered = cart.asPolar

            XCTAssertEqual(recovered.bearing.degrees, bearing, accuracy: 1e-10,
                          "Failed round-trip for bearing \(bearing)")
            XCTAssertEqual(recovered.magnitude.meters, 10, accuracy: 1e-10)
        }
    }

    func testAngleBetween_Perpendicular() {
        let north = CartesianVector(x: .init(meters: 0), y: .init(meters: 1))
        let east = CartesianVector(x: .init(meters: 1), y: .init(meters: 0))
        let angle = north.angle(between: east)
        XCTAssertEqual(angle.degrees, 90, accuracy: 1e-10)
    }

    func testAngleBetween_Parallel() {
        let v1 = CartesianVector(x: .init(meters: 1), y: .init(meters: 0))
        let v2 = CartesianVector(x: .init(meters: 2), y: .init(meters: 0))
        let angle = v1.angle(between: v2)
        XCTAssertEqual(angle.degrees, 0, accuracy: 1e-10)
    }

    func testAngleBetween_Opposite() {
        let v1 = CartesianVector(x: .init(meters: 1), y: .init(meters: 0))
        let v2 = CartesianVector(x: .init(meters: -1), y: .init(meters: 0))
        let angle = v1.angle(between: v2)
        XCTAssertEqual(angle.degrees, 180, accuracy: 1e-10)
    }

    func testSpeedVector() {
        let speedVector = SpeedCartesianVector(
            x: .init(knots: 30), // 30kt East component
            y: .init(knots: 40) // 40kt North component
        )
        XCTAssertEqual(speedVector.magnitude.knots, 50, accuracy: 1e-4)

        // Bearing should be ~37° (more North than East)
        XCTAssertEqual(speedVector.bearing.degrees, 36.87, accuracy: 0.01)
    }
}
