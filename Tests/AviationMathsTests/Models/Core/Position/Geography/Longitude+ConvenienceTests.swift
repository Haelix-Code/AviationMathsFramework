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

    /// `Longitude.description` calls `formatted(direction:isLongitude: false)`,
    /// so a longitude like 5° prints as "05°" (2-digit, latitude-style padding)
    /// instead of the 3-digit "005°" that longitude requires.
    func testDescription_PadsDegreesToThreeDigits() {
        let lon = Longitude(decimalDegrees: 5.0)
        XCTAssertTrue(
            lon.description.hasPrefix("005°"),
            "Longitude must pad to 3 degree digits, got: \(lon.description)"
        )
    }

    func testDecode_OutOfRangeValue_ThrowsInsteadOfCrashing() throws {
        let data = Data("181.0".utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(Longitude.self, from: data)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testDecode_InRangeValue_RoundTrips() throws {
        let data = try JSONEncoder().encode(Longitude(decimalDegrees: -120.0))
        let decoded = try JSONDecoder().decode(Longitude.self, from: data)
        XCTAssertEqual(decoded.decimalDegrees, -120.0)
    }
}
