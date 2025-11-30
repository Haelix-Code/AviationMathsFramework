import XCTest
@testable import AviationMaths

final class PolarVectorTests: XCTestCase {

    func testCartesianConversion_Length() {
        let polar = LengthPolar(angle: .init(value: 0, unit: .radians),
                                   magnitude: .init(meters: 10))
        let vector = polar.asCartesianVector
        XCTAssertEqual(vector.x.meters, 10, accuracy: 1e-10)
        XCTAssertEqual(vector.y.meters, 0, accuracy: 1e-10)
    }

    func testCartesianConversion_Speed() {
        let polar = SpeedPolar(angle: .init(value: .pi/2, unit: .radians),
                                magnitude: .init(value: 2, unit: .metersPerSecond))
        let vector = polar.asCartesianVector
        XCTAssertEqual(vector.x.mps, 0, accuracy: 1e-10)
        XCTAssertEqual(vector.y.mps, 2, accuracy: 1e-10)
    }

    func testCartesianConversion_Quadrants() {
        let mag = Measurement<UnitLength>(meters: 1)

        // 45° → Q1
        var v = LengthPolar(angle: .init(value: .pi/4, unit: .radians),
                            magnitude: mag).asCartesianVector
        XCTAssertEqual(v.x.meters, sqrt(0.5), accuracy: 1e-10)
        XCTAssertEqual(v.y.meters, sqrt(0.5), accuracy: 1e-10)

        // 135° → Q2
        v = LengthPolar(angle: .init(value: 3 * .pi/4, unit: .radians),
                        magnitude: mag).asCartesianVector
        XCTAssertEqual(v.x.meters, -sqrt(0.5), accuracy: 1e-10)
        XCTAssertEqual(v.y.meters, sqrt(0.5), accuracy: 1e-10)

        // 225° → Q3
        v = LengthPolar(angle: .init(value: 5 * .pi/4, unit: .radians),
                        magnitude: mag).asCartesianVector
        XCTAssertEqual(v.x.meters, -sqrt(0.5), accuracy: 1e-10)
        XCTAssertEqual(v.y.meters, -sqrt(0.5), accuracy: 1e-10)

        // 315° → Q4
        v = LengthPolar(angle: .init(value: 7 * .pi/4, unit: .radians),
                        magnitude: mag).asCartesianVector
        XCTAssertEqual(v.x.meters, sqrt(0.5), accuracy: 1e-10)
        XCTAssertEqual(v.y.meters, -sqrt(0.5), accuracy: 1e-10)
    }

    func testCartesianConversion_ZeroMagnitude() {
        let polar = LengthPolar(angle: .init(value: 1.234, unit: .radians),
                                   magnitude: .init(meters: 0))
        let v = polar.asCartesianVector
        XCTAssertEqual(v.x.meters, 0, accuracy: 1e-10)
        XCTAssertEqual(v.y.meters, 0, accuracy: 1e-10)
    }
}
