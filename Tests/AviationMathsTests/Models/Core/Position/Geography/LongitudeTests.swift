import XCTest
@testable import AviationMaths

final class LongitudeTests: XCTestCase {

    func testInitWithValidDecimalDegrees() {
        let lonEast = Longitude(decimalDegrees: 45.0)
        XCTAssertEqual(lonEast.decimalDegrees, 45.0)
        XCTAssertEqual(lonEast.direction, .east)

        let lonWest = Longitude(decimalDegrees: -30.0)
        XCTAssertEqual(lonWest.decimalDegrees, -30.0)
        XCTAssertEqual(lonWest.direction, .west)
    }

    func testInitWithDegreesAndDirection() {
        let lonEast = Longitude(degrees: 10, direction: .east)
        XCTAssertEqual(lonEast.decimalDegrees, 10.0)

        let lonWest = Longitude(degrees: 10, direction: .west)
        XCTAssertEqual(lonWest.decimalDegrees, -10.0)
    }

    func testInitWithMeasurement() {
        let angle = Measurement(value: 90.0, unit: UnitAngle.degrees)
        let lon = Longitude(measurement: angle)
        XCTAssertEqual(lon.decimalDegrees, 90.0)
    }

    func testInitWithDMS() {
        let dms = DegreesMinutesSeconds(degrees: 10, minutes: 30, seconds: 0)
        let lonEast = Longitude(dms: dms, direction: .east)
        XCTAssertEqual(lonEast.decimalDegrees, 10.5, accuracy: 1e-6)

        let lonWest = Longitude(dms: dms, direction: .west)
        XCTAssertEqual(lonWest.decimalDegrees, -10.5, accuracy: 1e-6)
    }

    func testInitWithDDM() {
        let ddm = DegreesDecimalMinutes(degrees: 10, minutes: 30.0)
        let lonEast = Longitude(ddm: ddm, direction: .east)
        XCTAssertEqual(lonEast.decimalDegrees, 10.5, accuracy: 1e-6)

        let lonWest = Longitude(ddm: ddm, direction: .west)
        XCTAssertEqual(lonWest.decimalDegrees, -10.5, accuracy: 1e-6)
    }

    func testInitWithComponentsDMS() {
        let lon = Longitude(degrees: 10, minutes: 30, seconds: 0, direction: .east)
        XCTAssertEqual(lon.decimalDegrees, 10.5, accuracy: 1e-6)
    }

    func testInitWithComponentsDDM() {
        let lon = Longitude(degrees: 10, minutes: 30.0, direction: .east)
        XCTAssertEqual(lon.decimalDegrees, 10.5, accuracy: 1e-6)
    }
}
