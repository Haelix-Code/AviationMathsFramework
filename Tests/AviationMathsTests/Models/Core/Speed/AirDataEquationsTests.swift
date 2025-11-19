import XCTest
@testable import AviationMaths

final class AirDataEquationsTests: XCTestCase {
    
    // MARK: - Impact Pressure Coefficient Tests
    
    func testImpactPressureCoefficient_Mach0() {
        let qc = AirDataEquations.impactPressureCoefficient(fromMach: 0.0)
        XCTAssertEqual(qc, 0.0, accuracy: 1e-10, "At Mach 0, qc should be 0")
    }
    
    func testImpactPressureCoefficient_Mach05() {
        let qc = AirDataEquations.impactPressureCoefficient(fromMach: 0.5)
        XCTAssertEqual(qc, 0.186, accuracy: 0.001)
    }
    
    func testImpactPressureCoefficient_Mach08() {
        let qc = AirDataEquations.impactPressureCoefficient(fromMach: 0.8)
        XCTAssertEqual(qc, 0.524, accuracy: 0.001)
    }
    
    func testMachFromQc_Zero() {
        let mach = AirDataEquations.machNumber(fromImpactPressureCoefficient: 0.0)
        XCTAssertEqual(mach, 0.0, accuracy: 1e-10)
    }
    
    func testMachFromQc_RoundTrip() {
        let originalMach = 0.75
        let qc = AirDataEquations.impactPressureCoefficient(fromMach: originalMach)
        let recoveredMach = AirDataEquations.machNumber(fromImpactPressureCoefficient: qc)
        
        XCTAssertEqual(recoveredMach, originalMach, accuracy: 1e-10)
    }
    
    func testQcRoundTrip_MultipleMach() {
        let machNumbers: [Double] = [0.1, 0.3, 0.5, 0.7, 0.85]
        
        for mach in machNumbers {
            let qc = AirDataEquations.impactPressureCoefficient(fromMach: mach)
            let recovered = AirDataEquations.machNumber(fromImpactPressureCoefficient: qc)
            XCTAssertEqual(recovered, mach, accuracy: 1e-10, "Round trip failed for Mach \(mach)")
        }
    }
    
    func testCAStoEAS_SeaLevel() {
        // At sea level (delta = 1.0), minimal difference
        let cas = Measurement<UnitSpeed>(knots: 200)
        let eas = AirDataEquations.equivalentAirspeed(
            fromCalibratedAirspeed: cas,
            relativePressure: 1.0
        )
        
        // Should be very close
        XCTAssertEqual(eas.knots, cas.knots, accuracy: 0.5)
    }
    
    
    func testEAStoCAS_RoundTrip() {
        let originalCAS = Measurement<UnitSpeed>(knots: 250)
        let delta = 0.687
        
        let eas = AirDataEquations.equivalentAirspeed(
            fromCalibratedAirspeed: originalCAS,
            relativePressure: delta
        )
        
        let recoveredCAS = AirDataEquations.calibratedAirspeed(
            fromEquivalentAirspeed: eas,
            relativePressure: delta
        )
        
        XCTAssertEqual(recoveredCAS.knots, originalCAS.knots, accuracy: 0.01)
    }
    
    func testEAStoTAS_SeaLevelDensity() {
        let eas = Measurement<UnitSpeed>(knots: 200)
        let seaLevelDensity = ISA.seaLevelDensity
        
        let tas = AirDataEquations.trueAirspeed(
            fromEquivalentAirspeed: eas,
            density: seaLevelDensity
        )
        
        XCTAssertEqual(tas.knots, eas.knots, accuracy: 0.01)
    }
    
    func testEAStoTAS_10000ft() {
        let eas = Measurement<UnitSpeed>(knots: 200)
        let density10k = Measurement<UnitConcentrationMass>(value: 0.9, unit: .gramsPerLiter)
        
        let tas = AirDataEquations.trueAirspeed(
            fromEquivalentAirspeed: eas,
            density: density10k
        )
        
        XCTAssertGreaterThan(tas.knots, eas.knots)
        
        XCTAssertEqual(tas.knots, 233, accuracy: 1.0)
    }
    
    func testTAStoEAS_RoundTrip() {
        let originalEAS = Measurement<UnitSpeed>(knots: 200)
        let density = Measurement<UnitConcentrationMass>(value: 0.9, unit: .gramsPerLiter)
        
        let tas = AirDataEquations.trueAirspeed(
            fromEquivalentAirspeed: originalEAS,
            density: density
        )
        
        let recoveredEAS = AirDataEquations.equivalentAirspeed(
            fromTrueAirspeed: tas,
            density: density
        )
        
        XCTAssertEqual(recoveredEAS.knots, originalEAS.knots, accuracy: 0.01)
    }
    
    // MARK: - Mach Number Tests
    
    func testMachFromTAS() {
        let tas = Measurement<UnitSpeed>(knots: 330.75)
        let speedOfSound = Measurement<UnitSpeed>(knots: 661.5)  // Sea level ISA
        
        let mach = AirDataEquations.machNumber(
            fromTrueAirspeed: tas,
            speedOfSound: speedOfSound
        )
        
        XCTAssertEqual(mach, 0.5, accuracy: 0.001)
    }
    
    func testTASFromMach() {
        let mach = 0.5
        let speedOfSound = Measurement<UnitSpeed>(knots: 661.5)
        
        let tas = AirDataEquations.trueAirspeed(
            fromMachNumber: mach,
            speedOfSound: speedOfSound
        )
        
        XCTAssertEqual(tas.knots, 330.75, accuracy: 0.1)
    }
    
    func testMachRoundTrip() {
        let originalTAS = Measurement<UnitSpeed>(knots: 450)
        let speedOfSound = Measurement<UnitSpeed>(knots: 600)
        
        let mach = AirDataEquations.machNumber(
            fromTrueAirspeed: originalTAS,
            speedOfSound: speedOfSound
        )
        
        let recoveredTAS = AirDataEquations.trueAirspeed(
            fromMachNumber: mach,
            speedOfSound: speedOfSound
        )
        
        XCTAssertEqual(recoveredTAS.knots, originalTAS.knots, accuracy: 0.01)
    }
    
    // MARK: - Complete Chain Tests
    
    func testCompleteConversionChain() {
        // CAS → EAS → TAS → Mach → TAS → EAS → CAS
        let originalCAS = Measurement<UnitSpeed>(knots: 250)
        let delta = 0.687  // 10,000 ft
        let density = Measurement<UnitConcentrationMass>(value: 0.9, unit: .gramsPerLiter)
        let speedOfSound = Measurement<UnitSpeed>(knots: 638)
        
        let eas = AirDataEquations.equivalentAirspeed(
            fromCalibratedAirspeed: originalCAS,
            relativePressure: delta
        )
        
        let tas = AirDataEquations.trueAirspeed(
            fromEquivalentAirspeed: eas,
            density: density
        )
        
        let mach = AirDataEquations.machNumber(
            fromTrueAirspeed: tas,
            speedOfSound: speedOfSound
        )
        
        
        let tasRecovered = AirDataEquations.trueAirspeed(
            fromMachNumber: mach,
            speedOfSound: speedOfSound
        )
        
        let easRecovered = AirDataEquations.equivalentAirspeed(
            fromTrueAirspeed: tasRecovered,
            density: density
        )
        
        let casRecovered = AirDataEquations.calibratedAirspeed(
            fromEquivalentAirspeed: easRecovered,
            relativePressure: delta
        )
        
        XCTAssertEqual(casRecovered.knots, originalCAS.knots, accuracy: 0.1)
    }
    
    
    func testImpactPressureFormula() {
        let testCases: [(mach: Double, expectedQc: Double)] = [
            (0.0, 0.0),
            (0.3, 0.0635),
            (0.6, 0.2755),
            (1.0, 0.8929),
        ]
        
        for testCase in testCases {
            let qc = AirDataEquations.impactPressureCoefficient(fromMach: testCase.mach)
            XCTAssertEqual(qc, testCase.expectedQc, accuracy: 0.001, "Failed for Mach \(testCase.mach)")
        }
    }
    
    func testDensityRatioFormula() {
        // Verify TAS = EAS · √(ρ₀/ρ)
        let eas = Measurement<UnitSpeed>(mps: 100)
        let rho = 0.7  // kg/m³
        let rho0 = 1.225  // kg/m³
        
        let tas = AirDataEquations.trueAirspeed(
            fromEquivalentAirspeed: eas,
            density: Measurement(value: rho, unit: .gramsPerLiter)
        )
        
        let expectedTAS = 100 * sqrt(rho0 / rho)
        XCTAssertEqual(tas.mps, expectedTAS, accuracy: 0.01)
    }
        
    private let seaLevelSpeedOfSound = ISA.seaLevelSpeedOfSound.mps
}
