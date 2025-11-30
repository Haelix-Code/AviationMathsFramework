import XCTest
@testable import AviationMaths

final class CartesianVectorTests: XCTestCase {

    func testInitAndLength() {
        let v = CartesianVector(x: .init(meters: 3), y: .init(meters: 4))
        XCTAssertEqual(v.length.converted(to: .meters).value, 5, accuracy: 1e-10)
    }

    func testInitWithVectorsArray() {
        let v1 = CartesianVector(x: .init(meters: 1), y: .init(meters: 2))
        let v2 = CartesianVector(x: .init(meters: 3), y: .init(meters: 4))
        let sum = CartesianVector(vectors: [v1, v2])
        XCTAssertEqual(sum.x.meters, 4)
        XCTAssertEqual(sum.y.meters, 6)
    }

    func testPolarCoordinate() {
        let v = CartesianVector(x: .init(meters: 0), y: .init(meters: 1))
        let polar = v.asPolar
        XCTAssertEqual(polar.magnitude.converted(to: .meters).value, 1, accuracy: 1e-10)
        XCTAssertEqual(polar.angle.converted(to: .degrees).value, 90, accuracy: 1e-10)
    }

    func testAngleBetweenVectors() {
        let v1 = CartesianVector(x: .init(meters: 1), y: .init(meters: 0))
        let v2 = CartesianVector(x: .init(meters: 0), y: .init(meters: 1))
        let angle = v1.angle(between: v2)
        XCTAssertEqual(angle.converted(to: .degrees).value, 90, accuracy: 1e-10)
    }

    func testAngleQuadrants() {
        // Q1: x > 0, y > 0 → 45°
        var v = CartesianVector(x: .init(meters: 1), y: .init(meters: 1))
        XCTAssertEqual(v.asPolar.angle.converted(to: .degrees).value, 45, accuracy: 1e-10)

        // Q2: x < 0, y > 0 → 135°
        v = CartesianVector(x: .init(meters: -1), y: .init(meters: 1))
        XCTAssertEqual(v.asPolar.angle.converted(to: .degrees).value, 135, accuracy: 1e-10)

        // Q3: x < 0, y < 0 → -135° or 225°
        v = CartesianVector(x: .init(meters: -1), y: .init(meters: -1))
        XCTAssertEqual(v.asPolar.angle.converted(to: .degrees).value, -135, accuracy: 1e-10)

        // Q4: x > 0, y < 0 → -45°
        v = CartesianVector(x: .init(meters: 1), y: .init(meters: -1))
        XCTAssertEqual(v.asPolar.angle.converted(to: .degrees).value, -45, accuracy: 1e-10)
    }

    func testAngleBetweenColinearOpposite() {
        let v1 = CartesianVector(x: .init(meters: 1), y: .init(meters: 0))
        let v2 = CartesianVector(x: .init(meters: -1), y: .init(meters: 0))
        let angle = v1.angle(between: v2)
        XCTAssertEqual(angle.converted(to: .degrees).value, 180, accuracy: 1e-10)
    }
    
    func testZeroLengthVector() {
        let v = CartesianVector(x: .init(meters: 0), y: .init(meters: 0))
        XCTAssertEqual(v.magnitude.value, 0, accuracy: 1e-10)
        XCTAssertEqual(v.asPolar.angle.value, 0, accuracy: 1e-10)  // Should be fine or undefined
    }
    
    func testEdgeCaseAngles() {
        // Positive X-axis, should be 0 degrees
        let v1 = CartesianVector(x: .init(meters: 1), y: .init(meters: 0))
        XCTAssertEqual(v1.asPolar.angle.converted(to: .degrees).value, 0, accuracy: 1e-10)

        // Positive Y-axis, should be 90 degrees
        let v2 = CartesianVector(x: .init(meters: 0), y: .init(meters: 1))
        XCTAssertEqual(v2.asPolar.angle.converted(to: .degrees).value, 90, accuracy: 1e-10)

        // Negative X-axis, should be 180 degrees
        let v3 = CartesianVector(x: .init(meters: -1), y: .init(meters: 0))
        XCTAssertEqual(v3.asPolar.angle.converted(to: .degrees).value, 180, accuracy: 1e-10)

        // Negative Y-axis, should be -90 degrees
        let v4 = CartesianVector(x: .init(meters: 0), y: .init(meters: -1))
        XCTAssertEqual(v4.asPolar.angle.converted(to: .degrees).value, -90, accuracy: 1e-10)
    }
    
    func testAngleBetweenParallelVectors() {
        let v1 = CartesianVector(x: .init(meters: 1), y: .init(meters: 0))
        let v2 = CartesianVector(x: .init(meters: 2), y: .init(meters: 0))
        let angle = v1.angle(between: v2)
        XCTAssertEqual(angle.converted(to: .degrees).value, 0, accuracy: 1e-10)  // Parallel, 0 degrees
    }

    func testAngleBetweenAntiparallelVectors() {
        let v1 = CartesianVector(x: .init(meters: 1), y: .init(meters: 0))
        let v2 = CartesianVector(x: .init(meters: -1), y: .init(meters: 0))
        let angle = v1.angle(between: v2)
        XCTAssertEqual(angle.converted(to: .degrees).value, 180, accuracy: 1e-10)  // Antiparallel, 180 degrees
    }
    
    func testWithSpeed() {
        let speedVector = CartesianVector<UnitSpeed>(x: .init(mps: 10), y: .init(mps: 20))
        XCTAssertEqual(speedVector.magnitude.converted(to: .metersPerSecond).value, 22.3607, accuracy: 1e-4)
    }
}
