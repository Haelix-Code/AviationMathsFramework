import XCTest
@testable import AviationMaths

final class SpeedTests: XCTestCase {
    
    func testFromCAS_Standard() throws {
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 200, reference: .calibratedAirspeed, context: context)
        XCTAssertEqual(speed.cas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 0.302, accuracy: 0.001)
    }
    
    func testFromCAS_HotHigh() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 35000),
            deltaISA: .init(kelvin: 30)
        )
        let speed = Speed(knots: 200, reference: .calibratedAirspeed, context: context)
        XCTAssertEqual(speed.cas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 193.396, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 370.472, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 0.603, accuracy: 0.001)
    }

    func testFromEAS_Standard() throws {
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 200, reference: .equivalentAirspeed, context: context)
        XCTAssertEqual(speed.cas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 0.302, accuracy: 0.001)
    }
    
    func testFromEAS_HotHigh() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 35000),
            deltaISA: .init(kelvin: 30)
        )
        let speed = Speed(knots: 200, reference: .equivalentAirspeed, context: context)
        XCTAssertEqual(speed.cas.knots, 207.294, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 383.121, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 0.623, accuracy: 0.001)
    }
    
    func testFromTAS_Standard() throws {
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 200, reference: .trueAirspeed, context: context)
        XCTAssertEqual(speed.cas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 0.302, accuracy: 0.001)
    }
    
    func testFromTAS_HotHigh() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 35000),
            deltaISA: .init(kelvin: 30)
        )
        let speed = Speed(knots: 200, reference: .trueAirspeed, context: context)
        XCTAssertEqual(speed.cas.knots, 105.456, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 104.405, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 0.325, accuracy: 0.001)
    }
    
    func testFromMach_Standard() throws {
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 1, reference: .machNumber, context: context)
        XCTAssertEqual(speed.cas.knots, 661.469, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 661.477, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 661.477, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 1, accuracy: 0.001)
    }
    
    func testFromMach_HotHigh() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 35000),
            deltaISA: .init(kelvin: 30)
        )
        let speed = Speed(knots: 1, reference: .machNumber, context: context)
        XCTAssertEqual(speed.cas.knots, 350.02, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 320.871, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 614.664, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 1, accuracy: 0.001)
    }
    
    func testCASRoundTrip() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 25000),
            deltaISA: .init(kelvin: 0)
        )
        
        let originalCAS = 250.0
        let speed = Speed(knots: originalCAS, reference: .calibratedAirspeed, context: context)
        
        let eas = speed.eas
        let speedFromEAS = Speed(value: eas, reference: .equivalentAirspeed, context: context)
        XCTAssertEqual(speedFromEAS.cas.knots, originalCAS, accuracy: 0.001)
    }
    
    func testEASRoundTrip() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 25000),
            deltaISA: .init(kelvin: 0)
        )
        
        let originalEAS = 200.0
        let speed = Speed(knots: originalEAS, reference: .equivalentAirspeed, context: context)
        
        let tas = speed.tas
        let speedFromTAS = Speed(value: tas, reference: .trueAirspeed, context: context)
        XCTAssertEqual(speedFromTAS.eas.knots, originalEAS, accuracy: 0.001)
    }
    
    func testTASRoundTrip() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 25000),
            deltaISA: .init(kelvin: 0)
        )
        
        let originalTAS = 300.0
        let speed = Speed(knots: originalTAS, reference: .trueAirspeed, context: context)
        
        let mach = speed.mach
        let speedFromMach = Speed(mach: mach, context: context)
        XCTAssertEqual(speedFromMach.tas.knots, originalTAS, accuracy: 0.001)
    }
    
    func testFullChainRoundTrip() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 25000),
            deltaISA: .init(kelvin: 5)
        )   
        
        let originalCAS = 400.0
        let speed = Speed(knots: originalCAS, reference: .calibratedAirspeed, context: context)
        
        let mach = speed.mach
        let speedFromMach = Speed(mach: mach, context: context)
        
        XCTAssertEqual(speedFromMach.cas.knots, originalCAS, accuracy: 0.001)
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
        
    func testSupersonicSpeed() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 35000),
            deltaISA: .init(kelvin: 0)
        )
        
        let speed = Speed(mach: 2.0, context: context)
        
        XCTAssertEqual(speed.cas.knots, 758.284, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 569.158, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 1147.136, accuracy: 0.001)
    }
    
    func testStratospheric() throws {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 40000),
            deltaISA: .init(kelvin: 0)
        )
        
        let speed = Speed(mach: 0.89, context: context)
        
        XCTAssertEqual(speed.cas.knots, 273.199, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 253.275, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 510.476, accuracy: 0.001)
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
}
