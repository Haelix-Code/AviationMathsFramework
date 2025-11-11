import XCTest
@testable import AviationMaths

final class SpeedContextTests: XCTestCase {
    
    // MARK: - Basic Context Creation
    
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
    
    // MARK: - Density Calculation
    
    func testDensityCalculation_SeaLevel() {
        let context = SpeedContext.standardISA
        
        guard let density = context.density else {
            XCTFail("Density should be calculated")
            return
        }
        
        // Sea level ISA density should be 1.225 kg/m³
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
        
        // At 10,000 ft ISA, density should be ~0.9 kg/m³
        XCTAssertEqual(density.value, 0.9, accuracy: 0.05)
    }
    
    func testDensityProvidedDirectly() {
        let directDensity = Measurement<UnitConcentrationMass>(value: 0.85, unit: .gramsPerLiter)
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            density: directDensity
        )
        
        // Should use the provided density, not calculate
        XCTAssertEqual(context.density?.value, 0.85, accuracy: 0.001)
    }
    
    // MARK: - Speed of Sound Calculation
    
    func testSpeedOfSound_SeaLevel() {
        let context = SpeedContext.standardISA
        
        guard let speedOfSound = context.speedOfSound else {
            XCTFail("Speed of sound should be calculated")
            return
        }
        
        // Sea level ISA: 340.294 m/s
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
        
        // At 10,000 ft ISA, temperature is lower, so speed of sound is lower
        XCTAssertLessThan(speedOfSound.mps, 340.294)
        
        // Should be around 325 m/s (638 knots)
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
        
        // Hot day has higher speed of sound
        XCTAssertGreaterThan(hotSpeed, standardSpeed)
    }
    
    // MARK: - Relative Pressure Calculation
    
    func testRelativePressure_SeaLevel() {
        let context = SpeedContext.standardISA
        
        guard let delta = context.relativePressure else {
            XCTFail("Relative pressure should be calculated")
            return
        }
        
        // At sea level, pressure ratio should be 1.0
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
        
        // At 10,000 ft ISA, pressure ratio should be ~0.687
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
        
        // At 20,000 ft ISA, pressure ratio should be ~0.460
        XCTAssertEqual(delta, 0.460, accuracy: 0.01)
    }
    
    // MARK: - Temperature Effect Tests
    
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
        
        // Hot day has lower density
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
        
        // Hot day has higher speed of sound
        XCTAssertGreaterThan(hotSpeed, standardSpeed)
        
        // Speed of sound increases with sqrt(T)
        // ΔT = 20K, so Δa ≈ 3% (about 10 m/s)
        let difference = hotSpeed - standardSpeed
        XCTAssertEqual(difference, 10, accuracy: 2)
    }
    
    // MARK: - Context Without Altitude
    
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
    
    // MARK: - Altitude Progression Tests
    
    func testDensityDecreasesWithAltitude() {
        let altitudes: [Double] = [0, 5000, 10000, 20000, 30000]
        var previousDensity = Double.infinity
        
        for altitude in altitudes {
            let context = SpeedContext(
                pressureAltitude: .init(feet: altitude),
                deltaISA: .init(kelvin: 0)
            )
            
            let density = context.density!.value
            
            // Density should decrease with altitude
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
            
            // Pressure ratio should decrease with altitude
            XCTAssertLessThan(delta, previousDelta)
            previousDelta = delta
        }
    }
    
    func testSpeedOfSoundDecreasesWithAltitude() {
        let altitudes: [Double] = [0, 5000, 10000]  // Only in troposphere
        var previousSpeed = Double.infinity
        
        for altitude in altitudes {
            let context = SpeedContext(
                pressureAltitude: .init(feet: altitude),
                deltaISA: .init(kelvin: 0)
            )
            
            let speed = context.speedOfSound!.mps
            
            // Speed of sound decreases with altitude in troposphere
            XCTAssertLessThan(speed, previousSpeed)
            previousSpeed = speed
        }
    }
    
    // MARK: - Edge Cases
    
    func testNegativeAltitude() {
        // Below sea level (e.g., Death Valley)
        let context = SpeedContext(
            pressureAltitude: .init(feet: -282),  // Lowest point in North America
            deltaISA: .init(kelvin: 0)
        )
        
        // Should still calculate valid values
        XCTAssertNotNil(context.density)
        XCTAssertNotNil(context.speedOfSound)
        XCTAssertNotNil(context.relativePressure)
        
        // Density should be higher than sea level
        XCTAssertGreaterThan(context.density!.value, 1.225)
        
        // Pressure ratio should be greater than 1.0
        XCTAssertGreaterThan(context.relativePressure!, 1.0)
    }
    
    func testExtremeCold() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: -50)  // Very cold
        )
        
        // Should still calculate valid values
        XCTAssertNotNil(context.density)
        XCTAssertNotNil(context.speedOfSound)
        
        // Density should be much higher than standard
        XCTAssertGreaterThan(context.density!.value, 1.0)
    }
    
    func testExtremeHeat() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 0),
            deltaISA: .init(kelvin: 50)  // Very hot desert
        )
        
        // Should still calculate valid values
        XCTAssertNotNil(context.density)
        XCTAssertNotNil(context.speedOfSound)
        
        // Density should be much lower than standard
        XCTAssertLessThan(context.density!.value, 1.0)
    }
}
