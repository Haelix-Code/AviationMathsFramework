import XCTest
@testable import AviationMaths

final class PolarVectorTests: XCTestCase {

    func testVector2DConversion_Length() {
        let polar = DistanceVector(angle: .init(value: 0, unit: .radians),
                                   magnitude: .init(meters: 10))
        let vector = polar.vector2D
        XCTAssertEqual(vector.x.meters, 0, accuracy: 1e-10)
        XCTAssertEqual(vector.y.meters, 10, accuracy: 1e-10)
    }

    func testVector2DConversion_Speed() {
        let polar = SpeedVector(angle: .init(value: .pi/2, unit: .radians),
                                magnitude: .init(value: 2, unit: .metersPerSecond))
        let vector = polar.vector2D
        XCTAssertEqual(vector.x.meters, 2, accuracy: 1e-10)
        XCTAssertEqual(vector.y.meters, 0, accuracy: 1e-10)
    }

    func testVector2DConversion_Quadrants() {
        let mag = Measurement<UnitLength>(meters: 1)

        // 45° → x = sin(45°), y = cos(45°)
        var v = DistanceVector(angle: .init(value: .pi/4, unit: .radians),
                               magnitude: mag).vector2D
        XCTAssertEqual(v.x.meters, sqrt(0.5), accuracy: 1e-10)
        XCTAssertEqual(v.y.meters, sqrt(0.5), accuracy: 1e-10)

        // 135°
        v = DistanceVector(angle: .init(value: 3 * .pi/4, unit: .radians),
                           magnitude: mag).vector2D
        XCTAssertEqual(v.x.meters, sqrt(0.5), accuracy: 1e-10)
        XCTAssertEqual(v.y.meters, -sqrt(0.5), accuracy: 1e-10)

        // 225°
        v = DistanceVector(angle: .init(value: 5 * .pi/4, unit: .radians),
                           magnitude: mag).vector2D
        XCTAssertEqual(v.x.meters, -sqrt(0.5), accuracy: 1e-10)
        XCTAssertEqual(v.y.meters, -sqrt(0.5), accuracy: 1e-10)

        // 315°
        v = DistanceVector(angle: .init(value: 7 * .pi/4, unit: .radians),
                           magnitude: mag).vector2D
        XCTAssertEqual(v.x.meters, -sqrt(0.5), accuracy: 1e-10)
        XCTAssertEqual(v.y.meters, sqrt(0.5), accuracy: 1e-10)
    }

    func testVector2DConversion_ZeroMagnitude() {
        let polar = DistanceVector(angle: .init(value: 1.234, unit: .radians),
                                   magnitude: .init(meters: 0))
        let v = polar.vector2D
        XCTAssertEqual(v.x.meters, 0, accuracy: 1e-10)
        XCTAssertEqual(v.y.meters, 0, accuracy: 1e-10)
    }
}
