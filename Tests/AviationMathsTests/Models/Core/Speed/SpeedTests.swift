import XCTest
@testable import AviationMaths

final class SpeedTests: XCTestCase {
    
    func testCAStoEAS_SeaLevel() throws {
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 200, reference: .calibratedAirspeed, context: context)
        
        XCTAssertEqual(speed.eas.knots, speed.cas.knots, accuracy: 1.0)
    }
    
    func testCAStoEAS_Altitude() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        let speed = Speed(knots: 250, reference: .calibratedAirspeed, context: context)
        
        XCTAssertGreaterThan(speed.cas.knots, speed.eas.knots)
    }
    
    func testEAStoTAS_SeaLevel() throws {
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 200, reference: .equivalentAirspeed, context: context)
        
        XCTAssertEqual(speed.tas.knots, speed.eas.knots, accuracy: 0.1)
    }
    
    func testEAStoTAS_Altitude() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        let speed = Speed(knots: 200, reference: .equivalentAirspeed, context: context)
        
        XCTAssertGreaterThan(speed.tas.knots, speed.eas.knots)
        
        let expectedRatio = 1.164
        let actualRatio = speed.tas.knots / speed.eas.knots
        XCTAssertEqual(actualRatio, expectedRatio, accuracy: 0.02)
    }
    
    func testTAStoMach() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        let speed = Speed(knots: 319, reference: .trueAirspeed, context: context)
        
        XCTAssertEqual(speed.mach, 0.5, accuracy: 0.01)
    }
    
    func testMachToTAS() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        let speed = Speed(mach: 0.5, context: context)
        
        XCTAssertEqual(speed.tas.knots, 319, accuracy: 2.0)
    }
    
    // MARK: - Compressibility Effect Tests (per aerotoolbox.com)
    
    func testCompressibilityBelow200Knots() throws {
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
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        let speed = Speed(knots: 300, reference: .calibratedAirspeed, context: context)
        
        let difference = abs(speed.eas.knots - speed.cas.knots)
        XCTAssertEqual(difference, 3.42, accuracy: 0.1)
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
        
        let mach = speed.mach
        let speedFromMach = Speed(mach: mach, context: context)
        
        XCTAssertEqual(speedFromMach.cas.knots, originalCAS, accuracy: 0.5)
    }
    

    func testHotDayEffect() throws {
        let standardContext = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        let hotDayContext = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 20)
        )
        
        let cas = 250.0
        let speedStandard = Speed(knots: cas, reference: .calibratedAirspeed, context: standardContext)
        let speedHot = Speed(knots: cas, reference: .calibratedAirspeed, context: hotDayContext)
        
        XCTAssertGreaterThan(speedHot.tas.knots, speedStandard.tas.knots)
        
        XCTAssertLessThan(speedHot.mach, speedStandard.mach)
    }
    
    func testColdDayEffect() throws {
        let standardContext = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        let coldDayContext = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: -20)
        )
        
        let cas = 250.0
        let speedStandard = Speed(knots: cas, reference: .calibratedAirspeed, context: standardContext)
        let speedCold = Speed(knots: cas, reference: .calibratedAirspeed, context: coldDayContext)
        
        XCTAssertLessThan(speedCold.tas.knots, speedStandard.tas.knots)
        
        XCTAssertGreaterThan(speedCold.mach, speedStandard.mach)
    }
    
    func testCAStoTAS_10000ft() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        let speed = Speed(knots: 250, reference: .calibratedAirspeed, context: context)
        
        XCTAssertEqual(speed.tas.knots, 290, accuracy: 5.0)
    }
    
    func testMachNumberCalculation() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 0),
            deltaISA: .init(kelvin: 0)
        )
        
        let speed = Speed(knots: 330.75, reference: .trueAirspeed, context: context)
        
        XCTAssertEqual(speed.mach, 0.5, accuracy: 0.01)
    }
    
    func testSpeedUnits() throws {
        let context = SpeedContext.standardISA
        let speed = Speed(mps: 100, reference: .trueAirspeed, context: context)
        
        XCTAssertEqual(speed.tas.mps, 100)
        XCTAssertEqual(speed.tas.knots, 194.384, accuracy: 0.01)
        XCTAssertEqual(speed.tas.fps, 328.084, accuracy: 0.01)
    }
    
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
        
        let speed = Speed(mach: 0.85, context: context)
        
        XCTAssertGreaterThan(speed.tas.knots, 0)
        XCTAssertGreaterThan(speed.eas.knots, 0)
        XCTAssertGreaterThan(speed.cas.knots, 0)
        
        XCTAssertEqual(speed.tas.knots, 490, accuracy: 10)
    }
    
    func testLowSpeed() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 1000),
            deltaISA: .init(kelvin: 0)
        )
        
        let speed = Speed(knots: 65, reference: .calibratedAirspeed, context: context)
        
        XCTAssertEqual(speed.cas.knots, 65, accuracy: 0.1)
        XCTAssertEqual(speed.eas.knots, 65, accuracy: 1.0)
        XCTAssertEqual(speed.tas.knots, 65, accuracy: 2.0)
    }
    

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
        
        XCTAssertEqual(speed1, speed2)
    }
    

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
    
    
    func testStallSpeedConsistency() throws {
        // Per aerotoolbox: aircraft always stalls at same IAS/CAS regardless of altitude
        // This means CAS at different altitudes should give different TAS but same dynamic pressure
        
        let casStall = 60.0
        
        let contextSeaLevel = SpeedContext.standardISA
        let contextAltitude = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        
        let speedSeaLevel = Speed(knots: casStall, reference: .calibratedAirspeed, context: contextSeaLevel)
        let speedAltitude = Speed(knots: casStall, reference: .calibratedAirspeed, context: contextAltitude)
        
        XCTAssertEqual(speedSeaLevel.cas.knots, casStall)
        XCTAssertEqual(speedAltitude.cas.knots, casStall)
        
        XCTAssertGreaterThan(speedAltitude.tas.knots, speedSeaLevel.tas.knots)
        
        XCTAssertEqual(speedSeaLevel.eas.knots, speedAltitude.eas.knots, accuracy: 0.5)
    }
    
    func testAltitudeEffectOnTAS() throws {
        let cas = 250.0
        
        let altitudes: [Double] = [0, 5000, 10000, 20000, 30000]
        var previousTAS = 0.0
        
        for altitude in altitudes {
            let context = SpeedContext(
                pressureAltitude: .init(feet: altitude),
                deltaISA: .init(kelvin: 0)
            )
            let speed = Speed(knots: cas, reference: .calibratedAirspeed, context: context)
            let tas = speed.tas.knots
            
            if altitude > 0 {
                XCTAssertGreaterThan(tas, previousTAS, "TAS should increase with altitude")
            }
            
            previousTAS = tas
        }
    }
}
