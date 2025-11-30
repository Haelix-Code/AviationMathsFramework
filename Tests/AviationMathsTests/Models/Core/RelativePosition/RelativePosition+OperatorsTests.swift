import XCTest
@testable import AviationMaths

final class RelativePositionOperatorTests: XCTestCase {

    private func position(bearing: Double, range: Double) -> RelativePosition {
        RelativePosition(bearing: .init(degrees: bearing), range: .init(meters: range))
    }
    
    private func position(x: Double, y: Double) -> RelativePosition {
        RelativePosition(x: .init(meters: x), y: .init(meters: y))
    }

    func testAddition_Cartesian() {
        let p1 = position(x: 1, y: 2)
        let p2 = position(x: 3, y: 4)

        let result = p1 + p2
        
        XCTAssertEqual(result.x.meters, 4, accuracy: 0.001)
        XCTAssertEqual(result.y.meters, 6, accuracy: 0.001)
    }
    
    func testAddition_OppositeDirections() {
        // 100m North + 100m South = zero
        let north = position(bearing: 0, range: 100)
        let south = position(bearing: 180, range: 100)
        
        let result = north + south
        
        XCTAssertEqual(result.range.meters, 0, accuracy: 0.001)
    }
    
    func testAddition_Perpendicular() {
        // 100m North + 100m East = 141m at bearing 45°
        let north = position(bearing: 0, range: 100)
        let east = position(bearing: 90, range: 100)
        
        let result = north + east
        
        XCTAssertEqual(result.range.meters, 141.42, accuracy: 0.01)
        XCTAssertEqual(result.bearing.degrees, 45, accuracy: 0.01)
    }

    func testSubtraction_Cartesian() {
        let p1 = position(x: 5, y: 7)
        let p2 = position(x: 2, y: 3)

        let result = p1 - p2
        
        XCTAssertEqual(result.x.meters, 3, accuracy: 0.0001)
        XCTAssertEqual(result.y.meters, 4, accuracy: 0.0001)
    }
    
    func testSubtraction_SamePosition() {
        let p = position(bearing: 45, range: 100)
        
        let result = p - p
        
        XCTAssertEqual(result.range.meters, 0, accuracy: 0.001)
    }
  
    func testNegation_Cartesian() {
        let p = position(x: 2, y: -3)
        
        let result = -p
        
        XCTAssertEqual(result.x.meters, -2, accuracy: 0.0001)
        XCTAssertEqual(result.y.meters, 3, accuracy: 0.0001)
    }
    
    func testNegation_Bearing() {
        // Negating flips to reciprocal bearing
        let p = position(bearing: 45, range: 100)
        
        let result = -p
        
        XCTAssertEqual(result.range.meters, 100, accuracy: 0.001)
        XCTAssertEqual(result.bearing.degrees, 225, accuracy: 0.001) // Reciprocal
    }

    func testMultiplication_Double() {
        let p = position(bearing: 90, range: 50) // 50m East
        
        let result = p * 2.0
        
        XCTAssertEqual(result.range.meters, 100, accuracy: 0.001)
        XCTAssertEqual(result.bearing.degrees, 90, accuracy: 0.001) // Same bearing
    }

    func testMultiplication_DoubleOnLeft() {
        let p = position(x: 1, y: -1)
        
        let result = 3.0 * p
        
        XCTAssertEqual(result.x.meters, 3, accuracy: 0.0001)
        XCTAssertEqual(result.y.meters, -3, accuracy: 0.0001)
    }
    
    func testMultiplication_Negative() {
        // Negative scalar reverses direction
        let p = position(bearing: 0, range: 100)
        
        let result = p * -1.0
        
        XCTAssertEqual(result.range.meters, 100, accuracy: 0.001)
        XCTAssertEqual(result.bearing.degrees, 180, accuracy: 0.001)
    }

    func testDivision() {
        let p = position(bearing: 270, range: 100) // 100m West
        
        let result = p / 4.0
        
        XCTAssertEqual(result.range.meters, 25, accuracy: 0.001)
        XCTAssertEqual(result.bearing.degrees, 270, accuracy: 0.001)
    }

    func testPlusEquals() {
        var p1 = position(x: 1, y: 1)
        let p2 = position(x: 2, y: 3)
        
        p1 += p2
        
        XCTAssertEqual(p1.x.meters, 3, accuracy: 0.0001)
        XCTAssertEqual(p1.y.meters, 4, accuracy: 0.0001)
    }

    func testMinusEquals() {
        var p1 = position(x: 5, y: 5)
        let p2 = position(x: 2, y: 1)
        
        p1 -= p2
        
        XCTAssertEqual(p1.x.meters, 3, accuracy: 0.0001)
        XCTAssertEqual(p1.y.meters, 4, accuracy: 0.0001)
    }

    func testTimesEquals() {
        var p = position(x: 2, y: 3)
        
        p *= 2
        
        XCTAssertEqual(p.x.meters, 4, accuracy: 0.0001)
        XCTAssertEqual(p.y.meters, 6, accuracy: 0.0001)
    }

    func testDivideEquals() {
        var p = position(x: 10, y: 20)
        
        p /= 5
        
        XCTAssertEqual(p.x.meters, 2, accuracy: 0.0001)
        XCTAssertEqual(p.y.meters, 4, accuracy: 0.0001)
    }
}
