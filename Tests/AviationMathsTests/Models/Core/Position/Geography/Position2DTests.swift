import XCTest
import Vincenty
@testable import AviationMaths

final class Position2DTests: XCTestCase {

    func testInitWithLatitudeLongitude() throws {
        let lat = try Latitude(decimalDegrees: 51.5)
        let lon = try Longitude(decimalDegrees: -0.12)
        let pos = Position2D(latitude: lat, longitude: lon)

        XCTAssertEqual(pos.latitude, lat)
        XCTAssertEqual(pos.longitude, lon)
    }

    func testInitWithDoubleValues() throws {
        let pos = try Position2D(latitude: 51.5, longitude: -0.12)
        XCTAssertEqual(pos.latitude.decimalDegrees, 51.5, accuracy: 1e-6)
        XCTAssertEqual(pos.longitude.decimalDegrees, -0.12, accuracy: 1e-6)
    }

    func testInitWithDMSAndDirection() throws {
        let latDMS = DegreesMinutesSeconds(degrees: 51, minutes: 30, seconds: 0)
        let lonDMS = DegreesMinutesSeconds(degrees: 0, minutes: 7, seconds: 12)
        let pos = try Position2D(
            latitudeDMS: latDMS, latitudeDirection: .north,
            longitudeDMS: lonDMS, longitudeDirection: .west
        )

        XCTAssertEqual(pos.latitude.decimalDegrees, 51.5, accuracy: 1e-6)
        XCTAssertEqual(pos.longitude.decimalDegrees, -0.12, accuracy: 1e-6)
    }

    func testInitWithDDMAndDirection() throws {
        let latDDM = DegreesDecimalMinutes(degrees: 51, minutes: 30.0)
        let lonDDM = DegreesDecimalMinutes(degrees: 0, minutes: 7.2)
        let pos = try Position2D(
            latitudeDDM: latDDM, latitudeDirection: .north,
            longitudeDDM: lonDDM, longitudeDirection: .west
        )

        XCTAssertEqual(pos.latitude.decimalDegrees, 51.5, accuracy: 1e-6)
        XCTAssertEqual(pos.longitude.decimalDegrees, -0.12, accuracy: 1e-6)
    }

    func testInitWithComponentsAndDirection() throws {
        let pos = try Position2D(
            latDegrees: 51, latMinutes: 30, latSeconds: 0, latDirection: .north,
            lonDegrees: 0, lonMinutes: 7, lonSeconds: 12, lonDirection: .west
        )

        XCTAssertEqual(pos.latitude.decimalDegrees, 51.5, accuracy: 1e-6)
        XCTAssertEqual(pos.longitude.decimalDegrees, -0.12, accuracy: 1e-6)
    }

    func testInit_OutOfRange_Throws_InsteadOfTrapping() {
        XCTAssertThrowsError(try Position2D(latitude: 95, longitude: 0)) {
            XCTAssertEqual($0 as? CoordinateError, .latitudeOutOfRange(95))
        }
        XCTAssertThrowsError(try Position2D(latitude: 0, longitude: -200)) {
            XCTAssertEqual($0 as? CoordinateError, .longitudeOutOfRange(-200))
        }
        XCTAssertThrowsError(try Position2D(coordinate: GeodeticCoordinate(latitude: .nan, longitude: 0))) {
            XCTAssertTrue($0 is CoordinateError)
        }
    }
}
