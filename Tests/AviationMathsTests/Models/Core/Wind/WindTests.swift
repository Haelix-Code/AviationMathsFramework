import XCTest
@testable import AviationMaths

final class WindTests: XCTestCase {

    func testWindConvenienceInit() {
        let w = Wind(feet: 5000, knots: 20, fromDirection: 270)
        XCTAssertEqual(w.altitude.feet, 5000)
        XCTAssertEqual(w.speed.knots, 20, accuracy: 0.0001)
        XCTAssertEqual(w.fromDirection.degrees, 270)
    }

    func testToDirection() {
        let w = Wind(feet: 0, knots: 10, fromDirection: 90)
        // Wind from East blows toward West
        XCTAssertEqual(w.toDirection.degrees, 270, accuracy: 0.0001)
    }

    func testToDirection_Wraps() {
        let w = Wind(feet: 0, knots: 10, fromDirection: 270)
        // Wind from West blows toward East
        XCTAssertEqual(w.toDirection.degrees, 90, accuracy: 0.0001)
    }

    func testWindVector_FromNorth() {
        // Wind FROM North (0°) → blows TOWARD South (180°)
        // Vector should point South: x=0, y=-speed
        let w = Wind(feet: 0, knots: 10, fromDirection: 0)
        let v = w.vector

        XCTAssertEqual(v.x.knots, 0, accuracy: 0.0001)
        XCTAssertEqual(v.y.knots, -10, accuracy: 0.0001)
    }

    func testWindVector_FromEast() {
        // Wind FROM East (90°) → blows TOWARD West (270°)
        // Vector should point West: x=-speed, y=0
        let w = Wind(feet: 0, knots: 10, fromDirection: 90)
        let v = w.vector

        XCTAssertEqual(v.x.knots, -10, accuracy: 0.0001)
        XCTAssertEqual(v.y.knots, 0, accuracy: 0.0001)
    }

    func testWindVector_FromSouth() {
        // Wind FROM South (180°) → blows TOWARD North (0°)
        // Vector should point North: x=0, y=+speed
        let w = Wind(feet: 0, knots: 10, fromDirection: 180)
        let v = w.vector

        XCTAssertEqual(v.x.knots, 0, accuracy: 0.0001)
        XCTAssertEqual(v.y.knots, 10, accuracy: 0.0001)
    }

    func testWindVector_FromWest() {
        // Wind FROM West (270°) → blows TOWARD East (90°)
        // Vector should point East: x=+speed, y=0
        let w = Wind(feet: 0, knots: 10, fromDirection: 270)
        let v = w.vector

        XCTAssertEqual(v.x.knots, 10, accuracy: 0.0001)
        XCTAssertEqual(v.y.knots, 0, accuracy: 0.0001)
    }

    func testWindVector_FromSouthWest() {
        // Wind FROM SW (225°) → blows TOWARD NE (45°)
        let w = Wind(feet: 0, knots: 10, fromDirection: 225)
        let v = w.vector

        // At 45°: x = 10*sin(45) = 7.07, y = 10*cos(45) = 7.07
        XCTAssertEqual(v.x.knots, 7.071, accuracy: 0.001)
        XCTAssertEqual(v.y.knots, 7.071, accuracy: 0.001)
    }

    func testWindPolar() {
        let w = Wind(feet: 0, knots: 20, fromDirection: 90)
        let p = w.polar

        XCTAssertEqual(p.magnitude.knots, 20)
        XCTAssertEqual(p.bearing.degrees, 270, accuracy: 0.0001) // Toward West
    }

    func testWindVectorRoundTrip() {
        let w = Wind(feet: 5000, knots: 35, fromDirection: 210)
        let vector = w.vector
        let polar = vector.asPolar

        XCTAssertEqual(polar.magnitude.knots, 35, accuracy: 0.001)
        XCTAssertEqual(polar.bearing.degrees, w.toDirection.degrees, accuracy: 0.001)
    }
}
