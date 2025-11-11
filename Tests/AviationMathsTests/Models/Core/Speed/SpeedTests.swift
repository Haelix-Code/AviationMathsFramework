import XCTest
@testable import AviationMaths

final class SpeedTests: XCTestCase {
    
    // MARK: - Basic Conversion Tests
    
    func testCAStoEAS_SeaLevel() throws {
        // At sea level, CAS ≈ EAS (minimal compressibility)
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 200, reference: .calibratedAirspeed, context: context)
        
        // Should be very close at sea level
        XCTAssertEqual(speed.eas.knots, speed.cas.knots, accuracy: 1.0)
    }
    
    func testCAStoEAS_Altitude() throws {
        // At altitude, compressibility becomes significant
        // Per aerotoolbox.com: divergence above 200 kts and 10,000 ft
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        let speed = Speed(knots: 250, reference: .calibratedAirspeed, context: context)
        
        // EAS should be higher than CAS at altitude due to compressibility
        XCTAssertGreaterThan(speed.eas.knots, speed.cas.knots)
    }
    
    func testEAStoTAS_SeaLevel() throws {
        // At sea level, EAS ≈ TAS (standard density)
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 200, reference: .equivalentAirspeed, context: context)
        
        XCTAssertEqual(speed.tas.knots, speed.eas.knots, accuracy: 0.1)
    }
    
    func testEAStoTAS_Altitude() throws {
        // At altitude, lower density means TAS > EAS
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        let speed = Speed(knots: 200, reference: .equivalentAirspeed, context: context)
        
        // TAS should be significantly higher than EAS at altitude
        XCTAssertGreaterThan(speed.tas.knots, speed.eas.knots)
        
        // Rough check: at 10,000 ft, density ratio is ~0.738, so TAS/EAS ≈ 1.164
        let expectedRatio = 1.164
        let actualRatio = speed.tas.knots / speed.eas.knots
        XCTAssertEqual(actualRatio, expectedRatio, accuracy: 0.02)
    }
    
    func testTAStoMach() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        // At 10,000 ft ISA, speed of sound ≈ 638 knots
        let speed = Speed(knots: 319, reference: .trueAirspeed, context: context)
        
        // Should be approximately Mach 0.5
        XCTAssertEqual(speed.mach, 0.5, accuracy: 0.01)
    }
    
    func testMachToTAS() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        let speed = Speed(mach: 0.5, context: context)
        
        // At 10,000 ft ISA, Mach 0.5 ≈ 319 knots TAS
        XCTAssertEqual(speed.tas.knots, 319, accuracy: 2.0)
    }
    
    // MARK: - Compressibility Effect Tests (per aerotoolbox.com)
    
    func testCompressibilityBelow200Knots() throws {
        // Below 200 knots, compressibility effects are minimal
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        let speed = Speed(knots: 150, reference: .calibratedAirspeed, context: context)
        
        // CAS and EAS should be very close
        let difference = abs(speed.eas.knots - speed.cas.knots)
        XCTAssertLessThan(difference, 3.0, "Compressibility should be minimal below 200 kts")
    }
    
    func testCompressibilityAbove200Knots() throws {
        // Above 200 knots at altitude, compressibility becomes significant
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        let speed = Speed(knots: 300, reference: .calibratedAirspeed, context: context)
        
        // CAS and EAS should diverge noticeably
        let difference = abs(speed.eas.knots - speed.cas.knots)
        XCTAssertGreaterThan(difference, 5.0, "Compressibility should be significant above 200 kts at altitude")
    }
    
    // MARK: - Round-Trip Conversion Tests
    
    func testCASRoundTrip() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 15000),
            deltaISA: .init(kelvin: 0)
        )
        
        let originalCAS = 250.0
        let speed = Speed(knots: originalCAS, reference: .calibratedAirspeed, context: context)
        
        // CAS → EAS → CAS
        let eas = speed.eas
        let speedFromEAS = Speed(value: eas, reference: .equivalentAirspeed, context: context)
        XCTAssertEqual(speedFromEAS.cas.knots, originalCAS, accuracy: 0.1)
    }
    
    func testEASRoundTrip() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 20000),
            deltaISA: .init(kelvin: 0)
        )
        
        let originalEAS = 200.0
        let speed = Speed(knots: originalEAS, reference: .equivalentAirspeed, context: context)
        
        // EAS → TAS → EAS
        let tas = speed.tas
        let speedFromTAS = Speed(value: tas, reference: .trueAirspeed, context: context)
        XCTAssertEqual(speedFromTAS.eas.knots, originalEAS, accuracy: 0.1)
    }
    
    func testTASRoundTrip() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        let originalTAS = 300.0
        let speed = Speed(knots: originalTAS, reference: .trueAirspeed, context: context)
        
        // TAS → Mach → TAS
        let mach = speed.mach
        let speedFromMach = Speed(mach: mach, context: context)
        XCTAssertEqual(speedFromMach.tas.knots, originalTAS, accuracy: 0.1)
    }
    
    func testFullChainRoundTrip() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 8000),
            deltaISA: .init(kelvin: 5)
        )
        
        let originalCAS = 220.0
        let speed = Speed(knots: originalCAS, reference: .calibratedAirspeed, context: context)
        
        // CAS → EAS → TAS → Mach → TAS → EAS → CAS
        let mach = speed.mach
        let speedFromMach = Speed(mach: mach, context: context)
        
        XCTAssertEqual(speedFromMach.cas.knots, originalCAS, accuracy: 0.5)
    }
    
    // MARK: - Temperature Effect Tests
    
    func testHotDayEffect() throws {
        let standardContext = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        let hotDayContext = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 20)  // ISA +20°C
        )
        
        let cas = 250.0
        let speedStandard = Speed(knots: cas, reference: .calibratedAirspeed, context: standardContext)
        let speedHot = Speed(knots: cas, reference: .calibratedAirspeed, context: hotDayContext)
        
        // On a hot day, TAS is higher for the same CAS (lower density)
        XCTAssertGreaterThan(speedHot.tas.knots, speedStandard.tas.knots)
        
        // Mach number is lower on a hot day (higher speed of sound)
        XCTAssertLessThan(speedHot.mach, speedStandard.mach)
    }
    
    func testColdDayEffect() throws {
        let standardContext = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        let coldDayContext = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: -20)  // ISA -20°C
        )
        
        let cas = 250.0
        let speedStandard = Speed(knots: cas, reference: .calibratedAirspeed, context: standardContext)
        let speedCold = Speed(knots: cas, reference: .calibratedAirspeed, context: coldDayContext)
        
        // On a cold day, TAS is lower for the same CAS (higher density)
        XCTAssertLessThan(speedCold.tas.knots, speedStandard.tas.knots)
        
        // Mach number is higher on a cold day (lower speed of sound)
        XCTAssertGreaterThan(speedCold.mach, speedStandard.mach)
    }
    
    // MARK: - Specific Test Cases
    
    func testCAStoTAS_10000ft() throws {
        // Test case at 10,000 ft ISA
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        let speed = Speed(knots: 250, reference: .calibratedAirspeed, context: context)
        
        // At 10,000 ft ISA:
        // - Density ratio ≈ 0.738
        // - Compressibility effect adds ~5-10 knots
        // Expected TAS ≈ 290 knots
        XCTAssertEqual(speed.tas.knots, 290, accuracy: 5.0)
    }
    
    func testMachNumberCalculation() throws {
        // Test that Mach number is correctly calculated as TAS/speed_of_sound
        let context = SpeedContext(
            pressureAltitude: .init(feet: 0),  // Sea level
            deltaISA: .init(kelvin: 0)
        )
        
        // At sea level ISA, speed of sound ≈ 661.5 knots
        let speed = Speed(knots: 330.75, reference: .trueAirspeed, context: context)
        
        // Should be Mach 0.5
        XCTAssertEqual(speed.mach, 0.5, accuracy: 0.01)
    }
    
    // MARK: - Unit Conversion Tests
    
    func testSpeedUnits() throws {
        let context = SpeedContext.standardISA
        let speed = Speed(mps: 100, reference: .trueAirspeed, context: context)
        
        XCTAssertEqual(speed.tas.mps, 100)
        XCTAssertEqual(speed.tas.knots, 194.384, accuracy: 0.01)
        XCTAssertEqual(speed.tas.fps, 328.084, accuracy: 0.01)
    }
    
    // MARK: - Edge Cases
    
    func testZeroSpeed() throws {
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 0, reference: .calibratedAirspeed, context: context)
        
        XCTAssertEqual(speed.cas.knots, 0)
        XCTAssertEqual(speed.eas.knots, 0)
        XCTAssertEqual(speed.tas.knots, 0)
        XCTAssertEqual(speed.mach, 0)
    }
    
    func testHighSubsonicSpeed() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 35000),
            deltaISA: .init(kelvin: 0)
        )
        
        // Mach 0.85 at cruise altitude
        let speed = Speed(mach: 0.85, context: context)
        
        // Should have valid conversions
        XCTAssertGreaterThan(speed.tas.knots, 0)
        XCTAssertGreaterThan(speed.eas.knots, 0)
        XCTAssertGreaterThan(speed.cas.knots, 0)
        
        // At 35,000 ft, Mach 0.85 should be around 490 KTAS
        XCTAssertEqual(speed.tas.knots, 490, accuracy: 10)
    }
    
    func testLowSpeed() throws {
        // Test very low speeds (e.g., approach speeds)
        let context = SpeedContext(
            pressureAltitude: .init(feet: 1000),
            deltaISA: .init(kelvin: 0)
        )
        
        let speed = Speed(knots: 65, reference: .calibratedAirspeed, context: context)
        
        // All speeds should be very close at low speed and low altitude
        XCTAssertEqual(speed.cas.knots, 65, accuracy: 0.1)
        XCTAssertEqual(speed.eas.knots, 65, accuracy: 1.0)
        XCTAssertEqual(speed.tas.knots, 65, accuracy: 2.0)
    }
    
    // MARK: - Comparison Tests
    
    func testSpeedComparison() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        let speed1 = Speed(knots: 200, reference: .calibratedAirspeed, context: context)
        let speed2 = Speed(knots: 250, reference: .calibratedAirspeed, context: context)
        
        XCTAssertLessThan(speed1, speed2)
        XCTAssertGreaterThan(speed2, speed1)
    }
    
    func testSpeedEquality() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        let speed1 = Speed(knots: 250, reference: .calibratedAirspeed, context: context)
        let speed2 = Speed(knots: speed1.tas.knots, reference: .trueAirspeed, context: context)
        
        // Same TAS means equal speeds
        XCTAssertEqual(speed1, speed2)
    }
    
    // MARK: - In Method Tests
    
    func testInMethod() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        let speed = Speed(knots: 250, reference: .calibratedAirspeed, context: context)
        let tasSpeed = speed.in(.trueAirspeed)
        
        XCTAssertEqual(tasSpeed.reference, .trueAirspeed)
        XCTAssertEqual(tasSpeed.tas.knots, speed.tas.knots)
    }
    
    // MARK: - Stall Speed Principle Test (from aerotoolbox.com)
    
    func testStallSpeedConsistency() throws {
        // Per aerotoolbox: aircraft always stalls at same IAS/CAS regardless of altitude
        // This means CAS at different altitudes should give different TAS but same dynamic pressure
        
        let casStall = 60.0  // Example stall speed in CAS
        
        let contextSeaLevel = SpeedContext.standardISA
        let contextAltitude = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        let speedSeaLevel = Speed(knots: casStall, reference: .calibratedAirspeed, context: contextSeaLevel)
        let speedAltitude = Speed(knots: casStall, reference: .calibratedAirspeed, context: contextAltitude)
        
        // CAS is the same (by definition)
        XCTAssertEqual(speedSeaLevel.cas.knots, casStall)
        XCTAssertEqual(speedAltitude.cas.knots, casStall)
        
        // TAS should be different (higher at altitude)
        XCTAssertGreaterThan(speedAltitude.tas.knots, speedSeaLevel.tas.knots)
        
        // But EAS should be very similar (represents dynamic pressure)
        XCTAssertEqual(speedSeaLevel.eas.knots, speedAltitude.eas.knots, accuracy: 0.5)
    }
    
    // MARK: - Altitude Effect Tests
    
    func testAltitudeEffectOnTAS() throws {
        let cas = 250.0
        
        // Test at multiple altitudes
        let altitudes: [Double] = [0, 5000, 10000, 20000, 30000]
        var previousTAS = 0.0
        
        for altitude in altitudes {
            let context = SpeedContext(
                pressureAltitude: .init(feet: altitude),
                deltaISA: .init(kelvin: 0)
            )
            let speed = Speed(knots: cas, reference: .calibratedAirspeed, context: context)
            let tas = speed.tas.knots
            
            // TAS should increase with altitude for same CAS
            if altitude > 0 {
                XCTAssertGreaterThan(tas, previousTAS, "TAS should increase with altitude")
            }
            
            previousTAS = tas
        }
    }
}
