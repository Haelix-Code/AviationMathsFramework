import XCTest
@testable import AviationMaths

final class ErrorHandlingTests: XCTestCase {

    // MARK: - Speed Error Tests

    func testSpeedConversion_ThrowsMissingDensity() {
        // Context without pressure altitude = no density
        let context = SpeedContext()
        let speed = Speed(knots: 200, reference: .equivalentAirspeed, context: context)

        XCTAssertThrowsError(try speed.asTAS()) { error in
            guard case ContextCalculationError.insufficientData(let calc, let missing) = error else {
                XCTFail("Expected ContextCalculationError.insufficientData")
                return
            }
            XCTAssertEqual(calc, "density")
            XCTAssertTrue(missing.contains("pressureAltitude"))
        }
    }

    func testSpeedConversion_ThrowsMissingTemperature() {
        // Context without pressure altitude = no speed of sound
        let context = SpeedContext()
        let speed = Speed(knots: 250, reference: .trueAirspeed, context: context)

        XCTAssertThrowsError(try speed.asMach()) { error in
            guard case ContextCalculationError.insufficientData(let calc, _) = error else {
                XCTFail("Expected ContextCalculationError.insufficientData")
                return
            }
            XCTAssertEqual(calc, "speedOfSound")
        }
    }

    func testSpeedConversion_SucceedsWithValidContext() throws {
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 200, reference: .calibratedAirspeed, context: context)

        let cas = try speed.asCAS()
        let eas = try speed.asEAS()
        let tas = try speed.asTAS()
        let mach = try speed.asMach()

        XCTAssertEqual(cas.knots, 200, accuracy: 0.1)
        XCTAssertGreaterThan(eas.knots, 0)
        XCTAssertGreaterThan(tas.knots, 0)
        XCTAssertGreaterThan(mach, 0)
    }

    // MARK: - Altitude Error Tests

    func testAltitudeConversion_ThrowsMissingGroundElevation() {
        let context = AltitudeContext()  // No ground elevation
        let altitude = Altitude(feet: 1000, reference: .agl, context: context)

        XCTAssertThrowsError(try altitude.valueThrowing(in: .amsl)) { error in
            guard case AltitudeConversionError.missingGroundElevation = error else {
                XCTFail("Expected AltitudeConversionError.missingGroundElevation")
                return
            }
        }
    }

    func testAltitudeConversion_ThrowsMissingQNH() {
        let context = AltitudeContext(groundElevation: .init(feet: 500))  // No QNH
        let altitude = Altitude(feet: 5000, reference: .amsl, context: context)

        XCTAssertThrowsError(try altitude.valueThrowing(in: .pressureAltitude)) { error in
            guard case AltitudeConversionError.missingQNH = error else {
                XCTFail("Expected AltitudeConversionError.missingQNH")
                return
            }
        }
    }

    func testAltitudeConversion_ThrowsMissingTemperatureProfile() {
        let context = AltitudeContext(
            groundElevation: .init(feet: 500),
            qnh: ISA.seaLevelPressure
            // Missing temperature and lapse rate
        )
        let altitude = Altitude(feet: 5000, reference: .amsl, context: context)

        XCTAssertThrowsError(try altitude.valueThrowing(in: .trueAltitude)) { error in
            guard case AltitudeConversionError.missingTemperatureProfile = error else {
                XCTFail("Expected AltitudeConversionError.missingTemperatureProfile")
                return
            }
        }
    }

    func testAltitudeConversion_SucceedsWithValidContext() throws {
        let context = AltitudeContext.standardISA
        let altitude = Altitude(feet: 5000, reference: .amsl, context: context)

        let agl = try altitude.valueThrowing(in: .agl)
        let amsl = try altitude.valueThrowing(in: .amsl)
        let pa = try altitude.valueThrowing(in: .pressureAltitude)

        XCTAssertEqual(agl.feet, 5000, accuracy: 0.1)
        XCTAssertEqual(amsl.feet, 5000, accuracy: 0.1)
        XCTAssertEqual(pa.feet, 5000, accuracy: 0.1)
    }

    // MARK: - Context Error Tests

    func testSpeedContext_ThrowsErrorForDensity() {
        let context = SpeedContext()  // No altitude

        XCTAssertThrowsError(try context.densityThrowing()) { error in
            guard case ContextCalculationError.insufficientData(let calc, let missing) = error else {
                XCTFail("Expected ContextCalculationError.insufficientData")
                return
            }
            XCTAssertEqual(calc, "density")
            XCTAssertTrue(missing.contains("pressureAltitude"))
        }
    }

    func testSpeedContext_ThrowsErrorForSpeedOfSound() {
        let context = SpeedContext()  // No altitude

        XCTAssertThrowsError(try context.speedOfSoundThrowing()) { error in
            guard case ContextCalculationError.insufficientData(let calc, _) = error else {
                XCTFail("Expected ContextCalculationError.insufficientData")
                return
            }
            XCTAssertEqual(calc, "speedOfSound")
        }
    }

    func testSpeedContext_SucceedsWithValidData() throws {
        let context = SpeedContext(pressureAltitude: .init(feet: 10000), deltaISA: .init(kelvin: 0))

        let density = try context.densityThrowing()
        let speedOfSound = try context.speedOfSoundThrowing()
        let relativePressure = try context.relativePressureThrowing()

        XCTAssertGreaterThan(density.value, 0)
        XCTAssertGreaterThan(speedOfSound.mps, 0)
        XCTAssertGreaterThan(relativePressure, 0)
    }

    // MARK: - Error Equality Tests

    func testSpeedConversionError_Equality() {
        XCTAssertEqual(
            SpeedConversionError.missingDensity,
            SpeedConversionError.missingDensity
        )
        XCTAssertNotEqual(
            SpeedConversionError.missingDensity,
            SpeedConversionError.missingPressureAltitude
        )
    }

    func testAltitudeConversionError_Equality() {
        XCTAssertEqual(
            AltitudeConversionError.missingQNH,
            AltitudeConversionError.missingQNH
        )
        XCTAssertNotEqual(
            AltitudeConversionError.missingQNH,
            AltitudeConversionError.missingGroundElevation
        )
    }
}
