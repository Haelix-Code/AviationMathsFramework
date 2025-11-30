import XCTest
import Foundation
@testable import AviationMaths

final class PolarVectorSpeedTests: XCTestCase {

    func testFromBearing_0FromNorth() {
        // Wind from 0° → vector points south
        let speed = Measurement<UnitSpeed>(value: 10, unit: .metersPerSecond)
        let v = SpeedPolar.fromBearing(degrees: 0, speed: speed, fromDirection: true)
        
        XCTAssertEqual(v.magnitude.value, 10)
        XCTAssertEqual(v.angle.normalizedRadians, 0 - .pi / 2 ) // -π = south
    }
    
    func testFromBearing_90FromEast() {
        // Wind from 90° → vector points west
        let speed = Measurement<UnitSpeed>(value: 5, unit: .metersPerSecond)
        let v = SpeedPolar.fromBearing(degrees: 90, speed: speed)
        
        XCTAssertEqual(v.magnitude.value, 5)
        XCTAssertEqual(v.angle.normalizedRadians, .pi) // π rad = west
    }

    func testBearingMatchesFromBearing() {
        // Wind from 45° → from bearing should return original 45°
        let speed = Measurement<UnitSpeed>(value: 12, unit: .metersPerSecond)
        let originalDegrees = 45.0
        let v = SpeedPolar.fromBearing(degrees: originalDegrees, speed: speed)
        XCTAssertEqual(v.fromBearing, originalDegrees)
        XCTAssertEqual(v.bearing, originalDegrees + 180)
    }
    
    func testBearingNormalization() {
        // Math angle > 360° should normalize correctly
        let speed = Measurement<UnitSpeed>(value: 10, unit: .metersPerSecond)
        let v = SpeedPolar(angle: .init(value: 3 * .pi, unit: .radians), magnitude: speed)
        XCTAssertEqual(v.bearing, 270) // 3π rad → 270° aviation
    }
    
    func testFromBearing_TowardFalse() {
        // fromDirection = false → vector points along given degrees
        let speed = Measurement<UnitSpeed>(value: 8, unit: .metersPerSecond)
        let v = SpeedPolar.fromBearing(degrees: 0, speed: speed, fromDirection: false)
        XCTAssertEqual(v.angle.normalizedRadians, .pi/2) // points north
    }
}
