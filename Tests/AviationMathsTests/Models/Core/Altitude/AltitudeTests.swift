import XCTest
@testable import AviationMaths

final class UnitAltitudeTests: XCTestCase {
    private let standardContext: AltitudeContext = .standardISA

    func testAGLtoAMSL_SeaLevel() {
        let thisAltitude = Altitude(feet: 1000, reference: .agl, context: .standardISA)

        XCTAssertEqual(thisAltitude.amsl.feet, 1000)
    }

    func testAGLtoAMSL() {
        let thisAltitude = Altitude(feet: 1000, reference: .agl, context: .init(groundElevation: .init(feet: 5000)))

        XCTAssertEqual(thisAltitude.amsl.feet, 6000)
    }

    func testAGLtoPA() {
        let thisAltitude = Altitude(
            feet: 15000,
            reference: .agl,
            context: .init(groundElevation: .init(feet: 520), qnh: .init(hectopascals: 1010)))

        XCTAssertEqual(thisAltitude.pressureAltitude.feet, 15599.3, accuracy: 0.5)
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

        XCTAssertEqual(thisAltitude.trueAltitude.feet, 4653, accuracy: 0.1)
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

        XCTAssertEqual(thisAltitude.trueAltitude.feet, 12800, accuracy: 0.1)
    }

    func testAMSLtoAGL_SeaLevel() {
        let thisAltitude = Altitude(feet: 1000, reference: .amsl, context: .init(groundElevation: .init(feet: 1000)))

        XCTAssertEqual(thisAltitude.agl.feet, 0, accuracy: 0.01)
    }

    func testAMSLtoAGL() {
        let thisAltitude = Altitude(feet: 6000, reference: .amsl, context: .init(groundElevation: .init(feet: 5000)))

        XCTAssertEqual(thisAltitude.agl.feet, 1000, accuracy: 0.01)
    }

    func testAMSLtoPA_Standard() {
        let thisAltitude = Altitude(feet: 15000, reference: .amsl, context: .standardISA)

        XCTAssertEqual(thisAltitude.pressureAltitude.feet, thisAltitude.amsl.feet, accuracy: 0.1)
    }

    func testAMSLtoPA() {
        // From original test: test_converts_aboveMeanSeaLevel_to_pressureAltitude
        let thisAltitude = Altitude(
            feet: 15000,
            reference: .amsl,
            context: .init(groundElevation: .init(feet: 520), qnh: .init(hectopascals: 1010))
        )

        XCTAssertEqual(thisAltitude.pressureAltitude.feet, 15079.7, accuracy: 0.5)
    }

    func testAMSLtoPANoElev() {
        let context = AltitudeContext(qnh: .init(hectopascals: 1010))

        let thisAltitude = Altitude(feet: 15000, reference: .amsl, context: context)

        XCTAssertEqual(thisAltitude.pressureAltitude.feet, 15079.7, accuracy: 0.5)
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

        XCTAssertEqual(thisAltitude.trueAltitude.feet, 12066, accuracy: 0.1)
    }

    func testPAtoAGL_Standard() {
        var context = AltitudeContext.standardISA
        context = AltitudeContext(
            groundElevation: .init(feet: 5000),
            qnh: context.qnh,
            seaLevelTemperature: context.seaLevelTemperature,
            lapseRate: context.lapseRate
        )
        
        let thisAltitude = Altitude(
            feet: 15000,
            reference: .pressureAltitude,
            context: context)

        XCTAssertEqual(thisAltitude.agl.feet, 10000, accuracy: 0.1)
    }

    func testPAtoAGL() {
        // From original test: test_converts_pressureAltitude_to_aboveGroundLevel
        let thisAltitude = Altitude(
            feet: 15000,
            reference: .pressureAltitude,
            context: .init(groundElevation: .init(feet: 520), qnh: .init(hectopascals: 1010))
        )

        XCTAssertEqual(thisAltitude.agl.feet, 14400.3, accuracy: 0.5)
    }

    func testPAtoAMSL_Standard() {
        let thisAltitude = Altitude(feet: 15000, reference: .pressureAltitude, context: .standardISA)

        XCTAssertEqual(thisAltitude.pressureAltitude.feet, thisAltitude.amsl.feet, accuracy: 0.1)
    }

    func testPAtoAMSL() {
        // From original test: test_converts_pressureAltitude_to_aboveMeanSeaLevel
        let thisAltitude = Altitude(
            feet: 15000,
            reference: .pressureAltitude,
            context: .init(groundElevation: .init(feet: 520), qnh: .init(hectopascals: 1010))
        )

        XCTAssertEqual(thisAltitude.amsl.feet, 14920.3, accuracy: 0.5)
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

        XCTAssertEqual(thisAltitude.agl.feet, 5000, accuracy: 1)
    }

    func testLengthUnits() {
        let altitude = Altitude(meters: 1000, reference: .agl, context: standardContext)
        XCTAssertEqual(altitude.agl.meters, 1000)
        XCTAssertEqual(altitude.agl.feet, 3280.84, accuracy: 0.1)
    }

    func testInMethod() {
        let altitude = Altitude(feet: 5000, reference: .agl, context: .init(groundElevation: .init(feet: 1000)))

        let amslAltitude = altitude.in(.amsl)
        XCTAssertEqual(amslAltitude!.value.feet, 6000)
        XCTAssertEqual(amslAltitude!.reference, .amsl)
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
        XCTAssertNotNil(context.surfaceTemperature)
        XCTAssertEqual(context.surfaceTemperature!.celsius, 15, accuracy: 0.1)
    }

    func testSurfaceTemperatureInput() {
        let context = AltitudeContext(
            groundElevation: .init(feet: 800),
            qnh: ISA.seaLevelPressure,
            surfaceTemperature: .init(celsius: 15),
            lapseRate: ISA.troposphereLapseRate
        )

        XCTAssertNotNil(context.seaLevelTemperature)

        let expectedSLTemp = 15 + (6.5/1000 * 800 * 0.3048)
        XCTAssertEqual(context.seaLevelTemperature!.celsius, expectedSLTemp, accuracy: 0.1)
    }

    func testCanConvertToTrueAltitude_AgreesWithThrowingConversion_WhenAlreadyTrueAltitude() {
        let incompleteContext = AltitudeContext() // no seaLevelTemperature, no lapseRate
        let altitude = Altitude(feet: 5000, reference: .trueAltitude, context: incompleteContext)

        XCTAssertTrue(altitude.canConvertToTrueAltitude, "No profile is needed: it's already true altitude")

        XCTAssertNoThrow(
            try altitude.valueThrowing(in: .trueAltitude),
            "canConvertToTrueAltitude promised this would succeed"
        )
    }

    /// Same mismatch for the
    /// `.geopotential` case, which `canConvertToTrueAltitude` also always
    /// allows (a pure geometric transform, no temperature profile needed).
    func testCanConvertToTrueAltitude_AgreesWithThrowingConversion_FromGeopotential() {
        let incompleteContext = AltitudeContext() // no seaLevelTemperature, no lapseRate
        let altitude = Altitude(feet: 5000, reference: .geopotential, context: incompleteContext)

        XCTAssertTrue(altitude.canConvertToTrueAltitude)

        XCTAssertNoThrow(
            try altitude.valueThrowing(in: .trueAltitude),
            "canConvertToTrueAltitude promised this would succeed"
        )
    }

    func testHashable_AgreesWithEquatable_WhenOnlyOneSideHasGroundElevation() {
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

        // Equatable falls back to AMSL since `withoutGround` has none: 1500 == 1500.
        XCTAssertEqual(withGround, withoutGround)

        XCTAssertEqual(
            withGround.hashValue, withoutGround.hashValue,
            "Equal altitudes must hash equally, but hash(into:) picks AGL vs AMSL per-side instead of matching =="
        )
    }

    /// `.agl` is defined as `amsl − groundElevation` (barometric/QFE-style), so converting
    /// from `.geopotential` to `.agl` must route through indicated AMSL, not the raw
    /// geometric true altitude — otherwise it mixes two different datums.
    func testConvertToAGL_FromGeopotential_MatchesTheEquivalentTrueAltitudeConversion() {
        let context = AltitudeContext(
            groundElevation: .init(feet: 500),
            qnh: .init(hectopascals: 1013.25),
            seaLevelTemperature: .init(celsius: 20),
            lapseRate: ISA.troposphereLapseRate
        )

        let trueAltitude = Altitude(feet: 5500, reference: .trueAltitude, context: context)
        let geopotentialEquivalent = Altitude(
            value: trueAltitude.geopotential,
            reference: .geopotential,
            context: context
        )

        XCTAssertEqual(
            geopotentialEquivalent.agl.feet,
            trueAltitude.agl.feet,
            accuracy: 1e-6,
            "Geopotential → AGL must agree with the equivalent True altitude → AGL conversion"
        )
    }

    func testTrueAltitude_InStandardISA_MatchesAMSL_AboveTropopause() {
        for meters in [13_000.0, 15_000, 18_000] {
            let altitude = Altitude(meters: meters, reference: .amsl, context: .standardISA)

            XCTAssertEqual(
                altitude.trueAltitude.meters, meters, accuracy: 0.5,
                "ISA true altitude must equal AMSL at \(meters) m"
            )
        }
    }

    func testPressureAltitude_GeopotentialRoundTrip_InNonISAContext() {
        let cold = AltitudeContext(
            groundElevation: .surface,
            qnh: ISA.seaLevelPressure,
            seaLevelTemperature: .init(celsius: -15),
            lapseRate: ISA.troposphereLapseRate
        )
        let pressureAltitude = Altitude(feet: 10_000, reference: .pressureAltitude, context: cold)

        let geopotential = pressureAltitude.converted(to: .geopotential)

        XCTAssertEqual(geopotential.pressureAltitude.feet, 10_000, accuracy: 1)
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
            pressureAltitude.geopotential.feet,
            pressureAltitude.converted(to: .trueAltitude).geopotential.feet,
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
                        (try? altitude.valueThrowing(in: target)) != nil,
                        "\(name): \(source.abbreviation) → \(target.abbreviation)"
                    )
                }
            }
        }
    }

    func testTrueAltitudeIfPossible_WithoutQNH_IsNilLikeTheThrowingConversion() {
        let context = AltitudeContext(
            groundElevation: .init(feet: 500),
            seaLevelTemperature: .init(celsius: 15),
            lapseRate: ISA.troposphereLapseRate
        )
        let altitude = Altitude(feet: 5000, reference: .amsl, context: context)

        XCTAssertThrowsError(try altitude.valueThrowing(in: .trueAltitude))
        XCTAssertNil(altitude.trueAltitudeIfPossible)
    }

    func testAGLIfPossible_AlreadyAGL_WithoutGroundElevation() {
        let altitude = Altitude(feet: 500, reference: .agl, context: AltitudeContext())

        XCTAssertEqual(altitude.aglIfPossible?.feet, 500)
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
}
