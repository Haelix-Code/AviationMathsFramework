import XCTest
@testable import AviationMaths

final class AtmosphericProfileTests: XCTestCase {

    func testBuilder_sortsLayersByAltitude() {
        let profile = AtmosphericProfile {
            AtmosphericLayer.layer(altitude: 10000, windFrom: 280, speed: 40, temperature: 0)
            AtmosphericLayer.layer(altitude: 5000, windFrom: 250, speed: 25, temperature: 10)
            AtmosphericLayer.layer(altitude: 15000, windFrom: 290, speed: 55, temperature: -10)
        }

        XCTAssertEqual(profile.layers.map { $0.altitude.feet }, [5000.0, 10000.0, 15000.0])
    }

    func testBuilder_SupportsIfElseAndFor() {
        let includeHigh = true
        let profile = AtmosphericProfile {
            AtmosphericLayer.layer(altitude: 10000, windFrom: 280, speed: 40, temperature: 0)
            if includeHigh {
                AtmosphericLayer.layer(altitude: 15000, windFrom: 290, speed: 55, temperature: -10)
            } else {
                AtmosphericLayer.layer(altitude: 12000, windFrom: 285, speed: 45, temperature: -5)
            }
            for feet in [5000.0, 2000.0] {
                AtmosphericLayer.layer(altitude: feet, windFrom: 250, speed: 25, temperature: 10)
            }
        }

        XCTAssertEqual(profile.layers.map { $0.altitude.feet }, [2000.0, 5000.0, 10000.0, 15000.0])
    }

    func testInitWithLayers_sortsLayersByAltitude() {
        let layers = [
            AtmosphericLayer.layer(altitude: 8000, windFrom: 240, speed: 35, temperature: 2),
            AtmosphericLayer.layer(altitude: 1000, windFrom: 190, speed: 10, temperature: 12),
            AtmosphericLayer.layer(altitude: 5000, windFrom: 220, speed: 22, temperature: 4)
        ]
        let profile = AtmosphericProfile(layers: layers)

        XCTAssertEqual(profile.layers.map { $0.altitude.feet }, [1000, 5000, 8000])
    }

    func testWindAt_delegatesToInterpolation() {
        let lower = Wind(feet: 0, knots: 10, fromDirection: 180)
        let upper = Wind(feet: 10000, knots: 30, fromDirection: 200)
        let profile = AtmosphericProfile {
            AtmosphericLayer.layer(altitude: 0, windFrom: 180, speed: 10, temperature: 20)
            AtmosphericLayer.layer(altitude: 10000, windFrom: 200, speed: 30, temperature: 0)
        }

        let w = profile.wind(at: .init(feet: 5000))
        XCTAssertNotNil(w)

        // Component-wise (u/v) interpolation is the correct physical answer
        // for winds that differ in direction, not a separate average of
        // speed and direction.
        let expectedPolar = ((lower.vector + upper.vector) / 2).asPolar
        XCTAssertEqual(w!.speed.knots, expectedPolar.magnitude.knots, accuracy: 1e-10)
        XCTAssertEqual(w!.fromDirection.degrees, expectedPolar.bearing.reciprocal.degrees, accuracy: 1e-10)
    }

    func testCodable_roundTrip() throws {
        let profile = AtmosphericProfile {
            AtmosphericLayer.layer(altitude: 0, windFrom: 180, speed: 10, temperature: 20)
            AtmosphericLayer.layer(altitude: 10000, windFrom: 200, speed: 30, temperature: 0)
        }

        let data = try JSONEncoder().encode(profile)
        let decoded = try JSONDecoder().decode(AtmosphericProfile.self, from: data)

        XCTAssertEqual(decoded, profile)
    }
}
