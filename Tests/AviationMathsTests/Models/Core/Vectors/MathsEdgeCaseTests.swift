import XCTest
@testable import AviationMaths

final class EdgeCaseTests: XCTestCase {

    // MARK: - NaN and Infinity Handling

    func testCartesianVector_WithNaN() {
        let v = CartesianVector(x: .init(meters: .nan), y: .init(meters: 0))
        XCTAssertTrue(v.magnitude.value.isNaN)
    }

    func testPolarVector_WithZeroMagnitude() {
        let v = PolarVector(bearing: .init(degrees: 45), magnitude: .init(meters: 0))
        let cart = v.asCartesianVector
        XCTAssertEqual(cart.x.meters, 0, accuracy: 1e-10)
        XCTAssertEqual(cart.y.meters, 0, accuracy: 1e-10)
    }

    // MARK: - Boundary Values

    func testLatitude_AtBoundaries() {
        let north = Latitude(decimalDegrees: 90)
        let south = Latitude(decimalDegrees: -90)
        XCTAssertEqual(north.decimalDegrees, 90)
        XCTAssertEqual(south.decimalDegrees, -90)
    }

    func testLongitude_AtBoundaries() {
        let east = Longitude(decimalDegrees: 180)
        let west = Longitude(decimalDegrees: -180)
        XCTAssertEqual(east.decimalDegrees, 180)
        XCTAssertEqual(west.decimalDegrees, -180)
    }

    func testBearing_Normalization_EdgeCases() {
        XCTAssertEqual(Measurement<UnitAngle>(degrees: 360).normalized.degrees, 0, accuracy: 1e-10)
        XCTAssertEqual(Measurement<UnitAngle>(degrees: -0.0001).normalized.degrees, 359.9999, accuracy: 1e-4)
        XCTAssertEqual(Measurement<UnitAngle>(degrees: 720).normalized.degrees, 0, accuracy: 1e-10)
        XCTAssertEqual(Measurement<UnitAngle>(degrees: -720).normalized.degrees, 0, accuracy: 1e-10)
    }

    // MARK: - Speed Edge Cases

    func testSpeed_ZeroTAS() {
        let context = SpeedContext.standardISA
        let speed = Speed(knots: 0, reference: .trueAirspeed, context: context)

        XCTAssertEqual(speed.mach, 0)
        XCTAssertEqual(speed.cas.knots, 0)
        XCTAssertEqual(speed.eas.knots, 0)
    }

    func testSpeed_VeryHighMach() {
        // Test supersonic - your equations are for subsonic only!
        let context = SpeedContext(
            pressureAltitude: .init(feet: 50000),
            deltaISA: .init(kelvin: 0)
        )

        // Mach 2 should still produce valid numbers (even if not physically accurate for all equations)
        let speed = Speed(mach: 2.0, context: context)
        XCTAssertGreaterThan(speed.tas.knots, 0)
        XCTAssertFalse(speed.tas.knots.isNaN)
    }

    // MARK: - ISA Boundary

    func testISA_TropopauseBoundary() {
        let below = ISA(altitudeMeters: 10999)
        let at = ISA(altitudeMeters: 11000)
        let above = ISA(altitudeMeters: 11001)

        // Lapse rate changes at tropopause
        XCTAssertEqual(below.lapseRate, 0.0065)
        XCTAssertEqual(above.lapseRate, 0)

        // Temperature should be continuous
        XCTAssertEqual(below.temperature.kelvin, at.temperature.kelvin, accuracy: 0.1)
        XCTAssertEqual(at.temperature.kelvin, above.temperature.kelvin, accuracy: 0.1)

        // Pressure should be continuous
        XCTAssertEqual(below.pressure.pascals, at.pressure.pascals, accuracy: 10)
    }

    func testISA_NegativeAltitude() {
        // Dead Sea is -430m
        let isa = ISA(altitudeMeters: -430)

        XCTAssertGreaterThan(isa.pressure.pascals, ISA.seaLevelPressure.pascals)
        XCTAssertGreaterThan(isa.density.value, ISA.seaLevelDensity.value)
        XCTAssertGreaterThan(isa.temperature.kelvin, ISA.seaLevelTemperature.kelvin)
    }

    // MARK: - Wind Triangle Edge Cases

    func testWindTriangle_WindEqualsAirspeed() {
        // What happens when wind speed = TAS and is a direct crosswind?
        let heading = Measurement<UnitAngle>(degrees: 0)
        let tas = Measurement<UnitSpeed>(knots: 100)
        let wind = Wind(feet: 0, knots: 100, fromDirection: 90) // 100kt from right

        // Should still produce valid result
        let ground = WindTriangle.groundVectorPolar(heading: heading, tas: tas, wind: wind)
        XCTAssertFalse(ground.magnitude.knots.isNaN)
    }

    func testWindTriangle_WindExceedsTAS_DirectlyOpposed() {
        // Flying into a headwind stronger than your airspeed = going backwards
        let heading = Measurement<UnitAngle>(degrees: 0)
        let tas = Measurement<UnitSpeed>(knots: 50)
        let wind = Wind(feet: 0, knots: 100, fromDirection: 0) // 100kt headwind

        let ground = WindTriangle.groundVectorPolar(heading: heading, tas: tas, wind: wind)

        // Groundspeed should be negative (going backwards) - represented as 50kt at 180°
        XCTAssertEqual(ground.magnitude.knots, 50, accuracy: 0.1)
        XCTAssertEqual(ground.bearing.degrees, 180, accuracy: 0.1, "Should be blown backwards")
    }
}
