import XCTest
@testable import AviationMaths

final class CodableLengthTests: XCTestCase {

    func testRoundTrip_Meters() throws {
        let value = CodableLength(.init(value: 100, unit: .meters))
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(CodableLength.self, from: data)
        XCTAssertEqual(decoded, value)
    }

    /// `UnitLength.nauticalMiles.symbol` is "NM", which the old decodeMap didn't
    /// recognise (lowercased to "nm"), so a value encoded in nautical miles could
    /// not be decoded back.
    func testRoundTrip_NauticalMiles() throws {
        let value = CodableLength(.init(value: 50, unit: .nauticalMiles))
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(CodableLength.self, from: data)
        XCTAssertEqual(decoded.measurement.converted(to: .nauticalMiles).value, 50, accuracy: 1e-9)
    }

    func testDecode_UnknownUnit_Throws() {
        let json = """
        {"value": 10, "unit": "furlong"}
        """
        XCTAssertThrowsError(try JSONDecoder().decode(CodableLength.self, from: Data(json.utf8))) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
}
