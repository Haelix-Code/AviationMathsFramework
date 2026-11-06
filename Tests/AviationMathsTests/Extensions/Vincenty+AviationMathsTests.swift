import XCTest
import Vincenty
@testable import AviationMaths

final class GeodeticCoordinateTests: XCTestCase {

    func testInitWithPosition2D() throws {
        let latitude = 37.7749
        let longitude = -122.4194
        let position2D = Position2D(latitude: try .init(decimalDegrees: latitude),
                                   longitude: try .init(decimalDegrees: longitude))

        let coordinate = GeodeticCoordinate(position2D: position2D)

        XCTAssertEqual(coordinate.latitude, latitude)
        XCTAssertEqual(coordinate.longitude, longitude)
    }
}
