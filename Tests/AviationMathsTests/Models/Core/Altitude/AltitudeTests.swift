import XCTest
@testable import AviationMaths

final class UnitAltitudeTests: XCTestCase {
    private let standardContext: AltitudeContext = .standardISA

    func testAGLtoAMSL_SeaLevel() {
        let thisAltitude = Altitude(feet: 1000, reference: .agl, context: .standardISA)

        XCTAssertEqual(try thisAltitude.amsl.feet, 1000)
    }

    func testAGLtoAMSL() {
        let thisAltitude = Altitude(feet: 1000, reference: .agl, context: .init(groundElevation: .init(feet: 5000)))

        XCTAssertEqual(try thisAltitude.amsl.feet, 6000)
    }

    func testAGLtoPA() {
        let thisAltitude = Altitude(
            feet: 15000,
            reference: .agl,
            context: .init(groundElevation: .init(feet: 520), qnh: .init(hectopascals: 1010)))

        XCTAssertEqual(try thisAltitude.pressureAltitude.feet, 15599.3, accuracy: 0.5)
    }

    func testAGLtoTrueAltitude_Standard() {
        // From original test: test_converts_aboveGroundLevel_to_trueAlt2
        let thisAltitude = Altitude(
            feet: 5000,
            reference: .agl,
            context: .init(
                groundElevation: .init(feet: 0),
                qnh: ISA.seaLevelPressure,
                surfaceTemperature: .init(celsius: -5),
                lapseRate: ISA.troposphereLapseRate
            )
        )

        XCTAssertEqual(try thisAltitude.trueAltitude.feet, 4653, accuracy: 0.1)
    }

    func testAGLtoTrueAltitude() {
        let thisAltitude = Altitude(
            feet: 12000,
            reference: .agl,
            context: .init(
                groundElevation: .init(feet: 800),
                qnh: .init(hectopascals: 984.298),
                surfaceTemperature: .init(celsius: 13.415),
                lapseRate: ISA.troposphereLapseRate
            )
        )

        XCTAssertEqual(try thisAltitude.trueAltitude.feet, 12800, accuracy: 0.1)
    }

    func testAMSLtoAGL_SeaLevel() {
        let thisAltitude = Altitude(feet: 1000, reference: .amsl, context: .init(groundElevation: .init(feet: 1000)))

        XCTAssertEqual(try thisAltitude.agl.feet, 0, accuracy: 0.01)
    }

    func testAMSLtoAGL() {
        let thisAltitude = Altitude(feet: 6000, reference: .amsl, context: .init(groundElevation: .init(feet: 5000)))

        XCTAssertEqual(try thisAltitude.agl.feet, 1000, accuracy: 0.01)
    }

    func testAMSLtoPA_Standard() {
        let thisAltitude = Altitude(feet: 15000, reference: .amsl, context: .standardISA)

        XCTAssertEqual(try thisAltitude.pressureAltitude.feet, try thisAltitude.amsl.feet, accuracy: 0.1)
    }

    func testAMSLtoPA() {
        // From original test: test_converts_aboveMeanSeaLevel_to_pressureAltitude
        let thisAltitude = Altitude(
            feet: 15000,
            reference: .amsl,
            context: .init(groundElevation: .init(feet: 520), qnh: .init(hectopascals: 1010))
        )

        XCTAssertEqual(try thisAltitude.pressureAltitude.feet, 15079.7, accuracy: 0.5)
    }

    func testAMSLtoPANoElev() {
        let context = AltitudeContext(qnh: .init(hectopascals: 1010))

        let thisAltitude = Altitude(feet: 15000, reference: .amsl, context: context)

        XCTAssertEqual(try thisAltitude.pressureAltitude.feet, 15079.7, accuracy: 0.5)
    }

    func testAMSLtoTrueAltitude() {
        // From original test: test_converts_aboveMeanSealLEvel_to_TrueAltitude
        let thisAltitude = Altitude(
            feet: 12000,
            reference: .amsl,
            context: .init(
                groundElevation: .init(feet: 800),
                qnh: ISA.seaLevelPressure,
                surfaceTemperature: .init(celsius: 15),
                lapseRate: ISA.troposphereLapseRate
            )
        )

        XCTAssertEqual(try thisAltitude.trueAltitude.feet, 12066, accuracy: 0.1)
    }

    func testPAtoAGL_Standard() throws {
        var context = AltitudeContext.standardISA
        context = AltitudeContext(
            groundElevation: .init(feet: 5000),
            qnh: context.qnh,
            seaLevelTemperature: try context.seaLevelTemperature,
            lapseRate: context.lapseRate
        )

        let thisAltitude = Altitude(
            feet: 15000,
            reference: .pressureAltitude,
            context: context)

        XCTAssertEqual(try thisAltitude.agl.feet, 10000, accuracy: 0.1)
    }

    func testPAtoAGL() {
        // From original test: test_converts_pressureAltitude_to_aboveGroundLevel
        let thisAltitude = Altitude(
            feet: 15000,
            reference: .pressureAltitude,
            context: .init(groundElevation: .init(feet: 520), qnh: .init(hectopascals: 1010))
        )

        XCTAssertEqual(try thisAltitude.agl.feet, 14400.3, accuracy: 0.5)
    }

    func testPAtoAMSL_Standard() {
        let thisAltitude = Altitude(feet: 15000, reference: .pressureAltitude, context: .standardISA)

        XCTAssertEqual(try thisAltitude.pressureAltitude.feet, try thisAltitude.amsl.feet, accuracy: 0.1)
    }

    func testPAtoAMSL() {
        // From original test: test_converts_pressureAltitude_to_aboveMeanSeaLevel
        let thisAltitude = Altitude(
            feet: 15000,
            reference: .pressureAltitude,
            context: .init(groundElevation: .init(feet: 520), qnh: .init(hectopascals: 1010))
        )

        XCTAssertEqual(try thisAltitude.amsl.feet, 14920.3, accuracy: 0.5)
    }

    func testTrueAltitudeToAGL() {
        // From original test: test_converts_TrueAlt_to_aboveGroundLevel
        let thisAltitude = Altitude(
            feet: 4653,
            reference: .trueAltitude,
            context: .init(
                groundElevation: .init(feet: 0),
                qnh: ISA.seaLevelPressure,
                surfaceTemperature: .init(celsius: -5),
                lapseRate: ISA.troposphereLapseRate
            )
        )

        XCTAssertEqual(try thisAltitude.agl.feet, 5000, accuracy: 1)
    }

    func testLengthUnits() {
        let altitude = Altitude(meters: 1000, reference: .agl, context: standardContext)
        XCTAssertEqual(try altitude.agl.meters, 1000)
        XCTAssertEqual(try altitude.agl.feet, 3280.84, accuracy: 0.1)
    }

    func testConvertedTo() throws {
        let altitude = Altitude(feet: 5000, reference: .agl, context: .init(groundElevation: .init(feet: 1000)))

        let amslAltitude = try altitude.converted(to: .amsl)
        XCTAssertEqual(amslAltitude.value.feet, 6000)
        XCTAssertEqual(amslAltitude.reference, .amsl)
    }

    func testSeaLevelTemperatureInput() {
        // Test using sea level temperature directly
        let context = AltitudeContext(
            groundElevation: .init(feet: 800),
            qnh: ISA.seaLevelPressure,
            seaLevelTemperature: .init(celsius: 15 + (6.5/1000 * 800 * 0.3048)),  // SL temp calculated from surface
            lapseRate: ISA.troposphereLapseRate
        )

        // Should have valid surface temperature
        XCTAssertNoThrow(try context.surfaceTemperature)
        XCTAssertEqual(try context.surfaceTemperature.celsius, 15, accuracy: 0.1)
    }

    func testSurfaceTemperatureInput() {
        let context = AltitudeContext(
            groundElevation: .init(feet: 800),
            qnh: ISA.seaLevelPressure,
            surfaceTemperature: .init(celsius: 15),
            lapseRate: ISA.troposphereLapseRate
        )

        XCTAssertNoThrow(try context.seaLevelTemperature)

        let expectedSLTemp = 15 + (6.5/1000 * 800 * 0.3048)
        XCTAssertEqual(try context.seaLevelTemperature.celsius, expectedSLTemp, accuracy: 0.1)
    }

    func testCanConvertToTrueAltitude_AgreesWithThrowingConversion_WhenAlreadyTrueAltitude() {
        let incompleteContext = AltitudeContext() // no seaLevelTemperature, no lapseRate
        let altitude = Altitude(feet: 5000, reference: .trueAltitude, context: incompleteContext)

        XCTAssertTrue(altitude.canConvertToTrueAltitude, "No profile is needed: it's already true altitude")

        XCTAssertNoThrow(
            try altitude.value(in: .trueAltitude),
            "canConvertToTrueAltitude promised this would succeed"
        )
    }

    func testCanConvertToTrueAltitude_AgreesWithThrowingConversion_FromGeopotential() {
        let incompleteContext = AltitudeContext() // no seaLevelTemperature, no lapseRate
        let altitude = Altitude(feet: 5000, reference: .geopotential, context: incompleteContext)

        XCTAssertTrue(altitude.canConvertToTrueAltitude)

        XCTAssertNoThrow(
            try altitude.value(in: .trueAltitude),
            "canConvertToTrueAltitude promised this would succeed"
        )
    }

    func testEquality_DistinguishesContexts_WhenOnlyOneSideHasGroundElevation() {
        let withGround = Altitude(
            value: .init(meters: 1500),
            reference: .amsl,
            context: .init(groundElevation: .init(meters: 1000))
        )
        let withoutGround = Altitude(
            value: .init(meters: 1500),
            reference: .amsl,
            context: .init() // no ground elevation
        )

        XCTAssertNotEqual(withGround, withoutGround)
        XCTAssertEqual(Set([withGround, withoutGround]).count, 2)
    }

    func testEquality_ComparesTheStoredReference_NotTheConvertedLevel() throws {
        let context = AltitudeContext.qnhOnly(hectopascals: 1013.25, groundElevation: .init(feet: 500))
        let agl = Altitude(feet: 1000, reference: .agl, context: context)
        let amsl = Altitude(value: try agl.amsl, reference: .amsl, context: context)

        XCTAssertEqual(try agl.amsl, try amsl.amsl, "Same level")
        XCTAssertNotEqual(agl, amsl, "Different stored reference")
    }

    func testIsSameLevel_AcrossReferencesAndContexts() throws {
        let context = AltitudeContext.qnhOnly(hectopascals: 1013.25, groundElevation: .init(feet: 500))
        let otherGround = AltitudeContext.qnhOnly(hectopascals: 1013.25, groundElevation: .init(feet: 800))
        let agl = Altitude(feet: 1000, reference: .agl, context: context)
        let tolerance = Measurement<UnitLength>(meters: 1e-6)

        let amsl = Altitude(feet: 1500, reference: .amsl, context: context)
        let aglOverOtherGround = Altitude(feet: 700, reference: .agl, context: otherGround)
        let pressureAltitude = Altitude(feet: 1500, reference: .pressureAltitude, context: context)
        let oneFootHigher = Altitude(feet: 1501, reference: .amsl, context: context)

        XCTAssertTrue(try agl.isSameLevel(as: amsl, tolerance: tolerance))
        XCTAssertTrue(try agl.isSameLevel(as: aglOverOtherGround, tolerance: tolerance))
        XCTAssertTrue(try agl.isSameLevel(as: pressureAltitude, tolerance: tolerance))
        XCTAssertFalse(try agl.isSameLevel(as: oneFootHigher, tolerance: tolerance))
        XCTAssertTrue(try agl.isSameLevel(as: oneFootHigher, tolerance: .init(feet: 2)))
    }

    func testIsBelow_ComparesAMSL() throws {
        let context = AltitudeContext.qnhOnly(hectopascals: 1013.25, groundElevation: .init(feet: 500))
        let agl = Altitude(feet: 1000, reference: .agl, context: context)

        XCTAssertTrue(try agl.isBelow(Altitude(feet: 1501, reference: .amsl, context: context)))
        XCTAssertFalse(try agl.isBelow(Altitude(feet: 1500, reference: .amsl, context: context)))
        XCTAssertFalse(try agl.isBelow(Altitude(feet: 1499, reference: .amsl, context: context)))
    }

    func testIsSameLevelAndIsBelow_Throw_WhenEitherSideCannotConvertToAMSL() {
        let convertible = Altitude(feet: 1000, reference: .amsl, context: AltitudeContext())
        let pressureAltitude = Altitude(feet: 1000, reference: .pressureAltitude, context: AltitudeContext())
        let tolerance = Measurement<UnitLength>(meters: 1)

        XCTAssertThrowsError(try convertible.isSameLevel(as: pressureAltitude, tolerance: tolerance))
        XCTAssertThrowsError(try pressureAltitude.isSameLevel(as: convertible, tolerance: tolerance))
        XCTAssertThrowsError(try convertible.isBelow(pressureAltitude))
        XCTAssertThrowsError(try pressureAltitude.isBelow(convertible))
    }

    func testEquality_SameStoredValueInDifferentUnits_IsEqualAndHashesEqually() {
        let context = AltitudeContext.qnhOnly(hectopascals: 1013.25, groundElevation: .surface)
        let feet = Altitude(feet: 1000, reference: .amsl, context: context)
        let meters = Altitude(meters: 304.8, reference: .amsl, context: context)

        XCTAssertEqual(feet, meters)
        XCTAssertEqual(feet.hashValue, meters.hashValue)
    }

    func testEqualityAndHashing_DoNotTrap_WhenTheContextCannotConvert() {
        let pressureAltitude = Altitude(feet: 5000, reference: .pressureAltitude, context: AltitudeContext())

        XCTAssertEqual(pressureAltitude, pressureAltitude)
        XCTAssertEqual(Set([pressureAltitude, pressureAltitude]).count, 1)
    }

    func testConvertToAGL_FromGeopotential_MatchesTheEquivalentTrueAltitudeConversion() throws {
        let context = AltitudeContext(
            groundElevation: .init(feet: 500),
            qnh: .init(hectopascals: 1013.25),
            seaLevelTemperature: .init(celsius: 20),
            lapseRate: ISA.troposphereLapseRate
        )

        let trueAltitude = Altitude(feet: 5500, reference: .trueAltitude, context: context)
        let geopotentialEquivalent = Altitude(
            value: try trueAltitude.geopotential,
            reference: .geopotential,
            context: context
        )

        XCTAssertEqual(
            try geopotentialEquivalent.agl.feet,
            try trueAltitude.agl.feet,
            accuracy: 1e-6,
            "Geopotential → AGL must agree with the equivalent True altitude → AGL conversion"
        )
    }

    func testTrueAltitude_InStandardISA_MatchesAMSL_AboveTropopause() {
        for meters in [13_000.0, 15_000, 18_000] {
            let altitude = Altitude(meters: meters, reference: .amsl, context: .standardISA)

            XCTAssertEqual(
                try altitude.trueAltitude.meters, meters, accuracy: 0.5,
                "ISA true altitude must equal AMSL at \(meters) m"
            )
        }
    }

    func testPressureAltitude_GeopotentialRoundTrip_InNonISAContext() throws {
        let cold = AltitudeContext(
            groundElevation: .surface,
            qnh: ISA.seaLevelPressure,
            seaLevelTemperature: .init(celsius: -15),
            lapseRate: ISA.troposphereLapseRate
        )
        let pressureAltitude = Altitude(feet: 10_000, reference: .pressureAltitude, context: cold)

        let geopotential = try pressureAltitude.converted(to: .geopotential)

        XCTAssertEqual(try geopotential.pressureAltitude.feet, 10_000, accuracy: 1)
    }

    func testGeopotential_FromPressureAltitude_MatchesRouteViaTrueAltitude() {
        let cold = AltitudeContext(
            groundElevation: .surface,
            qnh: ISA.seaLevelPressure,
            seaLevelTemperature: .init(celsius: -15),
            lapseRate: ISA.troposphereLapseRate
        )
        let pressureAltitude = Altitude(feet: 10_000, reference: .pressureAltitude, context: cold)

        XCTAssertEqual(
            try pressureAltitude.geopotential.feet,
            try pressureAltitude.converted(to: .trueAltitude).geopotential.feet,
            accuracy: 1
        )
    }

    func testCanConvert_AgreesWithThrowingConversion_ForEveryReferenceAndContext() {
        for (name, context) in Self.conversionContexts {
            for source in VerticalReference.allCases {
                let altitude = Altitude(feet: 5000, reference: source, context: context)

                for target in VerticalReference.allCases {
                    XCTAssertEqual(
                        altitude.canConvert(to: target),
                        (try? altitude.value(in: target)) != nil,
                        "\(name): \(source.abbreviation) → \(target.abbreviation)"
                    )
                }
            }
        }
    }

    func testTrueAltitude_WithoutQNH_Throws() {
        let context = AltitudeContext(
            groundElevation: .init(feet: 500),
            seaLevelTemperature: .init(celsius: 15),
            lapseRate: ISA.troposphereLapseRate
        )
        let altitude = Altitude(feet: 5000, reference: .amsl, context: context)

        XCTAssertThrowsError(try altitude.value(in: .trueAltitude))
        XCTAssertNil(try? altitude.value(in: .trueAltitude))
    }

    func testAGL_AlreadyAGL_WithoutGroundElevation() throws {
        let altitude = Altitude(feet: 500, reference: .agl, context: AltitudeContext())

        XCTAssertEqual(try altitude.value(in: .agl).feet, 500)
    }

    static let conversionContexts: [(name: String, context: AltitudeContext)] = [
        ("empty", AltitudeContext()),
        ("groundOnly", AltitudeContext(groundElevation: .init(feet: 500))),
        ("qnhOnly", .qnhOnly(hectopascals: 1000, groundElevation: .init(feet: 500))),
        ("temperatureNoQNH", AltitudeContext(
            groundElevation: .init(feet: 500),
            seaLevelTemperature: .init(celsius: 15),
            lapseRate: ISA.troposphereLapseRate
        )),
        ("standardISA", .standardISA)
    ]

    func testBothTemperaturesGiven_SurfaceTakesPrecedence() throws {
        let context = AltitudeContext(
            groundElevation: .init(meters: 1000),
            surfaceTemperature: .init(celsius: 0),
            seaLevelTemperature: .init(celsius: 30),
            lapseRate: ISA.troposphereLapseRate
        )

        XCTAssertEqual(try context.surfaceTemperature.celsius, 0, accuracy: 1e-9)
        XCTAssertEqual(try context.seaLevelTemperature.celsius, 6.5, accuracy: 1e-9)
    }

    func testProperties_ReturnExactlyWhatValueInReturns_ForEveryReferenceAndContext() {
        let nonStandard = AltitudeContext(
            groundElevation: .init(feet: 800),
            qnh: .init(hectopascals: 984.298),
            surfaceTemperature: .init(celsius: 13.415),
            lapseRate: ISA.troposphereLapseRate
        )
        let contexts = Self.conversionContexts + [("nonStandard", nonStandard)]

        func property(_ altitude: Altitude, _ target: VerticalReference) throws(AltitudeConversionError)
            -> Measurement<UnitLength> {
            switch target {
            case .agl: return try altitude.agl
            case .amsl: return try altitude.amsl
            case .pressureAltitude: return try altitude.pressureAltitude
            case .trueAltitude: return try altitude.trueAltitude
            case .geopotential: return try altitude.geopotential
            }
        }

        for (name, context) in contexts {
            for source in VerticalReference.allCases {
                let altitude = Altitude(feet: 5000, reference: source, context: context)

                for target in VerticalReference.allCases {
                    let label = "\(name): \(source.abbreviation) → \(target.abbreviation)"
                    let expected = Result { () throws(AltitudeConversionError) in try altitude.value(in: target) }
                    let actual = Result { () throws(AltitudeConversionError) in try property(altitude, target) }

                    switch (expected, actual) {
                    case let (.success(e), .success(a)):
                        XCTAssertEqual(a.value.bitPattern, e.value.bitPattern, label)
                        XCTAssertEqual(a.unit, e.unit, label)
                    case let (.failure(e), .failure(a)):
                        XCTAssertEqual(a, e, label)
                    default:
                        XCTFail("\(label): property \(actual), value(in:) \(expected)")
                    }
                }
            }
        }
    }

    func testProperties_ThrowTheConversionError_InsteadOfTrapping() {
        let pressureAltitude = Altitude(feet: 5000, reference: .pressureAltitude, context: AltitudeContext())
        let amsl = Altitude(feet: 5000, reference: .amsl, context: AltitudeContext())

        XCTAssertThrowsError(try pressureAltitude.amsl) { XCTAssertEqual($0 as? AltitudeConversionError, .missingQNH) }
        XCTAssertThrowsError(try amsl.agl) { XCTAssertEqual($0 as? AltitudeConversionError, .missingGroundElevation) }
        XCTAssertThrowsError(try amsl.pressureAltitude) { XCTAssertEqual($0 as? AltitudeConversionError, .missingQNH) }
        XCTAssertThrowsError(try amsl.trueAltitude) {
            XCTAssertEqual($0 as? AltitudeConversionError, .missingTemperatureProfile)
        }
        XCTAssertThrowsError(try amsl.geopotential) {
            XCTAssertEqual($0 as? AltitudeConversionError, .missingTemperatureProfile)
        }
    }

    func testConverted_ThrowsTheConversionError_InsteadOfTrapping() {
        let amsl = Altitude(feet: 5000, reference: .amsl, context: AltitudeContext())

        XCTAssertThrowsError(try amsl.converted(to: .pressureAltitude)) {
            XCTAssertEqual($0 as? AltitudeConversionError, .missingQNH)
        }
    }

    func testContextTemperatures_Throw_WhenTheyCannotBeCalculated() {
        XCTAssertThrowsError(try AltitudeContext().surfaceTemperature)
        XCTAssertThrowsError(try AltitudeContext().seaLevelTemperature)
    }

    func testValidatedContext_ThrowsForAnIncompleteContext_InsteadOfTrapping() {
        let missingQNH = AltitudeContext(
            groundElevation: .init(feet: 500),
            seaLevelTemperature: .init(celsius: 15),
            lapseRate: ISA.troposphereLapseRate
        )

        XCTAssertThrowsError(try ValidatedAltitudeContext(missingQNH)) {
            XCTAssertEqual($0 as? AltitudeConversionError, .missingQNH)
        }
        XCTAssertThrowsError(try ValidatedAltitude(Altitude(feet: 1000, reference: .amsl, context: missingQNH))) {
            XCTAssertEqual($0 as? AltitudeConversionError, .missingQNH)
        }
    }
}
