import XCTest
@testable import AviationMaths

final class CodableSpeedTests: XCTestCase {

    func testRoundTrip_Knots() throws {
        let value = CodableSpeed(.init(value: 120, unit: .knots))
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(CodableSpeed.self, from: data)
        XCTAssertEqual(decoded, value)
    }

    /// `mph` was missing from both `decodeMap` and `encodeNames`, so a value encoded
    /// in miles per hour fell back to `raw.unit.symbol` ("mph") on encode but then
    /// failed to decode since "mph" wasn't a recognised key.
    func testRoundTrip_MilesPerHour() throws {
        let value = CodableSpeed(.init(value: 60, unit: .milesPerHour))
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(CodableSpeed.self, from: data)
        XCTAssertEqual(decoded.measurement.converted(to: .milesPerHour).value, 60, accuracy: 1e-9)
    }

    func testDecode_UnknownUnit_Throws() {
        let json = """
        {"value": 10, "unit": "furlongs/fortnight"}
        """
        XCTAssertThrowsError(try JSONDecoder().decode(CodableSpeed.self, from: Data(json.utf8))) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
}
