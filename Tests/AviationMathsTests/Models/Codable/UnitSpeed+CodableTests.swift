import XCTest
@testable import AviationMaths

final class CodableSpeedTests: XCTestCase {

    func testRoundTrip_Knots() throws {
        let value = CodableSpeed(.init(value: 120, unit: .knots))
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(CodableSpeed.self, from: data)
        XCTAssertEqual(decoded, value)
    }

    func testRoundTrip_MilesPerHour() throws {
        let value = CodableSpeed(.init(value: 60, unit: .milesPerHour))
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(CodableSpeed.self, from: data)
        XCTAssertEqual(decoded.measurement.converted(to: .milesPerHour).value, 60, accuracy: 1e-9)
    }

    func testDecode_KnSymbol() throws {
        let json = """
        {"value": 25, "unit": "kn"}
        """
        let decoded = try JSONDecoder().decode(CodableSpeed.self, from: Data(json.utf8))
        XCTAssertEqual(decoded.measurement.knots, 25, accuracy: 1e-9)
    }

    func testRoundTrip_UnmappedUnit_PreservesSpeed() throws {
        let millimetresPerSecond = UnitSpeed(symbol: "mm/s", converter: UnitConverterLinear(coefficient: 0.001))
        let value = CodableSpeed(.init(value: 2500, unit: millimetresPerSecond))

        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(CodableSpeed.self, from: data)

        XCTAssertEqual(decoded.measurement.mps, 2.5, accuracy: 1e-9)
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
