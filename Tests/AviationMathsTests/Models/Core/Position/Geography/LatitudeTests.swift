import XCTest
@testable import AviationMaths

final class LatitudeTests: XCTestCase {

    func testInitWithValidDecimalDegrees() throws {
        let lat = try Latitude(decimalDegrees: 45.0)
        XCTAssertEqual(lat.decimalDegrees, 45.0)
        XCTAssertEqual(lat.direction, .north)

        let latSouth = try Latitude(decimalDegrees: -30.0)
        XCTAssertEqual(latSouth.decimalDegrees, -30.0)
        XCTAssertEqual(latSouth.direction, .south)
    }

    func testInitWithDegreesAndDirection() throws {
        let latNorth = try Latitude(degrees: 10, direction: .north)
        XCTAssertEqual(latNorth.decimalDegrees, 10.0)

        let latSouth = try Latitude(degrees: 10, direction: .south)
        XCTAssertEqual(latSouth.decimalDegrees, -10.0)
    }

    func testInitWithMeasurement() throws {
        let angle = Measurement(value: 45.0, unit: UnitAngle.degrees)
        let lat = try Latitude(measurement: angle)
        XCTAssertEqual(lat.decimalDegrees, 45.0)
    }

    func testInitWithDMS() throws {
        let dms = DegreesMinutesSeconds(degrees: 10, minutes: 30, seconds: 0)
        let lat = try Latitude(dms: dms, direction: .north)
        XCTAssertEqual(lat.decimalDegrees, 10.5, accuracy: 1e-6)

        let latSouth = try Latitude(dms: dms, direction: .south)
        XCTAssertEqual(latSouth.decimalDegrees, -10.5, accuracy: 1e-6)
    }

    func testInitWithDDM() throws {
        let ddm = DegreesDecimalMinutes(degrees: 10, minutes: 30.0)
        let lat = try Latitude(ddm: ddm, direction: .north)
        XCTAssertEqual(lat.decimalDegrees, 10.5, accuracy: 1e-6)

        let latSouth = try Latitude(ddm: ddm, direction: .south)
        XCTAssertEqual(latSouth.decimalDegrees, -10.5, accuracy: 1e-6)
    }

    func testInitWithComponentsDMS() throws {
        let lat = try Latitude(degrees: 10, minutes: 30, seconds: 0, direction: .north)
        XCTAssertEqual(lat.decimalDegrees, 10.5, accuracy: 1e-6)
    }

    func testInitWithComponentsDDM() throws {
        let lat = try Latitude(degrees: 10, minutes: 30.0, direction: .north)
        XCTAssertEqual(lat.decimalDegrees, 10.5, accuracy: 1e-6)
    }

    func testInit_OutOfRange_Throws_InsteadOfTrapping() {
        XCTAssertThrowsError(try Latitude(decimalDegrees: 90.5)) {
            XCTAssertEqual($0 as? CoordinateError, .latitudeOutOfRange(90.5))
        }
        XCTAssertThrowsError(try Latitude(decimalDegrees: .nan)) { XCTAssertTrue($0 is CoordinateError) }
        XCTAssertThrowsError(try Latitude(degrees: 91, direction: .north)) {
            XCTAssertEqual($0 as? CoordinateError, .latitudeOutOfRange(91))
        }
    }
}
