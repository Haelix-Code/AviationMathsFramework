import XCTest
@testable import AviationMaths

final class WindTriangleTests: XCTestCase {
    func testGroundspeedHeadwind() {
        // Aircraft TAS: 161.55816 m/s, track north (0°)
        let tas = Measurement<UnitSpeed>(value: 161.55816, unit: .metersPerSecond)
        let track = Measurement<UnitAngle>(degrees: 0)

        // Wind from north 15 m/s → headwind
        let wind = Wind(feet: 0, knots: 15, bearing: 0)

        let gsVector = WindTriangle.groundspeed(tas: tas, track: track, wind: wind)

        // Groundspeed magnitude
        let gsSpeed = gsVector.magnitude.value
        print("Groundspeed: \(gsSpeed) m/s")

        // Expect TAS - headwind
        XCTAssertEqual(gsSpeed, 146.558, accuracy: 0.001)
    }
    
    func testHeadwindSpeed() {
        let windSpeed = Measurement<UnitSpeed>(value: 20, unit: .metersPerSecond)
        let angleBetweenTrackAndWind = Double.pi / 4 // 45°

        // Headwind = projection of wind onto track
        let headwind = windSpeed.value * cos(angleBetweenTrackAndWind)

        XCTAssertEqual(round(headwind * 10) / 10, 14.1)
    }
    
    func testAngleBetweenTrackAndWind() {
        // Track north (0°)
        let trackDeg = 288.0
        let trackRad = trackDeg * .pi / 180
        let tas = Measurement<UnitSpeed>(value: 161.55816, unit: .metersPerSecond)

        // Wind from 210° → vector points toward 30° (210 + 180 = 30°)
        let wind = Wind(feet: 0, knots: 30, bearing: 210)

        // Construct vectors
        let tasVector = CartesianVector<UnitSpeed>(
            x: .init(value: tas.value * sin(trackRad), unit: tas.unit),
            y: .init(value: tas.value * cos(trackRad), unit: tas.unit)
        )

        let windVector = wind.vector

        // Angle between vectors
        let dot = tasVector.x.value * windVector.x.value + tasVector.y.value * windVector.y.value
        let magProduct = tasVector.magnitude.value * windVector.magnitude.value
        let angleRad = acos(dot / magProduct)

        XCTAssertEqual(angleRad, 1.361)
    }
}
