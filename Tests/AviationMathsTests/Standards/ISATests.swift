import XCTest
@testable import AviationMaths

final class ISATests: XCTestCase {
    func testISAAtSeaLevel() {
        let isa = ISA(altitudeMeters: 0)

        XCTAssertEqual(isa.temperature.kelvin, 288.15, accuracy: 0.01)
        XCTAssertEqual(isa.pressure.pascals, 101325.0)
        XCTAssertEqual(isa.density.value, 1.225, accuracy: 0.001)
        XCTAssertEqual(isa.densityAltitude.value, 0, accuracy: 1)
        XCTAssertEqual(isa.relativeDensity, 1.0, accuracy: 0.001)
        XCTAssertEqual(isa.speedOfSound.value, 340.294, accuracy: 0.01)
        XCTAssertEqual(isa.lapseRate, 0.0065)
    }

    func testAt5000Meters_NoDeltaISA() {
        let isa = ISA(altitudeMeters: 5000)
        XCTAssertEqual(isa.temperature.kelvin, 255.65, accuracy: 0.01)
        XCTAssertEqual(isa.pressure.pascals, 54019.89, accuracy: 0.01)
        XCTAssertEqual(isa.density.value, 0.73612, accuracy: 0.001)
        XCTAssertEqual(isa.densityAltitude.value, 5000, accuracy: 1)
        XCTAssertEqual(isa.relativeDensity, 0.600911, accuracy: 0.001)
        XCTAssertEqual(isa.speedOfSound.value, 320.53, accuracy: 0.01)
        XCTAssertEqual(isa.lapseRate, 0.0065)
    }

    func testAt20000Meters_NoDeltaISA() {
        let isa = ISA(altitudeMeters: 20000)
        XCTAssertEqual(isa.temperature.kelvin, 216.65, accuracy: 0.01)
        XCTAssertEqual(isa.pressure.pascals, 5474.88, accuracy: 0.01)
        XCTAssertEqual(isa.density.value, 0.08803, accuracy: 0.001)
        XCTAssertEqual(isa.densityAltitude.value, 20000)
        XCTAssertEqual(isa.relativeDensity, 0.071865, accuracy: 0.001)
        XCTAssertEqual(isa.speedOfSound.value, 295.07, accuracy: 0.01)
        // 20 km is the base of the ICAO 20–32 km layer (+1 K/km), which starts AT its base
        XCTAssertEqual(isa.lapseRate, -0.001)
    }

    func testSeaLevel_DeltaISA() {
        let isa = ISA(altitudeMeters: 0, deltaISA: 20)
        XCTAssertEqual(isa.temperature.kelvin, 308.15, accuracy: 0.01)
        XCTAssertEqual(isa.pressure.pascals, 101325, accuracy: 0.01)
        XCTAssertEqual(isa.density.value, 1.14549, accuracy: 0.001)
        XCTAssertEqual(isa.densityAltitude.value, 693.51, accuracy: 0.1)
        XCTAssertEqual(isa.relativeDensity, 0.935097, accuracy: 0.001)
        XCTAssertEqual(isa.speedOfSound.value, 351.91, accuracy: 0.01)
        XCTAssertEqual(isa.lapseRate, 0.0065)
    }

    func testAt5000Meters_DeltaISA() {
        let isa = ISA(altitudeMeters: 5000, deltaISA: 20)
        XCTAssertEqual(isa.temperature.kelvin, 275.65, accuracy: 0.01)
        XCTAssertEqual(isa.pressure.pascals, 54019.89, accuracy: 0.01)
        XCTAssertEqual(isa.density.value, 0.68271, accuracy: 0.001)
        XCTAssertEqual(isa.densityAltitude.value, 5689.97, accuracy: 0.01)
        XCTAssertEqual(isa.relativeDensity, 0.557311, accuracy: 0.001)
        XCTAssertEqual(isa.speedOfSound.value, 332.83, accuracy: 0.01)
        XCTAssertEqual(isa.lapseRate, 0.0065)
    }

    func testAt20000Meters_DeltaISA() {
        let isa = ISA(altitudeMeters: 20000, deltaISA: 20)
        XCTAssertEqual(isa.temperature.kelvin, 236.65, accuracy: 0.01)
        XCTAssertEqual(isa.pressure.pascals, 5474.88, accuracy: 0.01)
        XCTAssertEqual(isa.density.value, 0.08059, accuracy: 0.001)
        // Lands in the ICAO 20–32 km layer (+1 K/km), not an extrapolated isothermal layer
        XCTAssertEqual(isa.densityAltitude.value, 20544.73, accuracy: 0.1)
        XCTAssertEqual(isa.relativeDensity, 0.065792, accuracy: 0.001)
        XCTAssertEqual(isa.speedOfSound.value, 308.39, accuracy: 0.01)
        XCTAssertEqual(isa.lapseRate, -0.001)
    }

    func testTropopauseBoundary() {
        let below = ISA(altitudeMeters: 10999)
        let at = ISA(altitudeMeters: 11000)
        let above = ISA(altitudeMeters: 11001)

        XCTAssertEqual(below.lapseRate, 0.0065)
        // At exactly 11,000 m, `temperature`/`pressure` already treat this as the
        // isothermal lower-stratosphere layer (see the `.kelvin` assertion below);
        // `lapseRate` must agree rather than reporting the troposphere rate.
        XCTAssertEqual(at.lapseRate, 0)
        XCTAssertEqual(above.lapseRate, 0)
        XCTAssertEqual(at.temperature.kelvin, 216.65, accuracy: 0.0001)
    }

    func testStaticTemperatureWithDeltaISA() {
        let altitude = Measurement(value: 5000, unit: UnitLength.meters)
        let delta = Measurement(value: 10, unit: UnitTemperature.kelvin)
        let temp = ISA.temperature(at: altitude, deltaISA: delta)

        XCTAssertEqual(temp.kelvin, 265.65, accuracy: 0.01)
    }

    func testStaticPressureMethod() {
        let altitude = Measurement(value: 11000, unit: UnitLength.meters)
        let pressure = ISA.pressure(at: altitude)

        XCTAssertEqual(pressure.value, 22632, accuracy: 1)
    }

    func testStaticDensityMethod() {
        let altitude = Measurement(value: 5000, unit: UnitLength.meters)
        let density = ISA.density(at: altitude)

        XCTAssertEqual(density.value, 0.7361, accuracy: 0.001)
    }

    func testStaticRelativeDensityMethod() {
        let altitude = Measurement(value: 5000, unit: UnitLength.meters)
        let relativeDensity = ISA.relativeDensity(at: altitude)

        XCTAssertEqual(relativeDensity, 0.6009, accuracy: 0.001)
    }

    func testStaticSpeedOfSoundMethod() {
        let altitude = Measurement(value: 0, unit: UnitLength.meters)
        let speed = ISA.speedOfSound(at: altitude)

        XCTAssertEqual(speed.value, 340.294, accuracy: 0.01)
    }

    func testPressureAboveSeaLevel_AtTropopause_Exactly() {
        let exactlyAt = ISA(altitudeMeters: 11000, deltaISA: 0)

        XCTAssertEqual(exactlyAt.pressure.pascals, 22632.04, accuracy: 0.1,
                       "Pressure at tropopause should match ISA standard")

        XCTAssertEqual(exactlyAt.temperature.kelvin, 216.65, accuracy: 0.01,
                       "Temperature at tropopause should be 216.65K")
    }

    func testPressureAboveSeaLevel_TropopauseBoundary_Continuity() {
        // Test continuity across the tropopause boundary
        let justBelow = ISA(altitudeMeters: 10999, deltaISA: 0)
        let exactly = ISA(altitudeMeters: 11000, deltaISA: 0)
        let justAbove = ISA(altitudeMeters: 11001, deltaISA: 0)

        let diffBelow = abs(justBelow.pressure.pascals - exactly.pressure.pascals)
        let diffAbove = abs(exactly.pressure.pascals - justAbove.pressure.pascals)

        XCTAssertLessThan(diffBelow, 10,
                          "Pressure should be continuous approaching tropopause from below")
        XCTAssertLessThan(diffAbove, 10,
                          "Pressure should be continuous leaving tropopause")

        XCTAssertEqual(justBelow.temperature.kelvin, exactly.temperature.kelvin, accuracy: 0.1)
    }

    func testISA_ExactlyAtTropopause() {
        let isa = ISA(altitudeMeters: 11000, deltaISA: 0)

        XCTAssertEqual(isa.temperature.kelvin, 216.65, accuracy: 0.01)
        XCTAssertEqual(isa.pressure.pascals, 22632.1, accuracy: 1.0)
        XCTAssertEqual(isa.density.value, 0.36392, accuracy: 0.00001)
    }

    func testDensityCalculation_ConsistentWithPressureAndTemperature() {
        let isa = ISA(altitudeMeters: 5000, deltaISA: 0)

        let calculatedDensity = isa.pressure.pascals / (ISA.dryAirGasConstant * isa.temperature.kelvin)

        XCTAssertEqual(isa.density.value, calculatedDensity, accuracy: 0.0001,
                       "Density should equal P/(R×T)")
    }

    /// The ICAO / ESDU 77022 gas constant is 287.05287 J/(kg·K). With it, the
    /// lower-stratosphere pressure decays as exp(−4.806346e-5 × Δh_ft), which agrees with
    /// the ESDU figure in the ETPS notes (4.80634e-5, quoted to 6 figures); 287.058 gives
    /// 4.80626e-5.
    func testLowerStratospherePressureExponent_MatchesESDU77022() {
        let at40000ft = ISA(altitudeFeet: 40_000).pressure.pascals
        let at60000ft = ISA(altitudeFeet: 60_000).pressure.pascals

        let exponentPerFoot = log(at40000ft / at60000ft) / 20_000

        XCTAssertEqual(exponentPerFoot, 4.80634e-5, accuracy: 1e-10)
    }

    /// The published sea-level speed of sound (340.294 m/s) must agree with √(γ·R·T₀),
    /// which it only does with the ICAO gas constant.
    func testSeaLevelSpeedOfSound_ConsistentWithGasConstant() {
        let computed = sqrt(ISA.ratioSpecificHeats * ISA.dryAirGasConstant * ISA.seaLevelTemperature.kelvin)

        XCTAssertEqual(computed, ISA.seaLevelSpeedOfSound.mps, accuracy: 0.0005)
    }

}
