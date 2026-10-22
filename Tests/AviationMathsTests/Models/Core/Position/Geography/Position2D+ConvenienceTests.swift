import XCTest
@testable import AviationMaths
import Vincenty

final class Position2DConvenienceTests: XCTestCase {

    func testInitWithCoordinate() {
        let coord = GeodeticCoordinate(latitude: 51.5, longitude: -0.12)
        let pos = Position2D(coordinate: coord)

        XCTAssertEqual(pos.latitude.decimalDegrees, 51.5, accuracy: 1e-6)
        XCTAssertEqual(pos.longitude.decimalDegrees, -0.12, accuracy: 1e-6)
    }

    func testInitWithCoordinate_OvershootingPole_ClampsInsteadOfCrashing() {
        // Floating-point noise from geodesic math can land fractionally past a pole
        // or the antimeridian; this must clamp rather than trip Latitude/Longitude's
        // range precondition.
        let coord = GeodeticCoordinate(latitude: 90.0000000001, longitude: 180.0000000001)
        let pos = Position2D(coordinate: coord)

        XCTAssertEqual(pos.latitude.decimalDegrees, 90.0)
        XCTAssertEqual(pos.longitude.decimalDegrees, 180.0)
    }

    func testComputedPropertiesPassThrough() {
        let pos = Position2D(latitude: 51.5, longitude: -0.12)

        XCTAssertEqual(pos.latitudeDecimalDegrees, 51.5, accuracy: 1e-6)
        XCTAssertEqual(pos.longitudeDecimalDegrees, -0.12, accuracy: 1e-6)
        XCTAssertEqual(pos.latitudeDirection, .north)
        XCTAssertEqual(pos.longitudeDirection, .west)

        XCTAssertEqual(pos.latitudeDMS.asDecimalDegrees, 51.5, accuracy: 1e-6)
        XCTAssertEqual(pos.longitudeDDM.asDecimalDegrees, 0.12, accuracy: 1e-6)
    }
}
