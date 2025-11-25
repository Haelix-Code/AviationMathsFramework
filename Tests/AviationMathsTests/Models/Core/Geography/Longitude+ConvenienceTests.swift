import XCTest
@testable import AviationMaths

final class LongitudeConvenienceTests: XCTestCase {
    func testHemisphereProperties() {
        let east = Longitude(decimalDegrees: 45.0)
        XCTAssertTrue(east.isEasternHemisphere)
        XCTAssertFalse(east.isWesternHemisphere)

        let west = Longitude(decimalDegrees: -30.0)
        XCTAssertTrue(west.isWesternHemisphere)
        XCTAssertFalse(west.isEasternHemisphere)

        let primeMeridian = Longitude(decimalDegrees: 0.0)
        XCTAssertFalse(primeMeridian.isEasternHemisphere)
        XCTAssertFalse(primeMeridian.isWesternHemisphere)
    }

    func testNormalizedWithinRange() {
        let lon = Longitude(decimalDegrees: 170.0)
        XCTAssertEqual(lon.normalized.decimalDegrees, 170.0)
    }

    func testAs0To360Conversion() {
        let east = Longitude(decimalDegrees: 45.0)
        XCTAssertEqual(east.as0To360, 45.0)

        let west = Longitude(decimalDegrees: -30.0)
        XCTAssertEqual(west.as0To360, 330.0)
    }

    func testShortestDistanceSimple() {
        let lon1 = Longitude(decimalDegrees: 10.0)
        let lon2 = Longitude(decimalDegrees: 20.0)
        XCTAssertEqual(lon1.shortestDistance(to: lon2), 10.0)
    }

    func testShortestDistanceWrapAroundPositive() {
        let lon1 = Longitude(decimalDegrees: 170.0)
        let lon2 = Longitude(decimalDegrees: -170.0)
        XCTAssertEqual(lon1.shortestDistance(to: lon2), 20.0)
    }

    func testShortestDistanceWrapAroundNegative() {
        let lon1 = Longitude(decimalDegrees: -170.0)
        let lon2 = Longitude(decimalDegrees: 170.0)
        XCTAssertEqual(lon1.shortestDistance(to: lon2), -20.0)
    }
}
