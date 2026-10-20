import XCTest
@testable import AviationMaths

final class SpeedContextTests: XCTestCase {

    func testStandardISAContext() {
        let context = SpeedContext.standardISA

        XCTAssertNotNil(context.pressureAltitude)
        XCTAssertEqual(context.pressureAltitude?.meters, 0)
        XCTAssertNotNil(context.density)
        XCTAssertNotNil(context.speedOfSound)
        XCTAssertNotNil(context.relativePressure)
    }

    func testCustomContext() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )

        XCTAssertNotNil(context.pressureAltitude)
        XCTAssertNotNil(context.density)
        XCTAssertNotNil(context.speedOfSound)
        XCTAssertNotNil(context.relativePressure)
    }

    func testDensityCalculation_SeaLevel() {
        let context = SpeedContext.standardISA

        guard let density = context.density else {
            XCTFail("Density should be calculated")
            return
        }

        XCTAssertEqual(density.value, 1.225, accuracy: 0.001)
    }

    func testDensityCalculation_10000ft() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )

        guard let density = context.density else {
            XCTFail("Density should be calculated")
            return
        }

        XCTAssertEqual(density.value, 0.9, accuracy: 0.05)
    }

    func testDensityProvidedDirectly() {
        let directDensity = Measurement<UnitConcentrationMass>(value: 0.85, unit: .gramsPerLiter)
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            density: directDensity
        )

        XCTAssertEqual(context.density!.value, 0.85, accuracy: 0.001)
    }

    func testSpeedOfSound_SeaLevel() {
        let context = SpeedContext.standardISA

        guard let speedOfSound = context.speedOfSound else {
            XCTFail("Speed of sound should be calculated")
            return
        }

        XCTAssertEqual(speedOfSound.mps, 340.294, accuracy: 0.01)
    }

    func testSpeedOfSound_10000ft() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )

        guard let speedOfSound = context.speedOfSound else {
            XCTFail("Speed of sound should be calculated")
            return
        }

        XCTAssertLessThan(speedOfSound.mps, 340.294)
        XCTAssertEqual(speedOfSound.mps, 325, accuracy: 5)
    }

    func testSpeedOfSound_HotDay() {
        let standardContext = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )

        let hotContext = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 20)
        )

        let standardSpeed = standardContext.speedOfSound!.mps
        let hotSpeed = hotContext.speedOfSound!.mps

        XCTAssertGreaterThan(hotSpeed, standardSpeed)
    }

    func testRelativePressure_SeaLevel() {
        let context = SpeedContext.standardISA

        guard let delta = context.relativePressure else {
            XCTFail("Relative pressure should be calculated")
            return
        }

        XCTAssertEqual(delta, 1.0, accuracy: 0.001)
    }

    func testRelativePressure_10000ft() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )

        guard let delta = context.relativePressure else {
            XCTFail("Relative pressure should be calculated")
            return
        }

        XCTAssertEqual(delta, 0.687, accuracy: 0.01)
    }

    func testRelativePressure_20000ft() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 20000),
            deltaISA: .init(kelvin: 0)
        )

        guard let delta = context.relativePressure else {
            XCTFail("Relative pressure should be calculated")
            return
        }

        XCTAssertEqual(delta, 0.460, accuracy: 0.01)
    }

    func testDeltaISA_Effect_OnDensity() {
        let standardContext = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )

        let hotContext = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 20)
        )

        let standardDensity = standardContext.density!.value
        let hotDensity = hotContext.density!.value

        XCTAssertLessThan(hotDensity, standardDensity)
    }

    func testDeltaISA_Effect_OnSpeedOfSound() {
        let standardContext = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )

        let hotContext = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 20)
        )

        let standardSpeed = standardContext.speedOfSound!.mps
        let hotSpeed = hotContext.speedOfSound!.mps

        XCTAssertGreaterThan(hotSpeed, standardSpeed)

        let difference = hotSpeed - standardSpeed
        XCTAssertEqual(difference, 10, accuracy: 3)
    }

    func testContextWithoutAltitude() {
        let context = SpeedContext()

        XCTAssertNil(context.pressureAltitude)
        XCTAssertNil(context.density)
        XCTAssertNil(context.speedOfSound)
        XCTAssertNil(context.relativePressure)
    }

    func testContextWithDensityButNoAltitude() {
        let context = SpeedContext(
            density: .init(value: 1.0, unit: .gramsPerLiter)
        )

        XCTAssertNil(context.pressureAltitude)
        XCTAssertNotNil(context.density)
        XCTAssertNil(context.speedOfSound)
        XCTAssertNil(context.relativePressure)

        XCTAssertEqual(context.density?.value, 1.0)
    }

    func testDensityDecreasesWithAltitude() {
        let altitudes: [Double] = [0, 5000, 10000, 20000, 30000]
        var previousDensity = Double.infinity

        for altitude in altitudes {
            let context = SpeedContext(
                pressureAltitude: .init(feet: altitude),
                deltaISA: .init(kelvin: 0)
            )

            let density = context.density!.value

            XCTAssertLessThan(density, previousDensity)
            previousDensity = density
        }
    }

    func testPressureDecreasesWithAltitude() {
        let altitudes: [Double] = [0, 5000, 10000, 20000, 30000]
        var previousDelta = Double.infinity

        for altitude in altitudes {
            let context = SpeedContext(
                pressureAltitude: .init(feet: altitude),
                deltaISA: .init(kelvin: 0)
            )

            let delta = context.relativePressure!

            XCTAssertLessThan(delta, previousDelta)
            previousDelta = delta
        }
    }

    func testSpeedOfSoundDecreasesWithAltitude() {
        let altitudes: [Double] = [0, 5000, 10000]
        var previousSpeed = Double.infinity

        for altitude in altitudes {
            let context = SpeedContext(
                pressureAltitude: .init(feet: altitude),
                deltaISA: .init(kelvin: 0)
            )

            let speed = context.speedOfSound!.mps

            XCTAssertLessThan(speed, previousSpeed)
            previousSpeed = speed
        }
    }

    func testNegativeAltitude() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: -282),
            deltaISA: .init(kelvin: 0)
        )
        XCTAssertNotNil(context.density)
        XCTAssertNotNil(context.speedOfSound)
        XCTAssertNotNil(context.relativePressure)
        XCTAssertGreaterThan(context.density!.value, 1.225)

        XCTAssertGreaterThan(context.relativePressure!, 1.0)
    }

    func testExtremeCold() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: -50)
        )

        XCTAssertNotNil(context.density)
        XCTAssertNotNil(context.speedOfSound)

        XCTAssertGreaterThan(context.density!.value, 1.0)
    }

    func testExtremeHeat() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 0),
            deltaISA: .init(kelvin: 50)
        )

        XCTAssertNotNil(context.density)
        XCTAssertNotNil(context.speedOfSound)

        XCTAssertEqual(context.density!.value, 1.04, accuracy: 0.01)
    }

    /// `SpeedContext.at(altitude:)` routes a QNH-bearing altitude through
    /// `fromQNHAndAMSL`, which builds the context via the measured-pressure
    /// initializer with `pressureAltitude: nil`. Since `speedOfSound` requires
    /// `pressureAltitude` to be non-nil (even though temperature alone is
    /// sufficient for `a = √(γRT)`), Mach conversions are unreachable for any
    /// altitude created with a QNH context — which is the common case.
    ///
    /// Correct: pressureAltitude should be derivable (QNH → ISA pressure →
    /// pressure altitude), and speedOfSound should be computable from the known
    /// temperature regardless.
    func testAtAltitude_WithQNH_ProducesPressureAltitudeAndSpeedOfSound() {
        let altitude = Altitude(value: .init(feet: 5000), reference: .amsl, context: .standardISA)

        let speedContext = SpeedContext.at(altitude: altitude)

        XCTAssertNotNil(speedContext.pressureAltitude, "QNH is known, so pressure altitude should be derivable")
        XCTAssertNotNil(speedContext.speedOfSound, "Temperature is known, so speed of sound should be derivable")
        if let pa = speedContext.pressureAltitude {
            XCTAssertEqual(pa.feet, 5000, accuracy: 1)
        }
        if let sos = speedContext.speedOfSound {
            XCTAssertEqual(sos.mps, ISA.speedOfSound(at: .init(feet: 5000)).mps, accuracy: 1)
        }
    }

    /// The context has a measured temperature of -10°C, but taken at 10,000ft
    /// AMSL (`temperatureReferenceAltitudeAMSL`), not at the aircraft's actual
    /// altitude of 5,000ft. `SpeedContext.at(altitude:)` currently prefers
    /// `ac.temperatureAtReference` unconditionally, using -10°C as if it were
    /// the temperature at 5,000ft. The correct temperature at 5,000ft, found by
    /// applying the context's own (lapse-rate-derived) temperature model via
    /// `AltitudeContext.temperature(at:)`, is +2.5°C.
    func testAtAltitude_UsesLapseAdjustedTemperature_NotRawTemperatureAtReference() {
        let context = AltitudeContext(
            groundElevation: .surface,
            qnh: ISA.seaLevelPressure,
            surfaceTemperature: ISA.seaLevelTemperature,
            temperatureReferenceAltitudeAMSL: .init(feet: 10000),
            temperatureAtReference: .init(celsius: -10),
            lapseRate: nil // derive it from the surface/reference temperature pair above
        )
        let altitude = Altitude(value: .init(feet: 5000), reference: .amsl, context: context)

        let correctTemperature = context.temperature(at: altitude.amsl)
        XCTAssertNotNil(correctTemperature, "Lapse rate should be derivable from the context above")

        let speedContext = SpeedContext.at(altitude: altitude)
        XCTAssertNotNil(speedContext.temperature)

        if let correct = correctTemperature, let actual = speedContext.temperature {
            XCTAssertEqual(actual.celsius, correct.celsius, accuracy: 0.1)
        }
    }

    func testValidatedSpeedContext_AtQNHAltitude_DoesNotThrow() throws {
        // Uses .standardISA, which is a *complete* AltitudeContext (ground
        // elevation, QNH, sea-level temperature, surface temperature and lapse
        // rate all present), so that ValidatedAltitude's own (unrelated,
        // fatalError-based) completeness check does not fire and mask H1.
        let altitude = Altitude(value: .init(feet: 5000), reference: .amsl, context: .standardISA)
        let validatedAltitude = ValidatedAltitude(altitude)

        XCTAssertNoThrow(try ValidatedSpeedContext(at: validatedAltitude))
    }

    func testAtAltitude_AboveTropopause_MatchesISA() throws {
        for feet in [39_000.0, 45_000] {
            let altitude = Altitude(feet: feet, reference: .pressureAltitude, context: .standardISA)
            let isa = ISA(altitudeFeet: feet)

            let speedContext = SpeedContext.at(altitude: altitude)

            XCTAssertEqual(
                try XCTUnwrap(speedContext.temperature).kelvin, isa.temperature.kelvin, accuracy: 0.01,
                "Temperature at PA \(feet) ft"
            )
            XCTAssertEqual(
                try XCTUnwrap(speedContext.relativePressure),
                isa.pressure.pascals / ISA.seaLevelPressure.pascals,
                accuracy: 1e-5,
                "Relative pressure at PA \(feet) ft"
            )
        }
    }
}
