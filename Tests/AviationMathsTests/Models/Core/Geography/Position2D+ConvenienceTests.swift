import XCTest
@testable import AviationMaths
import GeodesySpherical

final class Position2DConvenienceTests: XCTestCase {
    func testInitWithCoordinate() {
        let coord = Coordinate(latitude: 51.5, longitude: -0.12)
        let pos = Position2D(coordinate: coord)

        XCTAssertEqual(pos.latitude.decimalDegrees, 51.5, accuracy: 1e-6)
        XCTAssertEqual(pos.longitude.decimalDegrees, -0.12, accuracy: 1e-6)
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
