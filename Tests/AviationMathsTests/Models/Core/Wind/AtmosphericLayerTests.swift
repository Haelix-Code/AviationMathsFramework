import XCTest
@testable import AviationMaths

final class AtmosphericLayerTests: XCTestCase {
    func test_initWithComponents_createsLayerCorrectly() {
        let layer = AtmosphericLayer(
            altitude: .init(feet: 10000),
            fromDirection: .init(degrees: 280),
            speed: .init(knots: 40),
            temperature: .init(celsius: -10)
        )

        XCTAssertEqual(layer.altitude.feet, 10000)
        XCTAssertEqual(layer.wind.fromDirection.degrees, 280)
        XCTAssertEqual(layer.wind.speed.knots, 40)
        XCTAssertEqual(layer.temperature.celsius, -10)
    }

    func test_winds_extractsWindsFromLayers() {
        let layers = [
            AtmosphericLayer(
                altitude: .init(feet: 1000),
                fromDirection: .init(degrees: 180),
                speed: .init(knots: 10),
                temperature: .init(celsius: 15)
            ),
            AtmosphericLayer(
                altitude: .init(feet: 5000),
                fromDirection: .init(degrees: 220),
                speed: .init(knots: 25),
                temperature: .init(celsius: 5)
            )
        ]

        let winds = layers.winds

        XCTAssertEqual(winds.count, 2)
        XCTAssertEqual(winds[0].altitude.feet, 1000)
        XCTAssertEqual(winds[0].fromDirection.degrees, 180)
        XCTAssertEqual(winds[0].speed.knots, 10)
        XCTAssertEqual(winds[1].altitude.feet, 5000)
        XCTAssertEqual(winds[1].fromDirection.degrees, 220)
        XCTAssertEqual(winds[1].speed.knots, 25)
    }

    func test_temperatureAt_withExactMatch_returnsExactTemp() {
        let layers = [
            AtmosphericLayer(
                altitude: .init(feet: 5000),
                fromDirection: .init(degrees: 270),
                speed: .init(knots: 25),
                temperature: .init(celsius: 10)
            ),
            AtmosphericLayer(
                altitude: .init(feet: 10000),
                fromDirection: .init(degrees: 280),
                speed: .init(knots: 40),
                temperature: .init(celsius: 0)
            )
        ]
        let temp = layers.temperature(at: .init(feet: 5000))

        XCTAssertNotNil(temp)
        XCTAssertEqual(temp?.celsius, 10)
    }

    func test_temperatureAt_withUnsortedLayers_interpolatesCorrectly() {
        let layers = [
            AtmosphericLayer(
                altitude: .init(feet: 10000),
                fromDirection: .init(degrees: 280),
                speed: .init(knots: 40),
                temperature: .init(celsius: 0)
            ),
            AtmosphericLayer(
                altitude: .init(feet: 5000),
                fromDirection: .init(degrees: 270),
                speed: .init(knots: 25),
                temperature: .init(celsius: 10)
            )
        ]

        let temp = layers.temperature(at: .init(feet: 7500))

        XCTAssertNotNil(temp)
        XCTAssertEqual(temp?.celsius ?? 0, 5, accuracy: 0.01)
    }

    func test_realisticSounding_canExtractAndInterpolate() {
        let sounding = [
            AtmosphericLayer(
                altitude: .init(feet: 1000),
                fromDirection: .init(degrees: 190),
                speed: .init(knots: 8),
                temperature: .init(celsius: 12)),
            AtmosphericLayer(
                altitude: .init(feet: 3000),
                fromDirection: .init(degrees: 205),
                speed: .init(knots: 15),
                temperature: .init(celsius: 8)),
            AtmosphericLayer(
                altitude: .init(feet: 5000),
                fromDirection: .init(degrees: 220),
                speed: .init(knots: 22),
                temperature: .init(celsius: 4)),
            AtmosphericLayer(
                altitude: .init(feet: 8000),
                fromDirection: .init(degrees: 250),
                speed: .init(knots: 35),
                temperature: .init(celsius: -2)),
            AtmosphericLayer(
                altitude: .init(feet: 10000),
                fromDirection: .init(degrees: 270),
                speed: .init(knots: 45),
                temperature: .init(celsius: -8)),
            AtmosphericLayer(
                altitude: .init(feet: 14000),
                fromDirection: .init(degrees: 280),
                speed: .init(knots: 60),
                temperature: .init(celsius: -18))
        ]

        let winds = sounding.winds
        let tempAt7000 = sounding.temperature(at: .init(feet: 7000))

        XCTAssertEqual(winds.count, 6)
        XCTAssertNotNil(tempAt7000)
        XCTAssertEqual(tempAt7000?.celsius ?? -999, 0, accuracy: 0.1)
    }

    func testInitAndProperties() {
        let wind = Wind(feet: 5000, knots: 30, fromDirection: 180)
        let layer = AtmosphericLayer(wind: wind,
                                     temperature: .init(celsius: -5))

        XCTAssertEqual(layer.altitude.feet, 5000)
        XCTAssertEqual(layer.wind, wind)
        XCTAssertEqual(layer.temperature.celsius, -5)
    }

    func testArrayComputedProperties() {
        let layers = [
            AtmosphericLayer(
                altitude: .init(feet: 0),
                fromDirection: .init(degrees: 0),
                speed: .init(knots: 10),
                temperature: .init(celsius: 20)
            ),
            AtmosphericLayer(
                altitude: .init(feet: 10000),
                fromDirection: .init(degrees: 180),
                speed: .init(knots: 40),
                temperature: .init(celsius: -10)
            )
        ]

        XCTAssertEqual(layers.winds.count, 2)
        XCTAssertEqual(layers.temperatureProfile.count, 2)
        XCTAssertEqual(layers.temperatureProfile[0].temperature.celsius, 20)
        XCTAssertEqual(layers.temperatureProfile[1].temperature.celsius, -10)
    }

    func testTemperatureInterpolation() {
        let layers = [
            AtmosphericLayer(altitude: .init(feet: 0),
                             fromDirection: .init(degrees: 0),
                             speed: .init(knots: 0),
                             temperature: .init(celsius: 20)),
            AtmosphericLayer(altitude: .init(feet: 10000),
                             fromDirection: .init(degrees: 0),
                             speed: .init(knots: 0),
                             temperature: .init(celsius: 0))
        ]

        let t = layers.temperature(at: .init(feet: 5000))
        XCTAssertNotNil(t)
        XCTAssertEqual(t!.celsius, 10, accuracy: 0.0001)
    }

    func testTemperatureOutOfRange() {
        let layers = [
            AtmosphericLayer(altitude: .init(feet: 1000),
                             fromDirection: .init(degrees: 0),
                             speed: .init(knots: 0),
                             temperature: .init(celsius: 10)),
            AtmosphericLayer(altitude: .init(feet: 2000),
                             fromDirection: .init(degrees: 0),
                             speed: .init(knots: 0),
                             temperature: .init(celsius: 0))
        ]

        XCTAssertNil(layers.temperature(at: .init(feet: 500)))
        XCTAssertNil(layers.temperature(at: .init(feet: 3000)))
    }

    func testDecode_AltitudeDisagreesWithWindAltitude_Throws() throws {
        let layer = AtmosphericLayer(
            altitude: .init(feet: 1000),
            fromDirection: .init(degrees: 0),
            speed: .init(knots: 10),
            temperature: .init(celsius: 10)
        )
        let data = try JSONEncoder().encode(layer)

        var json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        var altitude = json["altitude"] as! [String: Any]
        altitude["value"] = 2000
        json["altitude"] = altitude

        let mutatedData = try JSONSerialization.data(withJSONObject: json)

        XCTAssertThrowsError(try JSONDecoder().decode(AtmosphericLayer.self, from: mutatedData)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testAtmosphericLayerCodableRoundtrip() throws {
        let layer = AtmosphericLayer(
            altitude: .init(meters: 1000),
            fromDirection: .init(degrees: 270),
            speed: .init(mps: 15),
            temperature: .init(celsius: -2)
        )

        let data = try JSONEncoder().encode(layer)
        let decoded = try JSONDecoder().decode(AtmosphericLayer.self, from: data)
        XCTAssertEqual(decoded, layer)
    }

    func testCodableRoundTrip_ArbitraryMetricAltitudes() throws {
        var failures: [Double] = []

        for i in 0..<500 {
            let meters = Double(i) * 1.37 + 0.123
            let layer = AtmosphericLayer(
                altitude: .init(meters: meters),
                fromDirection: .init(degrees: 270),
                speed: .init(knots: 15),
                temperature: .init(celsius: 5)
            )
            let data = try JSONEncoder().encode(layer)
            if (try? JSONDecoder().decode(AtmosphericLayer.self, from: data)) == nil {
                failures.append(meters)
            }
        }

        XCTAssertEqual(failures, [], "\(failures.count) of 500 layers failed to decode their own encoding")
    }
}
