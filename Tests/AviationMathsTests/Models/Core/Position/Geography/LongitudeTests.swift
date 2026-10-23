import XCTest
@testable import AviationMaths

final class LongitudeTests: XCTestCase {

    func testInitWithValidDecimalDegrees() throws {
        let lonEast = try Longitude(decimalDegrees: 45.0)
        XCTAssertEqual(lonEast.decimalDegrees, 45.0)
        XCTAssertEqual(lonEast.direction, .east)

        let lonWest = try Longitude(decimalDegrees: -30.0)
        XCTAssertEqual(lonWest.decimalDegrees, -30.0)
        XCTAssertEqual(lonWest.direction, .west)
    }

    func testInitWithDegreesAndDirection() throws {
        let lonEast = try Longitude(degrees: 10, direction: .east)
        XCTAssertEqual(lonEast.decimalDegrees, 10.0)

        let lonWest = try Longitude(degrees: 10, direction: .west)
        XCTAssertEqual(lonWest.decimalDegrees, -10.0)
    }

    func testInitWithMeasurement() throws {
        let angle = Measurement(value: 90.0, unit: UnitAngle.degrees)
        let lon = try Longitude(measurement: angle)
        XCTAssertEqual(lon.decimalDegrees, 90.0)
    }

    func testInitWithDMS() throws {
        let dms = DegreesMinutesSeconds(degrees: 10, minutes: 30, seconds: 0)
        let lonEast = try Longitude(dms: dms, direction: .east)
        XCTAssertEqual(lonEast.decimalDegrees, 10.5, accuracy: 1e-6)

        let lonWest = try Longitude(dms: dms, direction: .west)
        XCTAssertEqual(lonWest.decimalDegrees, -10.5, accuracy: 1e-6)
    }

    func testInitWithDDM() throws {
        let ddm = DegreesDecimalMinutes(degrees: 10, minutes: 30.0)
        let lonEast = try Longitude(ddm: ddm, direction: .east)
        XCTAssertEqual(lonEast.decimalDegrees, 10.5, accuracy: 1e-6)

        let lonWest = try Longitude(ddm: ddm, direction: .west)
        XCTAssertEqual(lonWest.decimalDegrees, -10.5, accuracy: 1e-6)
    }

    func testInitWithComponentsDMS() throws {
        let lon = try Longitude(degrees: 10, minutes: 30, seconds: 0, direction: .east)
        XCTAssertEqual(lon.decimalDegrees, 10.5, accuracy: 1e-6)
    }

    func testInitWithComponentsDDM() throws {
        let lon = try Longitude(degrees: 10, minutes: 30.0, direction: .east)
        XCTAssertEqual(lon.decimalDegrees, 10.5, accuracy: 1e-6)
    }

    func testInit_OutOfRange_Throws_InsteadOfTrapping() {
        XCTAssertThrowsError(try Longitude(decimalDegrees: -180.5)) {
            XCTAssertEqual($0 as? CoordinateError, .longitudeOutOfRange(-180.5))
        }
        XCTAssertThrowsError(try Longitude(decimalDegrees: .infinity)) {
            XCTAssertEqual($0 as? CoordinateError, .longitudeOutOfRange(.infinity))
        }
        XCTAssertThrowsError(try Longitude(degrees: 181, direction: .west)) {
            XCTAssertEqual($0 as? CoordinateError, .longitudeOutOfRange(-181))
        }
    }
}
