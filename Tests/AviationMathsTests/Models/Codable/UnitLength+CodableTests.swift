import XCTest
@testable import AviationMaths

final class CodableLengthTests: XCTestCase {

    func testRoundTrip_Meters() throws {
        let value = CodableLength(.init(value: 100, unit: .meters))
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(CodableLength.self, from: data)
        XCTAssertEqual(decoded, value)
    }

    func testRoundTrip_NauticalMiles() throws {
        let value = CodableLength(.init(value: 50, unit: .nauticalMiles))
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(CodableLength.self, from: data)
        XCTAssertEqual(decoded.measurement.converted(to: .nauticalMiles).value, 50, accuracy: 1e-9)
    }

    func testRoundTrip_EveryUnit_PreservesLength() throws {
        let units: [UnitLength] = [.meters, .feet, .yards, .nauticalMiles, .kilometers, .miles, .centimeters]

        for unit in units {
            let value = CodableLength(.init(value: 2.5, unit: unit))
            let data = try JSONEncoder().encode(value)
            let decoded = try JSONDecoder().decode(CodableLength.self, from: data)
            XCTAssertEqual(decoded.measurement.meters, value.measurement.meters, accuracy: 1e-9, unit.symbol)
        }
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
