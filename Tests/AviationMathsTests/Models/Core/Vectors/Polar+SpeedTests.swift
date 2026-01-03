import XCTest
@testable import AviationMaths
import Foundation

final class PolarVectorSpeedTests: XCTestCase {

    func testSpeedProperty() {
        let v = SpeedPolar(bearing: .init(degrees: 45), magnitude: .init(knots: 100))

        XCTAssertEqual(v.speed.knots, 100, accuracy: 0.0001)
    }

    func testReciprocalBearing() {
        let v = SpeedPolar(bearing: .init(degrees: 45), magnitude: .init(knots: 100))

        XCTAssertEqual(v.reciprocalBearing.degrees, 225, accuracy: 0.0001)
    }

    func testReciprocalBearing_Wrapping() {
        let v = SpeedPolar(bearing: .init(degrees: 270), magnitude: .init(knots: 50))

        XCTAssertEqual(v.reciprocalBearing.degrees, 90, accuracy: 0.0001)
    }

    func testRoundTrip_AllCardinals() {
        let testCases: [Double] = [0, 90, 180, 270]

        for bearing in testCases {
            let original = SpeedPolar(bearing: .init(degrees: bearing), magnitude: .init(knots: 100))
            let cart = original.asCartesianVector
            let recovered = cart.asPolar

            XCTAssertEqual(recovered.bearing.degrees, bearing, accuracy: 0.0001,
                          "Failed round-trip for bearing \(bearing)")
            XCTAssertEqual(recovered.magnitude.knots, 100, accuracy: 0.0001)
        }
    }

    func testRoundTrip_IntermediateBearings() {
        let bearings: [Double] = [30, 60, 120, 150, 210, 240, 300, 330]

        for bearing in bearings {
            let original = SpeedPolar(bearing: .init(degrees: bearing), magnitude: .init(knots: 50))
            let cart = original.asCartesianVector
            let recovered = cart.asPolar

            XCTAssertEqual(recovered.bearing.degrees, bearing, accuracy: 0.0001,
                          "Failed round-trip for bearing \(bearing)")
            XCTAssertEqual(recovered.magnitude.knots, 50, accuracy: 0.0001)
        }
    }

    func testSpeedVectorAddition() {
        // Aircraft velocity: 100kt North
        // Wind velocity: 20kt from West (pushing East)
        let aircraft = SpeedPolar(bearing: .init(degrees: 0), magnitude: .init(knots: 100))
        let wind = SpeedPolar(bearing: .init(degrees: 90), magnitude: .init(knots: 20))

        let groundspeed = aircraft.adding(wind)

        // Result: √(100² + 20²) = 102kt, bearing ~11° (drifting right)
        XCTAssertEqual(groundspeed.magnitude.knots, 102.0, accuracy: 0.1)
        XCTAssertEqual(groundspeed.bearing.degrees, 11.31, accuracy: 0.01)
    }

    func testSpeedVectorSubtraction() {
        // If groundspeed is 120kt at 010°, and wind is 20kt toward 090°,
        // what was the aircraft velocity?
        let groundspeed = SpeedPolar(bearing: .init(degrees: 10), magnitude: .init(knots: 120))
        let wind = SpeedPolar(bearing: .init(degrees: 90), magnitude: .init(knots: 20))

        let aircraft = groundspeed.subtracting(wind)

        // Aircraft was heading more northerly to compensate for eastward drift
        XCTAssertLessThan(aircraft.bearing.degrees, 10)
    }

    func testKnotsUnit() {
        let v = SpeedPolar(bearing: .init(degrees: 0), magnitude: .init(knots: 250))

        XCTAssertEqual(v.magnitude.knots, 250, accuracy: 0.0001)
        XCTAssertEqual(v.magnitude.mps, 128.61, accuracy: 0.01)  // 250 * 0.514444
    }
}
