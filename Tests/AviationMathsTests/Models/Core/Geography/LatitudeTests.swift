import XCTest
@testable import AviationMaths

final class LatitudeTests: XCTestCase {

    func testInitWithValidDecimalDegrees() {
        let lat = Latitude(decimalDegrees: 45.0)
        XCTAssertEqual(lat.decimalDegrees, 45.0)
        XCTAssertEqual(lat.direction, .north)

        let latSouth = Latitude(decimalDegrees: -30.0)
        XCTAssertEqual(latSouth.decimalDegrees, -30.0)
        XCTAssertEqual(latSouth.direction, .south)
    }

    func testInitWithDegreesAndDirection() {
        let latNorth = Latitude(degrees: 10, direction: .north)
        XCTAssertEqual(latNorth.decimalDegrees, 10.0)

        let latSouth = Latitude(degrees: 10, direction: .south)
        XCTAssertEqual(latSouth.decimalDegrees, -10.0)
    }

    func testInitWithMeasurement() {
        let angle = Measurement(value: 45.0, unit: UnitAngle.degrees)
        let lat = Latitude(angle)
        XCTAssertEqual(lat.decimalDegrees, 45.0)
    }

    func testInitWithDMS() {
        let dms = DegreesMinutesSeconds(degrees: 10, minutes: 30, seconds: 0)
        let lat = Latitude(dms: dms, direction: .north)
        XCTAssertEqual(lat.decimalDegrees, 10.5, accuracy: 1e-6)

        let latSouth = Latitude(dms: dms, direction: .south)
        XCTAssertEqual(latSouth.decimalDegrees, -10.5, accuracy: 1e-6)
    }

    func testInitWithDDM() {
        let ddm = DegreesDecimalMinutes(degrees: 10, minutes: 30.0)
        let lat = Latitude(ddm: ddm, direction: .north)
        XCTAssertEqual(lat.decimalDegrees, 10.5, accuracy: 1e-6)

        let latSouth = Latitude(ddm: ddm, direction: .south)
        XCTAssertEqual(latSouth.decimalDegrees, -10.5, accuracy: 1e-6)
    }

    func testInitWithComponentsDMS() {
        let lat = Latitude(degrees: 10, minutes: 30, seconds: 0, direction: .north)
        XCTAssertEqual(lat.decimalDegrees, 10.5, accuracy: 1e-6)
    }

    func testInitWithComponentsDDM() {
        let lat = Latitude(degrees: 10, minutes: 30.0, direction: .north)
        XCTAssertEqual(lat.decimalDegrees, 10.5, accuracy: 1e-6)
    }
}
