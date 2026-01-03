import XCTest
@testable import AviationMaths

final class Position2DTests: XCTestCase {

    func testInitWithLatitudeLongitude() {
        let lat = Latitude(decimalDegrees: 51.5)
        let lon = Longitude(decimalDegrees: -0.12)
        let pos = Position2D(latitude: lat, longitude: lon)

        XCTAssertEqual(pos.latitude, lat)
        XCTAssertEqual(pos.longitude, lon)
    }

    func testInitWithDoubleValues() {
        let pos = Position2D(latitude: 51.5, longitude: -0.12)
        XCTAssertEqual(pos.latitude.decimalDegrees, 51.5, accuracy: 1e-6)
        XCTAssertEqual(pos.longitude.decimalDegrees, -0.12, accuracy: 1e-6)
    }

    func testInitWithDMSAndDirection() {
        let latDMS = DegreesMinutesSeconds(degrees: 51, minutes: 30, seconds: 0)
        let lonDMS = DegreesMinutesSeconds(degrees: 0, minutes: 7, seconds: 12)
        let pos = Position2D(
            latitudeDMS: latDMS, latitudeDirection: .north,
            longitudeDMS: lonDMS, longitudeDirection: .west
        )

        XCTAssertEqual(pos.latitude.decimalDegrees, 51.5, accuracy: 1e-6)
        XCTAssertEqual(pos.longitude.decimalDegrees, -0.12, accuracy: 1e-6)
    }

    func testInitWithDDMAndDirection() {
        let latDDM = DegreesDecimalMinutes(degrees: 51, minutes: 30.0)
        let lonDDM = DegreesDecimalMinutes(degrees: 0, minutes: 7.2)
        let pos = Position2D(
            latitudeDDM: latDDM, latitudeDirection: .north,
            longitudeDDM: lonDDM, longitudeDirection: .west
        )

        XCTAssertEqual(pos.latitude.decimalDegrees, 51.5, accuracy: 1e-6)
        XCTAssertEqual(pos.longitude.decimalDegrees, -0.12, accuracy: 1e-6)
    }

    func testInitWithComponentsAndDirection() {
        let pos = Position2D(
            latDegrees: 51, latMinutes: 30, latSeconds: 0, latDirection: .north,
            lonDegrees: 0, lonMinutes: 7, lonSeconds: 12, lonDirection: .west
        )

        XCTAssertEqual(pos.latitude.decimalDegrees, 51.5, accuracy: 1e-6)
        XCTAssertEqual(pos.longitude.decimalDegrees, -0.12, accuracy: 1e-6)
    }
}
