import XCTest
@testable import AviationMaths

final class WindInterpolationTests: XCTestCase {

    func testInterpolated_returnsNil_whenEmpty() {
        let winds: [Wind] = []
        XCTAssertNil(winds.interpolated(at: .init(feet: 5000)))
    }

    func testInterpolated_returnsNil_belowLowest() {
        let winds = [
            Wind(feet: 1000, knots: 10, fromDirection: 180),
            Wind(feet: 5000, knots: 20, fromDirection: 200)
        ]

        XCTAssertNil(winds.interpolated(at: .init(feet: 500)))
    }

    func testInterpolated_returnsNil_aboveHighest() {
        let winds = [
            Wind(feet: 1000, knots: 10, fromDirection: 180),
            Wind(feet: 5000, knots: 20, fromDirection: 200)
        ]

        XCTAssertNil(winds.interpolated(at: .init(feet: 6000)))
    }

    func testInterpolated_returnsExactMatch_whenNearSameAltitude() {
        let w1 = Wind(feet: 1000, knots: 10, fromDirection: 180)
        let w2 = Wind(feet: 5000, knots: 20, fromDirection: 200)
        let winds = [w1, w2]

        // Implementation uses abs(diff) < 0.1 meters for exact match
        let exact = winds.interpolated(at: w2.altitude)

        XCTAssertNotNil(exact)
        XCTAssertEqual(exact?.speed.knots ?? -1, 20, accuracy: 1e-12)
        XCTAssertEqual(exact?.fromDirection.degrees ?? -1, 200, accuracy: 1e-12)
        XCTAssertEqual(exact?.altitude.feet ?? -1, 5000, accuracy: 1e-12)
    }

    func testInterpolated_interpolatesSpeedLinearly() {
        let winds = [
            Wind(feet: 0, knots: 10, fromDirection: 180),
            Wind(feet: 10000, knots: 30, fromDirection: 180)
        ]

        let mid = winds.interpolated(at: .init(feet: 5000))
        XCTAssertNotNil(mid)
        XCTAssertEqual(mid!.speed.knots, 20, accuracy: 1e-10)
        XCTAssertEqual(mid!.fromDirection.degrees, 180, accuracy: 1e-10)
    }

    func testInterpolated_interpolatesDirection_across360Wrap_shortestWay() {
        // Lower = 350°, Upper = 10°
        // The shortest path is +20° through 0°, so midpoint should be ~0°
        let winds = [
            Wind(feet: 0, knots: 20, fromDirection: 350),
            Wind(feet: 10000, knots: 20, fromDirection: 10)
        ]

        let mid = winds.interpolated(at: .init(feet: 5000))
        XCTAssertNotNil(mid)
        XCTAssertEqual(mid!.fromDirection.degrees, 0, accuracy: 1e-8)
    }

    func testInterpolated_acceptsUnsortedInput() {
        let winds = [
            Wind(feet: 10000, knots: 30, fromDirection: 200),
            Wind(feet: 0, knots: 10, fromDirection: 180)
        ]

        let mid = winds.interpolated(at: .init(feet: 5000))
        XCTAssertNotNil(mid)
        XCTAssertEqual(mid!.speed.knots, 20, accuracy: 1e-10)
        XCTAssertEqual(mid!.fromDirection.degrees, 190, accuracy: 1e-10)
    }

    /// 360/30 at the surface and 120/30 at 10,000ft are two winds of equal
    /// speed but opposing-ish direction. Interpolating speed and direction
    /// independently keeps the speed at 30kt for every midpoint (wrong — the
    /// vectors partially cancel). Interpolating the u/v components and
    /// converting back gives the correct midpoint: 060/15.
    func testInterpolated_UsesComponentInterpolation_NotSeparateSpeedAndDirection() {
        let winds = [
            Wind(feet: 0, knots: 30, fromDirection: 360),
            Wind(feet: 10000, knots: 30, fromDirection: 120)
        ]

        let mid = winds.interpolated(at: .init(feet: 5000))
        XCTAssertNotNil(mid)

        // Correct: average the u/v (toDirection) components, not speed/direction separately.
        let lowerVector = winds[0].vector
        let upperVector = winds[1].vector
        let expectedVector = (lowerVector + upperVector) / 2
        let expectedWind = expectedVector.asPolar

        XCTAssertEqual(mid!.speed.knots, expectedWind.magnitude.knots, accuracy: 0.1)
        XCTAssertEqual(mid!.fromDirection.degrees, 60, accuracy: 0.1)
        XCTAssertEqual(mid!.speed.knots, 15, accuracy: 0.1)
    }

    /// 270/20 and 090/20 are directly opposing winds of equal speed: their
    /// vector sum is (near) zero, so the correct midpoint speed is ~0kt.
    /// Interpolating speed and direction separately instead reports 20kt,
    /// because it never notices the vectors cancel.
    func testInterpolated_OpposingWinds_CancelToNearZeroSpeed() {
        let winds = [
            Wind(feet: 0, knots: 20, fromDirection: 270),
            Wind(feet: 10000, knots: 20, fromDirection: 90)
        ]

        let mid = winds.interpolated(at: .init(feet: 5000))
        XCTAssertNotNil(mid)

        XCTAssertEqual(mid!.speed.knots, 0, accuracy: 0.5,
                      "Directly opposing winds of equal speed must ~cancel, not stay at full speed")
    }
}
