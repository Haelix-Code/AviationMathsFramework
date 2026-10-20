import XCTest
@testable import AviationMaths

final class PolarVectorTests: XCTestCase {

    func testCartesianConversion_North() {
        let polar = LengthPolar(bearing: .init(degrees: 0), magnitude: .init(meters: 10))
        let cart = polar.asCartesianVector
        XCTAssertEqual(cart.x.meters, 0, accuracy: 1e-10)
        XCTAssertEqual(cart.y.meters, 10, accuracy: 1e-10)
    }

    func testCartesianConversion_East() {
        let polar = LengthPolar(bearing: .init(degrees: 90), magnitude: .init(meters: 10))
        let cart = polar.asCartesianVector
        XCTAssertEqual(cart.x.meters, 10, accuracy: 1e-10)
        XCTAssertEqual(cart.y.meters, 0, accuracy: 1e-10)
    }

    func testCartesianConversion_South() {
        let polar = LengthPolar(bearing: .init(degrees: 180), magnitude: .init(meters: 10))
        let cart = polar.asCartesianVector
        XCTAssertEqual(cart.x.meters, 0, accuracy: 1e-10)
        XCTAssertEqual(cart.y.meters, -10, accuracy: 1e-10)
    }

    func testCartesianConversion_West() {
        let polar = LengthPolar(bearing: .init(degrees: 270), magnitude: .init(meters: 10))
        let cart = polar.asCartesianVector
        XCTAssertEqual(cart.x.meters, -10, accuracy: 1e-10)
        XCTAssertEqual(cart.y.meters, 0, accuracy: 1e-10)
    }

    func testCartesianConversion_NorthEast() {
        // 45° → equal x and y, both positive
        let polar = LengthPolar(bearing: .init(degrees: 45), magnitude: .init(meters: 1))
        let cart = polar.asCartesianVector
        XCTAssertEqual(cart.x.meters, sqrt(0.5), accuracy: 1e-10)
        XCTAssertEqual(cart.y.meters, sqrt(0.5), accuracy: 1e-10)
    }

    func testCartesianConversion_SouthEast() {
        // 135° → positive x, negative y
        let polar = LengthPolar(bearing: .init(degrees: 135), magnitude: .init(meters: 1))
        let cart = polar.asCartesianVector
        XCTAssertEqual(cart.x.meters, sqrt(0.5), accuracy: 1e-10)
        XCTAssertEqual(cart.y.meters, -sqrt(0.5), accuracy: 1e-10)
    }

    func testCartesianConversion_SouthWest() {
        // 225° → negative x, negative y
        let polar = LengthPolar(bearing: .init(degrees: 225), magnitude: .init(meters: 1))
        let cart = polar.asCartesianVector
        XCTAssertEqual(cart.x.meters, -sqrt(0.5), accuracy: 1e-10)
        XCTAssertEqual(cart.y.meters, -sqrt(0.5), accuracy: 1e-10)
    }

    func testCartesianConversion_NorthWest() {
        // 315° → negative x, positive y
        let polar = LengthPolar(bearing: .init(degrees: 315), magnitude: .init(meters: 1))
        let cart = polar.asCartesianVector
        XCTAssertEqual(cart.x.meters, -sqrt(0.5), accuracy: 1e-10)
        XCTAssertEqual(cart.y.meters, sqrt(0.5), accuracy: 1e-10)
    }

    func testCartesianConversion_ZeroMagnitude() {
        let polar = LengthPolar(bearing: .init(degrees: 123), magnitude: .init(meters: 0))
        let cart = polar.asCartesianVector
        XCTAssertEqual(cart.x.meters, 0, accuracy: 1e-10)
        XCTAssertEqual(cart.y.meters, 0, accuracy: 1e-10)
    }

    func testBearingNormalization() {
        // 450° should normalize to 90°
        let polar = LengthPolar(bearing: .init(degrees: 450), magnitude: .init(meters: 1))
        XCTAssertEqual(polar.bearing.degrees, 90, accuracy: 1e-10)

        // -90° should normalize to 270°
        let polar2 = LengthPolar(bearing: .init(degrees: -90), magnitude: .init(meters: 1))
        XCTAssertEqual(polar2.bearing.degrees, 270, accuracy: 1e-10)
    }

    func testSpeedPolar() {
        let polar = SpeedPolar(bearing: .init(degrees: 45), magnitude: .init(knots: 100))
        let cart = polar.asCartesianVector

        // 45° at 100kt → ~70.7kt East, ~70.7kt North
        XCTAssertEqual(cart.x.knots, 70.71, accuracy: 0.01)
        XCTAssertEqual(cart.y.knots, 70.71, accuracy: 0.01)
    }

    func testCodable_RoundTrip() throws {
        let polar = LengthPolar(bearing: .init(degrees: 135), magnitude: .init(feet: 1000))

        let data = try JSONEncoder().encode(polar)
        let decoded = try JSONDecoder().decode(LengthPolar.self, from: data)

        XCTAssertEqual(decoded.bearing.degrees, 135, accuracy: 1e-9)
        XCTAssertEqual(decoded.magnitude.feet, 1000, accuracy: 1e-9)
    }
}
