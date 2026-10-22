import XCTest
@testable import AviationMaths

final class SpeedTests: XCTestCase {

    func testFromCAS_Standard() {
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 200, reference: .calibratedAirspeed, context: context)
        XCTAssertEqual(speed.cas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 0.302, accuracy: 0.001)
    }

    func testFromCAS_HotHigh() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 35000),
            deltaISA: .init(kelvin: 30)
        )
        let speed = Speed(knots: 200, reference: .calibratedAirspeed, context: context)
        XCTAssertEqual(speed.cas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 193.395, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 370.468, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 0.603, accuracy: 0.001)
    }

    func testFromEAS_Standard() {
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 200, reference: .equivalentAirspeed, context: context)
        XCTAssertEqual(speed.cas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 0.302, accuracy: 0.001)
    }

    func testFromEAS_HotHigh() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 35000),
            deltaISA: .init(kelvin: 30)
        )
        let speed = Speed(knots: 200, reference: .equivalentAirspeed, context: context)
        XCTAssertEqual(speed.cas.knots, 207.297, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 383.122, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 0.623, accuracy: 0.001)
    }

    func testFromTAS_Standard() {
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 200, reference: .trueAirspeed, context: context)
        XCTAssertEqual(speed.cas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 0.302, accuracy: 0.001)
    }

    func testFromTAS_HotHigh() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 35000),
            deltaISA: .init(kelvin: 30)
        )
        let speed = Speed(knots: 200, reference: .trueAirspeed, context: context)
        XCTAssertEqual(speed.cas.knots, 105.458, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 104.405, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 200.000, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 0.325, accuracy: 0.001)
    }

    func testFromMach_Standard() {
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 1, reference: .machNumber, context: context)
        XCTAssertEqual(speed.cas.knots, 661.479, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 661.479, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 661.479, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 1, accuracy: 0.001)
    }

    func testFromMach_HotHigh() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 35000),
            deltaISA: .init(kelvin: 30)
        )
        let speed = Speed(knots: 1, reference: .machNumber, context: context)
        XCTAssertEqual(speed.cas.knots, 350.025, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 320.872, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 614.666, accuracy: 0.001)
        XCTAssertEqual(speed.mach, 1, accuracy: 0.001)
    }

    func testCASRoundTrip() {
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

    func testEASRoundTrip() {
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

    func testTASRoundTrip() {
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

    func testFullChainRoundTrip() {
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

    func testSpeedUnits() {
        let context = SpeedContext.standardISA
        let speed = Speed(mps: 100, reference: .trueAirspeed, context: context)

        XCTAssertEqual(speed.tas.mps, 100)
        XCTAssertEqual(speed.tas.knots, 194.384, accuracy: 0.01)
        XCTAssertEqual(speed.tas.fps, 328.084, accuracy: 0.01)
    }

    func testZeroSpeed() {
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 0, reference: .calibratedAirspeed, context: context)

        XCTAssertEqual(speed.cas.knots, 0)
        XCTAssertEqual(speed.eas.knots, 0)
        XCTAssertEqual(speed.tas.knots, 0)
        XCTAssertEqual(speed.mach, 0)
    }

    func testSupersonicSpeed() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 35000),
            deltaISA: .init(kelvin: 0)
        )

        let speed = Speed(mach: 2.0, context: context)
        
        XCTAssertEqual(speed.cas.knots, 717.027, accuracy: 0.01)
        XCTAssertEqual(speed.eas.knots, 641.744, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 1152.838, accuracy: 0.001)
    }

    func testStratospheric() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 40000),
            deltaISA: .init(kelvin: 0)
        )

        let speed = Speed(mach: 0.89, context: context)

        XCTAssertEqual(speed.cas.knots, 273.203, accuracy: 0.001)
        XCTAssertEqual(speed.eas.knots, 253.276, accuracy: 0.001)
        XCTAssertEqual(speed.tas.knots, 510.477, accuracy: 0.001)
    }

    func testInMethod() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )

        let speed = Speed(knots: 250, reference: .calibratedAirspeed, context: context)
        let tasSpeed = speed.in(.trueAirspeed)

        XCTAssertEqual(tasSpeed.reference, .trueAirspeed)
        XCTAssertEqual(tasSpeed.tas.knots, speed.tas.knots)
    }

    func testSpeedComparison_SamePhysicalSpeed() {
        let context1 = SpeedContext(
            pressureAltitude: .init(feet: 10000),
            deltaISA: .init(kelvin: 0)
        )
        let context2 = SpeedContext(
            pressureAltitude: .init(feet: 20000),
            deltaISA: .init(kelvin: 10)
        )

        let speed1 = Speed(knots: 300, reference: .trueAirspeed, context: context1)
        let speed2 = Speed(knots: 300, reference: .trueAirspeed, context: context2)

        XCTAssertNotEqual(speed1, speed2, "Same TAS, different context")
        XCTAssertTrue(try speed1.isSameSpeed(as: speed2, tolerance: .init(mps: 1e-7)))
    }

    func testSpeedComparison_DifferentReferences() {
        let context = SpeedContext(
            pressureAltitude: .init(feet: 15000),
            deltaISA: .init(kelvin: 0)
        )

        let speedTAS = Speed(knots: 350, reference: .trueAirspeed, context: context)
        let speedCAS = Speed(knots: speedTAS.cas.knots, reference: .calibratedAirspeed, context: context)

        XCTAssertNotEqual(speedTAS, speedCAS, "Same physical speed, different stored reference")
        XCTAssertTrue(try speedTAS.isSameSpeed(as: speedCAS, tolerance: .init(mps: 1e-7)))
    }

    func testIsSameSpeedAndIsSlower_CompareTAS() throws {
        let context = SpeedContext(pressureAltitude: .init(feet: 15000), deltaISA: .init(kelvin: 0))
        let tas = Speed(knots: 350, reference: .trueAirspeed, context: context)
        let mach = Speed(mach: tas.mach, context: context)
        let faster = Speed(knots: 351, reference: .trueAirspeed, context: context)

        XCTAssertTrue(try tas.isSameSpeed(as: mach, tolerance: .init(mps: 1e-7)))
        XCTAssertFalse(try tas.isSameSpeed(as: faster, tolerance: .init(mps: 1e-7)))
        XCTAssertTrue(try tas.isSameSpeed(as: faster, tolerance: .init(knots: 2)))

        XCTAssertTrue(try tas.isSlower(than: faster))
        XCTAssertFalse(try faster.isSlower(than: tas))
        XCTAssertFalse(try tas.isSlower(than: tas))
    }

    func testIsSameSpeedAndIsSlower_Throw_WhenEitherSideCannotConvertToTAS() {
        let tas = Speed(knots: 350, reference: .trueAirspeed, context: SpeedContext())
        let mach = Speed(mach: 0.8, context: SpeedContext())
        let tolerance = Measurement<UnitSpeed>(mps: 1)

        XCTAssertThrowsError(try tas.isSameSpeed(as: mach, tolerance: tolerance))
        XCTAssertThrowsError(try mach.isSameSpeed(as: tas, tolerance: tolerance))
        XCTAssertThrowsError(try tas.isSlower(than: mach))
        XCTAssertThrowsError(try mach.isSlower(than: tas))
    }

    func testSetMembership_AgreesWithEquality_AcrossAHashBucketBoundary() {
        let context = SpeedContext.standardISA
        let a = Speed(mps: 0.49e-6, reference: .trueAirspeed, context: context)
        let b = Speed(mps: 0.51e-6, reference: .trueAirspeed, context: context)

        XCTAssertEqual(Set([a, b]).count, a == b ? 1 : 2)
    }

    func testEqualityAndHashing_DoNotTrap_WhenTheContextCannotConvert() {
        let mach = Speed(mach: 0.8, context: SpeedContext())

        XCTAssertEqual(mach, mach)
        XCTAssertEqual(Set([mach, mach]).count, 1)
    }

    func testCanConvertAndIfPossible_AgreeWithThrowingConversion_ForEveryReferenceAndContext() {
        let contexts: [(name: String, context: SpeedContext)] = [
            ("empty", SpeedContext()),
            ("temperatureOnly", SpeedContext(temperature: .init(celsius: 0))),
            ("densityOnly", SpeedContext(density: .init(value: 0.9, unit: .gramsPerLiter))),
            ("measuredPressureOnly", SpeedContext(measuredPressure: .init(hectopascals: 500))),
            ("pressureAltitude", SpeedContext(pressureAltitude: .init(feet: 10000))),
            ("standardISA", .standardISA)
        ]

        func ifPossibleIsNil(_ speed: Speed, _ target: SpeedReference) -> Bool {
            switch target {
            case .calibratedAirspeed: return speed.casIfPossible == nil
            case .equivalentAirspeed: return speed.easIfPossible == nil
            case .trueAirspeed: return speed.tasIfPossible == nil
            case .machNumber: return speed.machIfPossible == nil
            }
        }

        for (name, context) in contexts {
            for source in SpeedReference.allCases {
                let speed = source == .machNumber
                    ? Speed(mach: 0.7, context: context)
                    : Speed(knots: 250, reference: source, context: context)

                for target in SpeedReference.allCases {
                    let label = "\(name): \(source.abbreviation) → \(target.abbreviation)"
                    let succeeds = (try? speed.convertedThrowing(to: target)) != nil

                    XCTAssertEqual(speed.canConvert(to: target), succeeds, "canConvert, \(label)")
                    XCTAssertEqual(ifPossibleIsNil(speed, target), !succeeds, "IfPossible, \(label)")
                }
            }
        }
    }

    func testMach_FromCAS_NeedsOnlyPressureRatio() throws {
        let altitude = Measurement<UnitLength>(feet: 35000)
        let reference = Speed(knots: 250, reference: .calibratedAirspeed, context: SpeedContext(pressureAltitude: altitude))
        let pressureOnly = Speed(
            knots: 250,
            reference: .calibratedAirspeed,
            context: SpeedContext(measuredPressure: ISA.pressure(at: altitude))
        )

        XCTAssertEqual(try XCTUnwrap(pressureOnly.machIfPossible), reference.mach, accuracy: 1e-6)
    }
}
