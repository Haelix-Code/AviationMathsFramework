import XCTest
@testable import AviationMaths
import Foundation

final class PolarArithmeticVectorTests: XCTestCase {
    func testAdding() {
        let v1 = PolarVector(angle: Measurement(value: 0, unit: .radians),
                             magnitude: Measurement(value: 3, unit: UnitLength.meters))
        let v2 = PolarVector(angle: Measurement(value: .pi/2, unit: .radians),
                             magnitude: Measurement(value: 4, unit: UnitLength.meters))
        let result = v1.adding(v2)
        
        XCTAssertEqual(result.magnitude.value, 5) // 3-4-5 triangle
        XCTAssertEqual(result.angle.converted(to: .radians).value, 0.92729, accuracy: 0.0001) // ~53 degrees
    }

    func testSubtracting() {
        let v1 = PolarVector(angle: Measurement(value: .pi/2, unit: .radians),
                             magnitude: Measurement(value: 5, unit: UnitLength.meters))
        let v2 = PolarVector(angle: Measurement(value: 0, unit: .radians),
                             magnitude: Measurement(value: 3, unit: UnitLength.meters))
        let result = v1.subtracting(v2)
        
        XCTAssertEqual(result.magnitude.value, 5.8309, accuracy: 0.0001)
        XCTAssertEqual(result.angle.converted(to: .radians).value, 2.1112, accuracy: 0.0001) // ~127 degrees
    }

    func testRotated() {
        let v = PolarVector(angle: Measurement(value: 1, unit: .radians),
                            magnitude: Measurement(value: 2, unit: UnitLength.meters))
        let rotated = v.rotated(by: Measurement(value: .pi, unit: .radians))
        
        XCTAssertEqual(rotated.magnitude.value, 2)
        XCTAssertEqual(rotated.angle.converted(to: .radians).value, 4.14159, accuracy: 0.0001)
    }

    func testNormalized() {
        let v = PolarVector(angle: Measurement(value: 0.5, unit: .radians),
                            magnitude: Measurement(value: 10, unit: UnitLength.meters))
        let normalized = v.normalized
        
        XCTAssertEqual(normalized.magnitude.value, 1)
        XCTAssertEqual(normalized.angle.value, 0.5)
    }

    func testDotProduct() {
        let v1 = PolarVector(angle: Measurement(value: 0, unit: .radians),
                             magnitude: Measurement(value: 2, unit: UnitLength.meters))
        let v2 = PolarVector(angle: Measurement(value: .pi/2, unit: .radians),
                             magnitude: Measurement(value: 3, unit: UnitLength.meters))
        let dot = v1.dotProduct(v2)
        
        XCTAssertEqual(dot.value, 0, accuracy: 0.0001)
        XCTAssertEqual(dot.unit, UnitLength.meters)
    }

    func testAngleBetween() {
        let v1 = PolarVector(angle: Measurement(value: 0, unit: .radians),
                             magnitude: Measurement(value: 2, unit: UnitLength.meters))
        let v2 = PolarVector(angle: Measurement(value: .pi/2, unit: .radians),
                             magnitude: Measurement(value: 2, unit: UnitLength.meters))
        let angle = v1.angleBetween(v2)
        
        XCTAssertEqual(angle.converted(to: .radians).value, 1.57079, accuracy: 0.0001) // pi/2
    }
}
