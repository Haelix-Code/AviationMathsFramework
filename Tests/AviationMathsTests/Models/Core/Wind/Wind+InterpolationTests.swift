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
}
