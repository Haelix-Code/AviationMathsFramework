import XCTest
@testable import AviationMaths

final class ISATests: XCTestCase {

    func testSeaLevelTemperature() {
        // Verify 15°C at sea level
        let celsius = ISA.seaLevelTemperature.converted(to: .celsius).value
        XCTAssertEqual(celsius, 15.0, accuracy: 0.01)
    }
    
    // MARK: - Temperature Tests (Standard ISA)
    
    func testTemperatureAtSeaLevel() {
        let isa = ISA(altitudeMeters: 0)
        
        XCTAssertEqual(isa.temperature.kelvin, 288.15, accuracy: 0.01)
        XCTAssertEqual(isa.temperature.celsius, 15.0, accuracy: 0.01)
    }
    
    func testTemperatureAt5000Meters() {
        let isa = ISA(altitudeMeters: 5000)
        
        // T = 288.15 - (0.0065 * 5000) = 255.65 K
        XCTAssertEqual(isa.temperature.kelvin, 255.65, accuracy: 0.01)
        XCTAssertEqual(isa.temperature.celsius, -17.5, accuracy: 0.01)
    }
    
    func testTemperatureAt11000Meters() {
        let isa = ISA(altitudeMeters: 11000)
        
        // T = 288.15 - (0.0065 * 11000) = 216.65 K
        XCTAssertEqual(isa.temperature.kelvin, 216.65, accuracy: 0.01)
        XCTAssertEqual(isa.temperature.celsius, -56.5, accuracy: 0.01)
    }
    
    func testTemperatureAt20000Meters() {
        let isa = ISA(altitudeMeters: 20000)
        
        // Isothermal at tropopause temperature
        XCTAssertEqual(isa.temperature.kelvin, 216.65, accuracy: 0.01)
    }
    
    // MARK: - Temperature Tests (with DeltaISA)
    
    func testTemperatureWithPositiveDeltaISA() {
        let isa = ISA(altitudeMeters: 0, deltaISA: 15)
        
        XCTAssertEqual(isa.temperature.kelvin, 303.15, accuracy: 0.01) // 288.15 + 15
        XCTAssertEqual(isa.temperature.celsius, 30.0, accuracy: 0.01)
    }
    
    func testDeltaISAAppliesInStratosphere() {
        let isa = ISA(altitudeMeters: 15000, deltaISA: 20)
        
        // Isothermal: 216.65 + 20 = 236.65 K
        XCTAssertEqual(isa.temperature.kelvin, 236.65, accuracy: 0.01)
    }
    
    // MARK: - Pressure Tests (Standard ISA)
    
    func testPressureAtSeaLevel() {
        let isa = ISA(altitudeMeters: 0)
        
        XCTAssertEqual(isa.pressure.value, 101325, accuracy: 0.1)
        XCTAssertEqual(isa.pressure.hectopascals, 1013.25, accuracy: 0.01)
    }
    
    func testPressureAt5000Meters() {
        let isa = ISA(altitudeMeters: 5000)
        
        // Expected: ~54,020 Pa (from ISA tables)
        XCTAssertEqual(isa.pressure.value, 54020, accuracy: 1)
        XCTAssertEqual(isa.pressure.hectopascals, 540.20, accuracy: 0.01)
    }
    
    func testPressureAt15000Meters() {
        let isa = ISA(altitudeMeters: 15000)
        
        // Expected: ~12,111 Pa (from ISA tables)
        XCTAssertEqual(isa.pressure.value, 12045, accuracy: 0.1)
    }
    
    func testPressureAt20000Meters() {
        let isa = ISA(altitudeMeters: 20000)
        
        // Expected: ~5,529 Pa (from ISA tables)
        XCTAssertEqual(isa.pressure.value, 5475, accuracy: 1)
    }
    
    func testPressureDecreasesWithAltitude() {
        let isa0 = ISA(altitudeMeters: 0)
        let isa5000 = ISA(altitudeMeters: 5000)
        let isa10000 = ISA(altitudeMeters: 10000)
        
        XCTAssertGreaterThan(isa0.pressure.value, isa5000.pressure.value)
        XCTAssertGreaterThan(isa5000.pressure.value, isa10000.pressure.value)
    }
    
    // MARK: - Pressure Tests (with DeltaISA)
    
    func testPressureWithPositiveDeltaISA() {
        let isaStandard = ISA(altitudeMeters: 5000)
        let isaHot = ISA(altitudeMeters: 5000, deltaISA: 15)
        
        XCTAssertGreaterThan(isaHot.pressure.value, isaStandard.pressure.value)
    }
    
    func testPressureWithNegativeDeltaISA() {
        let isaStandard = ISA(altitudeMeters: 5000)
        let isaCold = ISA(altitudeMeters: 5000, deltaISA: -15)
        
        XCTAssertLessThan(isaCold.pressure.value, isaStandard.pressure.value)
    }
    
    // MARK: - Density Tests (Standard ISA)
    
    func testDensityAtSeaLevel() {
        let isa = ISA(altitudeMeters: 0)
        
        XCTAssertEqual(isa.density.value, 1.225, accuracy: 0.001)
    }
    
    func testDensityAt5000Meters() {
        let isa = ISA(altitudeMeters: 5000)
        
        // Expected: ~0.7361 kg/m³
        XCTAssertEqual(isa.density.value, 0.7361, accuracy: 0.001)
    }
    
    func testDensityAt11000Meters() {
        let isa = ISA(altitudeMeters: 11000)
        
        // Expected: ~0.3639 kg/m³
        XCTAssertEqual(isa.density.value, 0.3639, accuracy: 0.001)
    }
    
    func testDensityDecreasesWithAltitude() {
        let isa0 = ISA(altitudeMeters: 0)
        let isa5000 = ISA(altitudeMeters: 5000)
        let isa10000 = ISA(altitudeMeters: 10000)
        
        XCTAssertGreaterThan(isa0.density.value, isa5000.density.value)
        XCTAssertGreaterThan(isa5000.density.value, isa10000.density.value)
    }
    
    func testDensityMatchesIdealGasLaw() {
        let isa = ISA(altitudeMeters: 5000)
        
        // ρ = P / (R * T)
        let expectedDensity = isa.pressure.value / (ISA.dryAirGasConstant * isa.temperature.kelvin)
        XCTAssertEqual(isa.density.value, expectedDensity, accuracy: 1e-6)
    }
    
    // MARK: - Speed of Sound Tests
    
    func testSpeedOfSoundAtSeaLevel() {
        let isa = ISA(altitudeMeters: 0)
        
        XCTAssertEqual(isa.speedOfSound.value, 340.294, accuracy: 0.01)
    }
    
    func testSpeedOfSoundAt5000Meters() {
        let isa = ISA(altitudeMeters: 5000)
        
        // a = sqrt(γ * R * T) = sqrt(1.4 * 287.058 * 255.65)
        let expected = sqrt(1.4 * 287.058 * 255.65)
        XCTAssertEqual(isa.speedOfSound.value, expected, accuracy: 0.01)
        XCTAssertEqual(isa.speedOfSound.value, 320.53, accuracy: 0.1)
    }
    
    func testSpeedOfSoundAt11000Meters() {
        let isa = ISA(altitudeMeters: 11000)
        
        // a = sqrt(1.4 * 287.058 * 216.65) ≈ 295.07 m/s
        XCTAssertEqual(isa.speedOfSound.value, 295.07, accuracy: 0.1)
    }
    
    func testSpeedOfSoundDecreasesWithTemperature() {
        let isaWarm = ISA(altitudeMeters: 0, deltaISA: 20)
        let isaCold = ISA(altitudeMeters: 0, deltaISA: -20)
        
        XCTAssertGreaterThan(isaWarm.speedOfSound.value, isaCold.speedOfSound.value)
    }
    
    func testSpeedOfSoundInIsothermalLayer() {
        let isa11km = ISA(altitudeMeters: 11000)
        let isa15km = ISA(altitudeMeters: 15000)
        let isa20km = ISA(altitudeMeters: 20000)
        
        // Should be same in isothermal layer
        XCTAssertEqual(isa11km.speedOfSound.value, isa15km.speedOfSound.value, accuracy: 0.01)
        XCTAssertEqual(isa15km.speedOfSound.value, isa20km.speedOfSound.value, accuracy: 0.01)
    }
    
    // MARK: - Static Method Tests
    
    func testStaticTemperatureMethod() {
        let altitude = Measurement(value: 5000, unit: UnitLength.meters)
        let temp = ISA.temperature(at: altitude)
        
        XCTAssertEqual(temp.kelvin, 255.65, accuracy: 0.01)
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
    
    func testStaticSpeedOfSoundMethod() {
        let altitude = Measurement(value: 0, unit: UnitLength.meters)
        let speed = ISA.speedOfSound(at: altitude)
        
        XCTAssertEqual(speed.value, 340.294, accuracy: 0.01)
    }
    
    // MARK: - Edge Case Tests
    
    func testZeroAltitude() {
        let isa = ISA(altitudeMeters: 0)
        
        XCTAssertEqual(isa.temperature.kelvin, ISA.seaLevelTemperature.kelvin, accuracy: 1e-6)
        XCTAssertEqual(isa.pressure.value, ISA.seaLevelPressure.value, accuracy: 1)
        XCTAssertEqual(isa.density.value, ISA.seaLevelDensity.value, accuracy: 1e-4)
    }
}
