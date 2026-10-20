import XCTest
@testable import AviationMaths

final class BarometricEquationsTests: XCTestCase {

    func testConvertVerticalDistanceMetersToPressurePaISA() {
        let pressureAtAltitude = BarometricEquations.pressureFromAltitude(
            altitude: .init(meters: 1000),
            referencePressure: ISA.seaLevelPressure,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )

        XCTAssertEqual(pressureAtAltitude.pascals, 89874.75, accuracy: 1)
    }

    func testConvertVerticalDistanceMetersAndQNHToPressurePa() {
        let pressureAtAltitude = BarometricEquations.pressureFromAltitude(
            altitude: .init(meters: 5000),
            referencePressure: .init(pascals: 101000),
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )

        XCTAssertEqual(pressureAtAltitude.pascals, 53847.22, accuracy: 1)
    }

    func testConvertVerticalPressurePaToAltitudeMeters_ZERO() {
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

    func testConvertVerticalPressurePaToAltitudeMetersISA() {
        let pressure: Measurement<UnitPressure> = .init(pascals: 26436)

        let altitude = BarometricEquations.altitudeFromPressure(
            pressure: pressure,
            referencePressure: ISA.seaLevelPressure,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )

        XCTAssertEqual(altitude.meters, 10000, accuracy: 1)
    }

    func testConvertVerticalPressurePaToAltitudeMeters() {
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

    func testConvertVerticalPressurePaAndQNHToAltitudeMeters() {
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

    func testTrueAltitudeFromPressure() {
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

    func testPressureFromTrueAltitude() {
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

    func testTrueAltitudeRoundTrip() {
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

    func testRoundTrip_StandardAtmosphere_LowAltitude() {
        let original = Measurement<UnitLength>(meters: 1000)
        let pressure = BarometricEquations.pressureFromAltitude(altitude: original)
        let recovered = BarometricEquations.altitudeFromPressure(pressure: pressure)

        XCTAssertEqual(recovered.meters, original.meters, accuracy: 0.1,
                      "Round-trip should recover original altitude")
    }

    func testRoundTrip_StandardAtmosphere_HighAltitude() {
        let original = Measurement<UnitLength>(meters: 10000)
        let pressure = BarometricEquations.pressureFromAltitude(altitude: original)
        let recovered = BarometricEquations.altitudeFromPressure(pressure: pressure)

        XCTAssertEqual(recovered.meters, original.meters, accuracy: 1.0,
                      "Round-trip should recover original altitude")
    }

    func testRoundTrip_NonStandardQNH() {
        let altitude = Measurement<UnitLength>(meters: 2500)
        let qnh = Measurement<UnitPressure>(hectopascals: 1008)

        let pressure = BarometricEquations.pressureFromAltitude(
            altitude: altitude,
            referencePressure: qnh
        )

        let recovered = BarometricEquations.altitudeFromPressure(
            pressure: pressure,
            referencePressure: qnh
        )

        XCTAssertEqual(recovered.meters, altitude.meters, accuracy: 0.5,
                      "Round-trip with custom QNH should work")
    }

    func testRoundTrip_NonStandardTemperature() {
        let altitude = Measurement<UnitLength>(meters: 3000)
        let temp = Measurement<UnitTemperature>(celsius: 25)

        let pressure = BarometricEquations.pressureFromAltitude(
            altitude: altitude,
            temperature: temp
        )

        let recovered = BarometricEquations.altitudeFromPressure(
            pressure: pressure,
            temperature: temp
        )

        XCTAssertEqual(recovered.meters, altitude.meters, accuracy: 0.5,
                      "Round-trip with custom temperature should work")    }

    func testAccuracy_MultipleRoundTrips() {
        var altitude = Measurement<UnitLength>(meters: 3500)

        for _ in 0..<5 {
            let pressure = BarometricEquations.pressureFromAltitude(altitude: altitude)
            altitude = BarometricEquations.altitudeFromPressure(pressure: pressure)
        }

        XCTAssertEqual(altitude.meters, 3500, accuracy: 1.0,
                      "Multiple round trips should not accumulate significant error")
    }

    func testBarometricEquations_KnownISAValues() {
        let altitude = Measurement<UnitLength>(meters: 5000)
        let pressure = BarometricEquations.pressureFromAltitude(altitude: altitude)
        XCTAssertEqual(pressure.pascals, 54020.5, accuracy: 0.1)

        let recoveredAlt = BarometricEquations.altitudeFromPressure(pressure: pressure)
        XCTAssertEqual(recoveredAlt.meters, 5000, accuracy: 0.1)
    }

    /// `BarometricEquations.pressureFromAltitude` always applies the single
    /// troposphere formula, even above the 11 km tropopause where the ISA
    /// model switches to an isothermal layer. `ISA.pressure(at:)` already
    /// implements the correct two-layer model (verified in the review against
    /// ICAO published pressures), so it is the ground truth here.
    ///
    /// At 15,000 m the review measured ~4% error from using the single-layer
    /// formula; this test pins the correct value to a tight tolerance so it
    /// fails against today's single-layer implementation.
    func testPressureFromAltitude_AboveTropopause_MatchesTwoLayerISA() {
        let altitude = Measurement<UnitLength>(meters: 15000)

        let correctPressure = ISA.pressure(at: altitude)
        let actualPressure = BarometricEquations.pressureFromAltitude(altitude: altitude)

        XCTAssertEqual(
            actualPressure.pascals, correctPressure.pascals, accuracy: 1,
            "Above 11km, pressureFromAltitude must switch to the isothermal stratosphere model"
        )
    }

    /// Same issue, inverse direction: `altitudeFromPressure` must recover the
    /// correct altitude for a pressure drawn from the two-layer ISA model above
    /// the tropopause, not the single-layer troposphere extrapolation.
    func testAltitudeFromPressure_AboveTropopause_MatchesTwoLayerISA() {
        let correctAltitude = Measurement<UnitLength>(meters: 15000)
        let pressureAt15km = ISA.pressure(at: correctAltitude)

        let recoveredAltitude = BarometricEquations.altitudeFromPressure(pressure: pressureAt15km)

        XCTAssertEqual(
            recoveredAltitude.meters, correctAltitude.meters, accuracy: 1,
            "Above 11km, altitudeFromPressure must switch to the isothermal stratosphere model"
        )
    }

}
