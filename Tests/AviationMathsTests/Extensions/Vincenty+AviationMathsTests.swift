import XCTest
import Vincenty
@testable import AviationMaths

final class GeodeticCoordinateTests: XCTestCase {

    func testInitWithPosition2D() {
        let latitude = 37.7749
        let longitude = -122.4194
        let position2D = Position2D(latitude: .init(decimalDegrees: latitude),
                                   longitude: .init(decimalDegrees: longitude))

        let coordinate = GeodeticCoordinate(position2D: position2D)

        XCTAssertEqual(coordinate.latitude, latitude)
        XCTAssertEqual(coordinate.longitude, longitude)
    }
}
