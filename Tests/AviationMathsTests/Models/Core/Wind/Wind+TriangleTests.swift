import XCTest
@testable import AviationMaths

final class WindTriangleTests: XCTestCase {
    
    func testGroundspeed_PureHeadwind() {
        // Aircraft: 100kt TAS, heading North (0°)
        // Wind: 20kt FROM North (0°) → pure headwind
        // Expected GS: 80kt, track 0°
        
        let tas = Measurement<UnitSpeed>(knots: 100)
        let track = Measurement<UnitAngle>(degrees: 0)
        let wind = Wind(feet: 0, knots: 20, bearingFrom: 0)
        
        let gs = WindTriangle.groundspeed(tas: tas, track: track, wind: wind)
        
        XCTAssertEqual(gs.x.knots, 0, accuracy: 0.001)
        XCTAssertEqual(gs.y.knots, 80, accuracy: 0.001)
        XCTAssertEqual(gs.magnitude.knots, 80, accuracy: 0.001)
        XCTAssertEqual(gs.bearing.degrees, 0, accuracy: 0.001)
    }
    
    func testGroundspeed_PureTailwind() {
        // Aircraft: 100kt TAS, heading North (0°)
        // Wind: 20kt FROM South (180°) → pure tailwind
        // Expected GS: 120kt, track 0°
        
        let tas = Measurement<UnitSpeed>(knots: 100)
        let track = Measurement<UnitAngle>(degrees: 0)
        let wind = Wind(feet: 0, knots: 20, bearingFrom: 180)
        
        let gs = WindTriangle.groundspeed(tas: tas, track: track, wind: wind)
        
        XCTAssertEqual(gs.x.knots, 0, accuracy: 0.001)
        XCTAssertEqual(gs.y.knots, 120, accuracy: 0.001)
        XCTAssertEqual(gs.magnitude.knots, 120, accuracy: 0.001)
    }
    
    func testGroundspeed_PureCrosswindFromRight() {
        // Aircraft: 100kt TAS, heading North (0°)
        // Wind: 20kt FROM East (90°) → pure right crosswind
        // Expected: GS slightly > 100kt, drift left
        
        let tas = Measurement<UnitSpeed>(knots: 100)
        let track = Measurement<UnitAngle>(degrees: 0)
        let wind = Wind(feet: 0, knots: 20, bearingFrom: 90)
        
        let gs = WindTriangle.groundspeed(tas: tas, track: track, wind: wind)
        
        // x component: -20kt (pushed West)
        // y component: 100kt (aircraft's northward motion)
        XCTAssertEqual(gs.x.knots, -20, accuracy: 0.001)
        XCTAssertEqual(gs.y.knots, 100, accuracy: 0.001)
        
        // Magnitude: sqrt(100² + 20²) = 102kt
        XCTAssertEqual(gs.magnitude.knots, 102.0, accuracy: 0.1)
        
        // Track: should be slightly west of north (drift left)
        // atan2(-20, 100) in aviation = ~348.7°
        XCTAssertEqual(gs.bearing.degrees, 348.69, accuracy: 0.1)
    }
    
    func testGroundspeed_PureCrosswindFromLeft() {
        // Aircraft: 100kt TAS, heading North (0°)
        // Wind: 20kt FROM West (270°) → pure left crosswind
        
        let tas = Measurement<UnitSpeed>(knots: 100)
        let track = Measurement<UnitAngle>(degrees: 0)
        let wind = Wind(feet: 0, knots: 20, bearingFrom: 270)
        
        let gs = WindTriangle.groundspeed(tas: tas, track: track, wind: wind)
        
        // x component: +20kt (pushed East)
        // y component: 100kt
        XCTAssertEqual(gs.x.knots, 20, accuracy: 0.001)
        XCTAssertEqual(gs.y.knots, 100, accuracy: 0.001)
        
        // Track: should be slightly east of north (drift right)
        XCTAssertEqual(gs.bearing.degrees, 11.31, accuracy: 0.1)
    }
    
    func testGroundspeed_QuarteringHeadwind() {
        // Aircraft: 100kt TAS, heading East (90°)
        // Wind: 30kt FROM NE (45°) → quartering headwind from right
        
        let tas = Measurement<UnitSpeed>(knots: 100)
        let track = Measurement<UnitAngle>(degrees: 90)
        let wind = Wind(feet: 0, knots: 30, bearingFrom: 45)
        
        let gs = WindTriangle.groundspeed(tas: tas, track: track, wind: wind)
        
        // Aircraft: heading East → x=100, y=0
        // Wind from 45° → toward 225° (SW)
        // Wind vector: x = 30*sin(225°) = -21.2, y = 30*cos(225°) = -21.2
        
        let expectedX = 100 + 30 * sin(225.0 * .pi / 180) // 100 - 21.2 = 78.8
        let expectedY = 0 + 30 * cos(225.0 * .pi / 180) // 0 - 21.2 = -21.2
        
        XCTAssertEqual(gs.x.knots, expectedX, accuracy: 0.1)
        XCTAssertEqual(gs.y.knots, expectedY, accuracy: 0.1)
    }
    
    func testGroundspeed_NoWind() {
        let tas = Measurement<UnitSpeed>(knots: 150)
        let track = Measurement<UnitAngle>(degrees: 45)
        let wind = Wind(feet: 0, knots: 0, bearingFrom: 0)
        
        let gs = WindTriangle.groundspeed(tas: tas, track: track, wind: wind)
        
        XCTAssertEqual(gs.magnitude.knots, 150, accuracy: 0.001)
        XCTAssertEqual(gs.bearing.degrees, 45, accuracy: 0.001)
    }
    
    func testGroundspeedPolar() {
        let tas = Measurement<UnitSpeed>(knots: 100)
        let heading = Measurement<UnitAngle>(degrees: 0)
        let wind = Wind(feet: 0, knots: 20, bearingFrom: 0)
        
        let gsPolar = WindTriangle.groundspeedPolar(tas: tas, heading: heading, wind: wind)
        
        XCTAssertEqual(gsPolar.magnitude.knots, 80, accuracy: 0.001)
        XCTAssertEqual(gsPolar.bearing.degrees, 0, accuracy: 0.001)
    }
    
}
