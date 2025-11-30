import XCTest
import Foundation
@testable import AviationMaths

final class PolarVectorLengthTests: XCTestCase {

    func testLengthProperty() {
        let v = LengthPolar(bearing: .init(degrees: 45), magnitude: .init(meters: 5))

        XCTAssertEqual(v.length.meters, 5, accuracy: 0.0001)
        XCTAssertEqual(v.length.unit, UnitLength.meters)
    }

    func testMagnitudeAndLengthAreEquivalent() {
        let v = LengthPolar(bearing: .init(degrees: 90), magnitude: .init(meters: 100))

        XCTAssertEqual(v.length.meters, v.magnitude.meters, accuracy: 0.0001)
    }

    func testRoundTrip_AllCardinals() {
        let bearings: [Double] = [0, 90, 180, 270]

        for bearing in bearings {
            let original = LengthPolar(bearing: .init(degrees: bearing), magnitude: .init(meters: 100))
            let cart = original.lengthCartesianVector
            let recovered = cart.asPolar

            XCTAssertEqual(recovered.bearing.degrees, bearing, accuracy: 0.0001,
                          "Failed round-trip for bearing \(bearing)")
            XCTAssertEqual(recovered.magnitude.meters, 100, accuracy: 0.0001)
        }
    }

    func testRoundTrip_AllQuadrants() {
        let bearings: [Double] = [45, 135, 225, 315]

        for bearing in bearings {
            let original = LengthPolar(bearing: .init(degrees: bearing), magnitude: .init(meters: 50))
            let cart = original.lengthCartesianVector
            let recovered = cart.asPolar

            XCTAssertEqual(recovered.bearing.degrees, bearing, accuracy: 0.0001,
                          "Failed round-trip for bearing \(bearing)")
        }
    }
}
