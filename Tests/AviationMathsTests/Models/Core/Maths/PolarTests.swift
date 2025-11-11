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

    func testDescription() {
        let polar = DistanceVector(angle: .init(value: .pi/4, unit: .radians),
                                   magnitude: .init(meters: 1000))
        let desc = polar.description()
        XCTAssertTrue(desc.contains("45.0"))
    }

    func testDescription_NaNAngle() {
        let polar = DistanceVector(angle: .init(value: .nan, unit: .degrees),
                                   magnitude: .init(meters: 10))
        XCTAssertEqual(polar.description(), "--")
    }
}
