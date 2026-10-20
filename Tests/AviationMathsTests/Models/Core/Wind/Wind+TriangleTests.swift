import XCTest
@testable import AviationMaths

final class WindTriangleTests: XCTestCase {

    func testGroundVector_NoWind() {
        let heading = Measurement<UnitAngle>(degrees: 45)
        let tas = Measurement<UnitSpeed>(knots: 120)
        let wind = Wind(feet: 0, knots: 0, fromDirection: 0)

        let ground = WindTriangle.groundVectorPolar(heading: heading, tas: tas, wind: wind)

        XCTAssertEqual(ground.bearing.degrees, 45, accuracy: 0.1)
        XCTAssertEqual(ground.magnitude.knots, 120, accuracy: 0.1)
    }

    func testGroundVector_PureHeadwind() {
        let heading = Measurement<UnitAngle>(degrees: 0)
        let tas = Measurement<UnitSpeed>(knots: 100)
        let wind = Wind(feet: 0, knots: 20, fromDirection: 0) // From North

        let ground = WindTriangle.groundVectorPolar(heading: heading, tas: tas, wind: wind)

        XCTAssertEqual(ground.bearing.degrees, 0, accuracy: 0.1)
        XCTAssertEqual(ground.magnitude.knots, 80, accuracy: 0.1, "Headwind reduces groundspeed")
    }

    func testGroundVector_PureTailwind() {
        let heading = Measurement<UnitAngle>(degrees: 0)
        let tas = Measurement<UnitSpeed>(knots: 100)
        let wind = Wind(feet: 0, knots: 20, fromDirection: 180) // From South

        let ground = WindTriangle.groundVectorPolar(heading: heading, tas: tas, wind: wind)

        XCTAssertEqual(ground.bearing.degrees, 0, accuracy: 0.1)
        XCTAssertEqual(ground.magnitude.knots, 120, accuracy: 0.1, "Tailwind increases groundspeed")
    }

    func testGroundVector_RightCrosswind() {
        let heading = Measurement<UnitAngle>(degrees: 0)
        let tas = Measurement<UnitSpeed>(knots: 100)
        let wind = Wind(feet: 0, knots: 20, fromDirection: 90) // From East (right)

        let ground = WindTriangle.groundVectorPolar(heading: heading, tas: tas, wind: wind)
        let drift = WindTriangle.driftAngle(heading: heading, tas: tas, wind: wind)

        XCTAssertEqual(ground.magnitude.knots, 102.0, accuracy: 0.1)
        XCTAssertLessThan(ground.bearing.degrees, 360, "Should drift left (west)")
        XCTAssertGreaterThan(ground.bearing.degrees, 340)
        XCTAssertLessThan(drift.degrees, 0, "Negative drift = left")
    }

    func testGroundVector_LeftCrosswind() {
        let heading = Measurement<UnitAngle>(degrees: 0)
        let tas = Measurement<UnitSpeed>(knots: 100)
        let wind = Wind(feet: 0, knots: 20, fromDirection: 270) // From West (left)

        let drift = WindTriangle.driftAngle(heading: heading, tas: tas, wind: wind)

        XCTAssertGreaterThan(drift.degrees, 0, "Positive drift = right")
    }

    func testAirVector_NoWind() {
        let track = Measurement<UnitAngle>(degrees: 90)
        let groundspeed = Measurement<UnitSpeed>(knots: 150)
        let wind = Wind(feet: 0, knots: 0, fromDirection: 0)

        let air = WindTriangle.airVectorPolar(track: track, groundspeed: groundspeed, wind: wind)

        XCTAssertEqual(air.bearing.degrees, 90, accuracy: 0.1, "No wind = heading equals track")
        XCTAssertEqual(air.magnitude.knots, 150, accuracy: 0.1, "No wind = TAS equals groundspeed")
    }

    func testAirVector_Headwind() {
        let track = Measurement<UnitAngle>(degrees: 0)
        let groundspeed = Measurement<UnitSpeed>(knots: 100)
        let wind = Wind(feet: 0, knots: 20, fromDirection: 0) // Headwind

        let air = WindTriangle.airVectorPolar(track: track, groundspeed: groundspeed, wind: wind)

        XCTAssertEqual(air.bearing.degrees, 0, accuracy: 0.1, "No crosswind = no heading change")
        XCTAssertEqual(air.magnitude.knots, 120, accuracy: 0.1, "Need more TAS to overcome headwind")
    }

    func testAirVector_Tailwind() {
        let track = Measurement<UnitAngle>(degrees: 0)
        let groundspeed = Measurement<UnitSpeed>(knots: 100)
        let wind = Wind(feet: 0, knots: 20, fromDirection: 180) // Tailwind

        let air = WindTriangle.airVectorPolar(track: track, groundspeed: groundspeed, wind: wind)

        XCTAssertEqual(air.bearing.degrees, 0, accuracy: 0.1)
        XCTAssertEqual(air.magnitude.knots, 80, accuracy: 0.1, "Less TAS needed with tailwind")
    }

    func testAirVector_Crosswind() {
        let track = Measurement<UnitAngle>(degrees: 0)
        let groundspeed = Measurement<UnitSpeed>(knots: 100)
        let wind = Wind(feet: 0, knots: 20, fromDirection: 270) // From West (left)

        let air = WindTriangle.airVectorPolar(track: track, groundspeed: groundspeed, wind: wind)

        // Must point into the wind (west) to track north
        XCTAssertGreaterThan(air.bearing.degrees, 345)
        XCTAssertLessThan(air.bearing.degrees, 360)
    }

    func testHeadingForTrack_Simple() {
        let track = Measurement<UnitAngle>(degrees: 0)
        let tas = Measurement<UnitSpeed>(knots: 100)
        let wind = Wind(feet: 0, knots: 20, fromDirection: 270) // Left crosswind

        let result = WindTriangle.headingForTrack(track: track, tas: tas, wind: wind)

        XCTAssertNotNil(result)

        // Should crab into the wind (heading west of track)
        XCTAssertGreaterThan(result!.polar.bearing.degrees, 345)
        XCTAssertLessThan(result!.polar.bearing.degrees, 360)

        // WCA should be negative (crabbing left)
        XCTAssertLessThan(result!.wca.degrees, 0)

        // Verify the solution: using this heading should give us the desired track
        let verification = WindTriangle.groundVectorPolar(
            heading: result!.polar.bearing,
            tas: tas,
            wind: wind
        )
        XCTAssertEqual(verification.bearing.degrees, track.degrees, accuracy: 0.5)
    }

    func testHeadingForTrack_WindTooStrong() {
        let track = Measurement<UnitAngle>(degrees: 0)
        let tas = Measurement<UnitSpeed>(knots: 50)
        let wind = Wind(feet: 0, knots: 60, fromDirection: 90) // Crosswind exceeds TAS

        let result = WindTriangle.headingForTrack(track: track, tas: tas, wind: wind)

        XCTAssertNil(result, "Should return nil when wind exceeds aircraft capability")
    }

    func testWind_FromVectors_NoWind() {
        let heading = Measurement<UnitAngle>(degrees: 45)
        let tas = Measurement<UnitSpeed>(knots: 100)
        let track = Measurement<UnitAngle>(degrees: 45)
        let groundspeed = Measurement<UnitSpeed>(knots: 100)

        let wind = WindTriangle.wind(heading: heading, tas: tas, track: track, groundspeed: groundspeed)

        XCTAssertEqual(wind.speed.knots, 0, accuracy: 0.1)
    }

    func testWind_FromVectors_Headwind() {
        let heading = Measurement<UnitAngle>(degrees: 0)
        let tas = Measurement<UnitSpeed>(knots: 120)
        let track = Measurement<UnitAngle>(degrees: 0)
        let groundspeed = Measurement<UnitSpeed>(knots: 100)

        let wind = WindTriangle.wind(heading: heading, tas: tas, track: track, groundspeed: groundspeed)

        XCTAssertEqual(wind.speed.knots, 20, accuracy: 0.1)
        XCTAssertEqual(wind.fromDirection.degrees, 0, accuracy: 0.1, "Wind from North (headwind)")
    }

    func testWind_FromVectors_Tailwind() {
        let heading = Measurement<UnitAngle>(degrees: 0)
        let tas = Measurement<UnitSpeed>(knots: 80)
        let track = Measurement<UnitAngle>(degrees: 0)
        let groundspeed = Measurement<UnitSpeed>(knots: 100)

        let wind = WindTriangle.wind(heading: heading, tas: tas, track: track, groundspeed: groundspeed)

        XCTAssertEqual(wind.speed.knots, 20, accuracy: 0.1)
        XCTAssertEqual(wind.fromDirection.degrees, 180, accuracy: 0.1, "Wind from South (tailwind)")
    }

    func testWind_FromVectors_Crosswind() {
        // Heading north at 100kt TAS, but tracking slightly east at ~102kt
        let heading = Measurement<UnitAngle>(degrees: 0)
        let tas = Measurement<UnitSpeed>(knots: 100)
        let track = Measurement<UnitAngle>(degrees: 11.3) // Drifting right
        let groundspeed = Measurement<UnitSpeed>(knots: 102)

        let wind = WindTriangle.wind(heading: heading, tas: tas, track: track, groundspeed: groundspeed)

        XCTAssertEqual(wind.speed.knots, 20, accuracy: 1)
        XCTAssertEqual(wind.fromDirection.degrees, 270, accuracy: 1, "Wind from West")
    }

    func testWind_RoundTrip() {
        // Create a scenario, calculate wind, then verify
        let originalWind = Wind(feet: 10000, knots: 35, fromDirection: 225)
        let heading = Measurement<UnitAngle>(degrees: 90)
        let tas = Measurement<UnitSpeed>(knots: 180)

        // Forward: calculate ground vector
        let ground = WindTriangle.groundVectorPolar(heading: heading, tas: tas, wind: originalWind)

        // Reverse: calculate wind from the vectors
        let calculatedWind = WindTriangle.wind(
            heading: heading,
            tas: tas,
            track: ground.bearing,
            groundspeed: ground.magnitude,
            altitude: .init(feet: 10000)
        )

        XCTAssertEqual(calculatedWind.speed.knots, originalWind.speed.knots, accuracy: 0.1)
        XCTAssertEqual(calculatedWind.fromDirection.degrees, originalWind.fromDirection.degrees, accuracy: 0.1)
        XCTAssertEqual(calculatedWind.altitude.feet, 10000)
    }

    func testHeadwindComponent_PureHeadwind() {
        let wind = Wind(feet: 0, knots: 20, fromDirection: 0)
        let track = Measurement<UnitAngle>(degrees: 0)

        let headwind = WindTriangle.headwindComponent(wind: wind, track: track)

        XCTAssertEqual(headwind.knots, 20, accuracy: 0.1, "Full headwind")
    }

    func testHeadwindComponent_PureTailwind() {
        let wind = Wind(feet: 0, knots: 20, fromDirection: 180)
        let track = Measurement<UnitAngle>(degrees: 0)

        let headwind = WindTriangle.headwindComponent(wind: wind, track: track)

        XCTAssertEqual(headwind.knots, -20, accuracy: 0.1, "Negative = tailwind")
    }

    func testHeadwindComponent_Crosswind() {
        let wind = Wind(feet: 0, knots: 20, fromDirection: 90)
        let track = Measurement<UnitAngle>(degrees: 0)

        let headwind = WindTriangle.headwindComponent(wind: wind, track: track)

        XCTAssertEqual(headwind.knots, 0, accuracy: 0.1, "Pure crosswind = no headwind component")
    }

    func testHeadwindComponent_Quartering() {
        let wind = Wind(feet: 0, knots: 20, fromDirection: 45) // From NE
        let track = Measurement<UnitAngle>(degrees: 0) // Tracking North

        let headwind = WindTriangle.headwindComponent(wind: wind, track: track)

        // 45° quartering headwind: component = 20 * cos(45°) ≈ 14.1kt
        XCTAssertEqual(headwind.knots, 14.1, accuracy: 0.2)
    }

    func testCrosswindComponent_FromRight() {
        let wind = Wind(feet: 0, knots: 20, fromDirection: 90) // From East
        let track = Measurement<UnitAngle>(degrees: 0) // Tracking North

        let crosswind = WindTriangle.crosswindComponent(wind: wind, track: track)

        XCTAssertEqual(crosswind.knots, 20, accuracy: 0.1, "Positive = from right")
    }

    func testCrosswindComponent_FromLeft() {
        let wind = Wind(feet: 0, knots: 20, fromDirection: 270) // From West
        let track = Measurement<UnitAngle>(degrees: 0) // Tracking North

        let crosswind = WindTriangle.crosswindComponent(wind: wind, track: track)

        XCTAssertEqual(crosswind.knots, -20, accuracy: 0.1, "Negative = from left")
    }

    /// TAS is supplied in m/s, wind speed in knots. `groundVector` adds the two
    /// vectors via the default `Vector.+`, which currently sums `.value` without
    /// unit conversion. Heading and wind-to-direction are both due north (000°),
    /// so this is a pure tailwind: the two magnitudes should add after converting
    /// wind to the same unit as TAS.
    ///
    /// Correct: 100 m/s + (20 kt → m/s) = 100 + 10.28888... = 110.28888... m/s.
    /// Buggy (today): 100 + 20 = 120 m/s (wind's raw knot value added as if m/s).
    func testGroundVector_MixedUnits_TailwindAddsConvertedSpeed() {
        let heading = Measurement<UnitAngle>(degrees: 0)
        let tas = Measurement<UnitSpeed>(value: 100, unit: .metersPerSecond)
        let wind = Wind(
            altitude: .init(feet: 0),
            fromDirection: .init(degrees: 180), // wind blows FROM south, i.e. TO north: tailwind
            speed: .init(knots: 20)
        )

        let ground = WindTriangle.groundVectorPolar(heading: heading, tas: tas, wind: wind)

        let expectedMps = 100 + Measurement<UnitSpeed>(knots: 20).mps
        XCTAssertEqual(ground.magnitude.converted(to: .metersPerSecond).value, expectedMps, accuracy: 0.01)
        XCTAssertEqual(ground.bearing.degrees, 0, accuracy: 0.1)
    }

}
