import XCTest
@testable import AviationMaths

final class ErrorHandlingTests: XCTestCase {

    // MARK: - Speed Error Tests

    func testSpeedConversion_ThrowsMissingDensity() {
        // Context without pressure altitude = no density
        let context = SpeedContext()
        let speed = Speed(knots: 200, reference: .equivalentAirspeed, context: context)

        XCTAssertThrowsError(try speed.tas) { error in
            XCTAssertEqual(error as? SpeedConversionError, .missingDensity)
        }
    }

    func testSpeedConversion_ThrowsMissingSpeedOfSound() {
        // Context without pressure altitude = no speed of sound
        let context = SpeedContext()
        let speed = Speed(knots: 250, reference: .trueAirspeed, context: context)

        XCTAssertThrowsError(try speed.mach) { error in
            XCTAssertEqual(error as? SpeedConversionError, .missingSpeedOfSound)
        }
    }

    func testSpeedConversion_SucceedsWithValidContext() throws {
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 200, reference: .calibratedAirspeed, context: context)

        let cas = try speed.cas
        let eas = try speed.eas
        let tas = try speed.tas
        let mach = try speed.mach

        XCTAssertEqual(cas.knots, 200, accuracy: 0.1)
        XCTAssertGreaterThan(eas.knots, 0)
        XCTAssertGreaterThan(tas.knots, 0)
        XCTAssertGreaterThan(mach, 0)
    }

    // MARK: - Altitude Error Tests

    func testAltitudeConversion_ThrowsMissingGroundElevation() {
        let context = AltitudeContext()  // No ground elevation
        let altitude = Altitude(feet: 1000, reference: .agl, context: context)

        XCTAssertThrowsError(try altitude.value(in: .amsl)) { error in
            guard case AltitudeConversionError.missingGroundElevation = error else {
                XCTFail("Expected AltitudeConversionError.missingGroundElevation")
                return
            }
        }
    }

    func testAltitudeConversion_ThrowsMissingQNH() {
        let context = AltitudeContext(groundElevation: .init(feet: 500))  // No QNH
        let altitude = Altitude(feet: 5000, reference: .amsl, context: context)

        XCTAssertThrowsError(try altitude.value(in: .pressureAltitude)) { error in
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

        XCTAssertThrowsError(try altitude.value(in: .trueAltitude)) { error in
            guard case AltitudeConversionError.missingTemperatureProfile = error else {
                XCTFail("Expected AltitudeConversionError.missingTemperatureProfile")
                return
            }
        }
    }

    func testAltitudeConversion_SucceedsWithValidContext() throws {
        let context = AltitudeContext.standardISA
        let altitude = Altitude(feet: 5000, reference: .amsl, context: context)

        let agl = try altitude.value(in: .agl)
        let amsl = try altitude.value(in: .amsl)
        let pa = try altitude.value(in: .pressureAltitude)

        XCTAssertEqual(agl.feet, 5000, accuracy: 0.1)
        XCTAssertEqual(amsl.feet, 5000, accuracy: 0.1)
        XCTAssertEqual(pa.feet, 5000, accuracy: 0.1)
    }

    // MARK: - Context Error Tests

    func testSpeedContext_ThrowsErrorForDensity() {
        let context = SpeedContext()  // No altitude

        XCTAssertThrowsError(try context.density) { error in
            XCTAssertEqual(error as? SpeedConversionError, .missingDensity)
        }
    }

    func testSpeedContext_ThrowsErrorForSpeedOfSound() {
        let context = SpeedContext()  // No altitude

        XCTAssertThrowsError(try context.speedOfSound) { error in
            XCTAssertEqual(error as? SpeedConversionError, .missingSpeedOfSound)
        }
    }

    func testSpeedContext_ThrowsErrorForRelativePressure() {
        let context = SpeedContext()  // No altitude

        XCTAssertThrowsError(try context.relativePressure) { error in
            XCTAssertEqual(error as? SpeedConversionError, .missingRelativePressure)
        }
    }

    func testSpeedContext_SucceedsWithValidData() throws {
        let context = SpeedContext(pressureAltitude: .init(feet: 10000), deltaISA: .init(kelvin: 0))

        let density = try context.density
        let speedOfSound = try context.speedOfSound
        let relativePressure = try context.relativePressure

        XCTAssertGreaterThan(density.value, 0)
        XCTAssertGreaterThan(speedOfSound.mps, 0)
        XCTAssertGreaterThan(relativePressure, 0)
    }

    // MARK: - Error Equality Tests

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

    func testErrors_DescribeThemselves_WhenHeldAsError() {
        let qnh: Error = AltitudeConversionError.missingQNH
        let density: Error = SpeedConversionError.missingDensity

        XCTAssertEqual(qnh.localizedDescription, "QNH required for pressure altitude conversions")
        XCTAssertEqual(
            density.localizedDescription,
            "Air density needs a density, a measured pressure and temperature, or a pressure altitude"
        )
        XCTAssertEqual(
            (CoordinateError.latitudeOutOfRange(95) as Error).localizedDescription,
            "Latitude must be between -90° and +90°, got 95.0°"
        )
        XCTAssertEqual(
            (GeodesicPositionError.mismatchedOrigins as Error).localizedDescription,
            "Positions with different origins can't be summed"
        )
    }
}
