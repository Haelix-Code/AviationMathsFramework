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

    func testDecode_OutOfRangeValue_ThrowsInsteadOfCrashing() throws {
        let data = Data("91.0".utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(Latitude.self, from: data)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testDecode_InRangeValue_RoundTrips() throws {
        let data = try JSONEncoder().encode(Latitude(decimalDegrees: 45.0))
        let decoded = try JSONDecoder().decode(Latitude.self, from: data)
        XCTAssertEqual(decoded.decimalDegrees, 45.0)
    }
}
