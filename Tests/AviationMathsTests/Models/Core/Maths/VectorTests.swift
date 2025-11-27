import XCTest
@testable import AviationMaths

final class Vector2DTests: XCTestCase {

    func testInitAndLength() {
        let v = Vector2D(x: .init(meters: 3), y: .init(meters: 4))
        XCTAssertEqual(v.length.converted(to: .meters).value, 5, accuracy: 1e-10)
    }

    func testInitWithVectorsArray() {
        let v1 = Vector2D(x: .init(meters: 1), y: .init(meters: 2))
        let v2 = Vector2D(x: .init(meters: 3), y: .init(meters: 4))
        let sum = Vector2D(vectors: [v1, v2])
        XCTAssertEqual(sum.x.meters, 4)
        XCTAssertEqual(sum.y.meters, 6)
    }

    func testPolarCoordinate() {
        let v = Vector2D(x: .init(meters: 0), y: .init(meters: 1))
        let polar = v.polarCoordinate
        XCTAssertEqual(polar.magnitude.converted(to: .meters).value, 1, accuracy: 1e-10)
        XCTAssertEqual(polar.angle.converted(to: .degrees).value, 90, accuracy: 1e-10)
    }

    func testAngleBetweenVectors() {
        let v1 = Vector2D(x: .init(meters: 1), y: .init(meters: 0))
        let v2 = Vector2D(x: .init(meters: 0), y: .init(meters: 1))
        let angle = v1.angleBetween(vector2D: v2)
        XCTAssertEqual(angle.converted(to: .degrees).value, 90, accuracy: 1e-10)
    }

    func testAngleQuadrants() {
        // Q1: x > 0, y > 0 → 45°
        var v = Vector2D(x: .init(meters: 1), y: .init(meters: 1))
        XCTAssertEqual(v.polarCoordinate.angle.converted(to: .degrees).value, 45, accuracy: 1e-10)

        // Q2: x < 0, y > 0 → 135°
        v = Vector2D(x: .init(meters: -1), y: .init(meters: 1))
        XCTAssertEqual(v.polarCoordinate.angle.converted(to: .degrees).value, 135, accuracy: 1e-10)

        // Q3: x < 0, y < 0 → -135° or 225°
        v = Vector2D(x: .init(meters: -1), y: .init(meters: -1))
        XCTAssertEqual(v.polarCoordinate.angle.converted(to: .degrees).value, -135, accuracy: 1e-10)

        // Q4: x > 0, y < 0 → -45°
        v = Vector2D(x: .init(meters: 1), y: .init(meters: -1))
        XCTAssertEqual(v.polarCoordinate.angle.converted(to: .degrees).value, -45, accuracy: 1e-10)
    }

    func testAngleBetweenColinearOpposite() {
        let v1 = Vector2D(x: .init(meters: 1), y: .init(meters: 0))
        let v2 = Vector2D(x: .init(meters: -1), y: .init(meters: 0))
        let angle = v1.angleBetween(vector2D: v2)
        XCTAssertEqual(angle.converted(to: .degrees).value, 180, accuracy: 1e-10)
    }
}
