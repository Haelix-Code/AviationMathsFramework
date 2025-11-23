import XCTest
@testable import AviationMaths

final class LatitudeConvenienceTests: XCTestCase {
    func testHemisphereProperties() {
        let north = Latitude(decimalDegrees: 45.0)
        XCTAssertTrue(north.isNorthernHemisphere)
        XCTAssertFalse(north.isSouthernHemisphere)

        let south = Latitude(decimalDegrees: -30.0)
        XCTAssertTrue(south.isSouthernHemisphere)
        XCTAssertFalse(south.isNorthernHemisphere)

        let equator = Latitude(decimalDegrees: 0.0)
        XCTAssertFalse(equator.isNorthernHemisphere)
        XCTAssertFalse(equator.isSouthernHemisphere)
    }
}
