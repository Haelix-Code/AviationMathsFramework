import XCTest
@testable import AviationMaths

final class WindTests: XCTestCase {

    func testWindConvenienceInit() {
        let w = Wind(feet: 5000, knots: 20, bearing: 270)
        XCTAssertEqual(w.altitude.feet, 5000)
        XCTAssertEqual(w.speed.knots, 20, accuracy: 0.0001)
        XCTAssertEqual(w.fromDirection.degrees, 270)
    }

    func testToDirectionWraps() {
        let w = Wind(altitude: .init(meters: 0),
                     fromDirection: .init(degrees: 370),
                     speed: .init(mps: 10))
        XCTAssertEqual(w.toDirection.degrees, 190, accuracy: 0.0001)
    }

    func testWindVector() {
        // 90° wind at 10 m/s → from east → blowing toward west
        let w = Wind(altitude: .init(meters: 0),
                     fromDirection: .init(degrees: 90),
                     speed: .init(mps: 10))

        // Math convention:
        // toDirection = 90 + 180 = 270 → blowing west
        // Math polar: 0 rad along +x, CCW → 270° → angle = -pi/2
        let v = w.vector
        XCTAssertEqual(v.x.mps, -10, accuracy: 0.0001)
        XCTAssertEqual(v.y.mps, 0, accuracy: 0.0001)
    }
    
    func testWindPolar() {
        let w = Wind(
            altitude: .init(meters: 0),
            fromDirection: .init(degrees: 90),
            speed: .init(mps: 10)
        )

        let p = w.polar
        XCTAssertEqual(p.magnitude.value, 10)
        XCTAssertEqual(p.angle.converted(to: .radians).value, -3.14159, accuracy: 0.0001) // -pi/2
    }
}
