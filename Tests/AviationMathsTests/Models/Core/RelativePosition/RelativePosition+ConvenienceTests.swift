import XCTest
@testable import AviationMaths
import Foundation

final class RelativePositionConvenienceTests: XCTestCase {
    func testBearingNorth() {
        let start = RelativePosition(x: .init(meters: 0), y: .init(meters: 0))
        let destination = RelativePosition(x: .init(meters: 0), y: .init(meters: 10))

        let bearing = start.bearing(to: destination)

        XCTAssertEqual(bearing.value, 0, accuracy: 0.0001, "Bearing should be 0 radians (North).")
    }

    func testBearingSouth() {
        let start = RelativePosition(x: .init(meters: 0), y: .init(meters: 0))
        let destination = RelativePosition(x: .init(meters: 0), y: .init(meters: -10))

        let bearing = start.bearing(to: destination)

        XCTAssertEqual(bearing.radians, .pi, accuracy: 0.0001, "Bearing should be π radians (South).")
    }

    func testBearingEast() {
        let start = RelativePosition(x: .init(meters: 0), y: .init(meters: 0))
        let destination = RelativePosition(x: .init(meters: 10), y: .init(meters: 0))

        let bearing = start.bearing(to: destination)

        XCTAssertEqual(bearing.radians, (.pi / 2), accuracy: 0.0001, "Bearing should be π/2 radians (East).")
    }

    func testBearingWest() {
        let start = RelativePosition(x: .init(meters: 0), y: .init(meters: 0))
        let destination = RelativePosition(x: .init(meters: -10), y: .init(meters: 0))

        let bearing = start.bearing(to: destination)

        XCTAssertEqual(bearing.radians, 3 * .pi / 2, accuracy: 0.0001, "Bearing should be 3π/2 radians (West).")
    }

    func testBearingSamePosition() {
        let start = RelativePosition(x: .init(meters: 0), y: .init(meters: 0))
        let destination = start

        let bearing = start.bearing(to: destination)

        XCTAssertEqual(bearing.radians, 0, accuracy: 0.0001, "Bearing should be 0 radians (same position).")
    }

    func testBearingNormalization() {
        let start = RelativePosition(x: .init(meters: 0), y: .init(meters: 0))
        let destination = RelativePosition(x: .init(meters: -10), y: .init(meters: -10))

        let bearing = start.bearing(to: destination)
        XCTAssert(bearing.radians >= 0, "Bearing should be greater than or equal to 0.")
        XCTAssert(bearing.radians <= 2 * .pi, "Bearing should be less than or equal to 2xπ.")
    }
}
