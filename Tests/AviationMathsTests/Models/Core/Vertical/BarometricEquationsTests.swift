import XCTest
@testable import AviationMaths

final class BarometricEquationsTests: XCTestCase {

    // MARK: - Standard Barometric Tests (ISA)

    func testConvertVerticalDistanceMetersToPressurePaISA() throws {
        let pressureAtAltitude = BarometricEquations.pressureFromAltitude(
            altitude: .init(meters: 1000),
            referencePressure: ISA.seaLevelPressure,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )

        XCTAssertEqual(pressureAtAltitude.pascals, 89874.75, accuracy: 1)
    }

    func testConvertVerticalDistanceMetersAndQNHToPressurePa() throws {
        let pressureAtAltitude = BarometricEquations.pressureFromAltitude(
            altitude: .init(meters: 5000),
            referencePressure: .init(pascals: 101000),
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )

        XCTAssertEqual(pressureAtAltitude.pascals, 53847.22, accuracy: 1)
    }

    func testConvertVerticalPressurePaToAltitudeMeters_ZERO() throws {
        let pressure: Measurement<UnitPressure> = .init(pascals: 101325)
        let referencePressure: Measurement<UnitPressure> = .init(hectopascals: 1013.25)

        let altitude = BarometricEquations.altitudeFromPressure(
            pressure: pressure,
            referencePressure: referencePressure,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )

        XCTAssertEqual(altitude.meters, 0, accuracy: 0.1)
    }

    func testConvertVerticalPressurePaToAltitudeMetersISA() throws {
        let pressure: Measurement<UnitPressure> = .init(pascals: 26436)

        let altitude = BarometricEquations.altitudeFromPressure(
            pressure: pressure,
            referencePressure: ISA.seaLevelPressure,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )

        XCTAssertEqual(altitude.meters, 10000, accuracy: 1)
    }

    func testConvertVerticalPressurePaToAltitudeMeters() throws {
        let pressure: Measurement<UnitPressure> = .init(pascals: 95325)
        let referencePressure: Measurement<UnitPressure> = .init(hectopascals: 990)

        let altitude = BarometricEquations.altitudeFromPressure(
            pressure: pressure,
            referencePressure: referencePressure,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )

        XCTAssertEqual(altitude.meters, 317.9, accuracy: 1)
    }

    func testConvertVerticalPressurePaAndQNHToAltitudeMeters() throws {
        let pressure: Measurement<UnitPressure> = .init(pascals: 50000)
        let referencePressure: Measurement<UnitPressure> = .init(hectopascals: 1010)

        let altitude = BarometricEquations.altitudeFromPressure(
            pressure: pressure,
            referencePressure: referencePressure,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )

        XCTAssertEqual(altitude.meters, 5550.8, accuracy: 1)
    }

    // MARK: - True Altitude Tests

    func testTrueAltitudeFromPressure() throws {
        // Test case: non-standard atmosphere (cold)
        let pressure: Measurement<UnitPressure> = .init(pascals: 69681) // ~3000m in ISA
        let seaLevelTemp: Measurement<UnitTemperature> = .init(celsius: -5)
        let qnh: Measurement<UnitPressure> = .init(hectopascals: 1013.25)
        let lapseRate: Double = ISA.troposphereLapseRate

        let trueAlt = BarometricEquations.trueAltitudeFromPressure(
            pressure: pressure,
            referencePressure: qnh,
            referenceTemperature: seaLevelTemp,
            lapseRate: lapseRate
        )

        // In colder air, true altitude is lower than ISA would suggest
        XCTAssertLessThan(trueAlt.meters, 3000)
    }

    func testPressureFromTrueAltitude() throws {
        // Test case: non-standard atmosphere (hot)
        let trueAlt: Measurement<UnitLength> = .init(meters: 3000)
        let seaLevelTemp: Measurement<UnitTemperature> = .init(celsius: 25)
        let qnh: Measurement<UnitPressure> = .init(hectopascals: 1013.25)
        let lapseRate: Double = ISA.troposphereLapseRate

        let pressure = BarometricEquations.pressureFromTrueAltitude(
            trueAltitude: trueAlt,
            referencePressure: qnh,
            referenceTemperature: seaLevelTemp,
            lapseRate: lapseRate
        )

        // Should return a pressure value
        XCTAssertGreaterThan(pressure.pascals, 60000)
        XCTAssertLessThan(pressure.pascals, 80000)
    }

    func testTrueAltitudeRoundTrip() throws {
        // Test that converting altitude → pressure → altitude gives same result
        let originalAlt: Measurement<UnitLength> = .init(feet: 5000)
        let seaLevelTemp: Measurement<UnitTemperature> = .init(celsius: 15)
        let qnh: Measurement<UnitPressure> = .init(hectopascals: 1013.25)
        let lapseRate: Double = ISA.troposphereLapseRate

        let pressure = BarometricEquations.pressureFromTrueAltitude(
            trueAltitude: originalAlt,
            referencePressure: qnh,
            referenceTemperature: seaLevelTemp,
            lapseRate: lapseRate
        )

        let recoveredAlt = BarometricEquations.trueAltitudeFromPressure(
            pressure: pressure,
            referencePressure: qnh,
            referenceTemperature: seaLevelTemp,
            lapseRate: lapseRate
        )

        XCTAssertEqual(recoveredAlt.feet, originalAlt.feet, accuracy: 0.1)
    }
}
