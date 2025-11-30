import XCTest
@testable import AviationMaths

final class RelativePositionTests: XCTestCase {
    
    func testInitWithBearingAndRange_North() {
        let pos = RelativePosition(bearing: .init(degrees: 0), range: .init(meters: 100))
        
        XCTAssertEqual(pos.bearing.degrees, 0, accuracy: 0.0001)
        XCTAssertEqual(pos.range.meters, 100, accuracy: 0.0001)
        XCTAssertEqual(pos.x.meters, 0, accuracy: 0.0001)
        XCTAssertEqual(pos.y.meters, 100, accuracy: 0.0001)
    }
    
    func testInitWithBearingAndRange_East() {
        let pos = RelativePosition(bearing: .init(degrees: 90), range: .init(meters: 100))
        
        XCTAssertEqual(pos.bearing.degrees, 90, accuracy: 0.0001)
        XCTAssertEqual(pos.x.meters, 100, accuracy: 0.0001)
        XCTAssertEqual(pos.y.meters, 0, accuracy: 0.0001)
    }
    
    func testInitWithBearingAndRange_South() {
        let pos = RelativePosition(bearing: .init(degrees: 180), range: .init(meters: 100))
        
        XCTAssertEqual(pos.bearing.degrees, 180, accuracy: 0.0001)
        XCTAssertEqual(pos.x.meters, 0, accuracy: 0.0001)
        XCTAssertEqual(pos.y.meters, -100, accuracy: 0.0001)
    }
    
    func testInitWithBearingAndRange_West() {
        let pos = RelativePosition(bearing: .init(degrees: 270), range: .init(meters: 100))
        
        XCTAssertEqual(pos.bearing.degrees, 270, accuracy: 0.0001)
        XCTAssertEqual(pos.x.meters, -100, accuracy: 0.0001)
        XCTAssertEqual(pos.y.meters, 0, accuracy: 0.0001)
    }
    
    func testInitWithXY_NorthEast() {
        // Q1: +x, +y → bearing 0-90°
        let pos = RelativePosition(x: .init(meters: 3), y: .init(meters: 4))
        
        XCTAssertEqual(pos.x.meters, 3, accuracy: 0.0001)
        XCTAssertEqual(pos.y.meters, 4, accuracy: 0.0001)
        XCTAssertEqual(pos.range.meters, 5, accuracy: 0.0001)
        XCTAssertEqual(pos.bearing.degrees, 36.87, accuracy: 0.01)  // atan(3/4)
    }
    
    func testInitWithXY_SouthEast() {
        // Q2: +x, -y → bearing 90-180°
        let pos = RelativePosition(x: .init(meters: 3), y: .init(meters: -4))
        
        XCTAssertEqual(pos.range.meters, 5, accuracy: 0.0001)
        XCTAssertEqual(pos.bearing.degrees, 143.13, accuracy: 0.01)  // 180 - atan(3/4)
    }
    
    func testInitWithXY_SouthWest() {
        // Q3: -x, -y → bearing 180-270°
        let pos = RelativePosition(x: .init(meters: -3), y: .init(meters: -4))
        
        XCTAssertEqual(pos.range.meters, 5, accuracy: 0.0001)
        XCTAssertEqual(pos.bearing.degrees, 216.87, accuracy: 0.01)  // 180 + atan(3/4)
    }
    
    func testInitWithXY_NorthWest() {
        // Q4: -x, +y → bearing 270-360°
        let pos = RelativePosition(x: .init(meters: -3), y: .init(meters: 4))
        
        XCTAssertEqual(pos.range.meters, 5, accuracy: 0.0001)
        XCTAssertEqual(pos.bearing.degrees, 323.13, accuracy: 0.01)  // 360 - atan(3/4)
    }
    
    func testInitWithVector2D() {
        let vector = CartesianVector(
            x: Measurement(value: 100, unit: UnitLength.meters),
            y: Measurement(value: 100, unit: UnitLength.meters)
        )
        
        let pos = RelativePosition(cartesianVector: vector)
        
        XCTAssertEqual(pos.x.meters, 100, accuracy: 0.0001)
        XCTAssertEqual(pos.y.meters, 100, accuracy: 0.0001)
        XCTAssertEqual(pos.bearing.degrees, 45, accuracy: 0.0001)
        XCTAssertEqual(pos.range.meters, 141.42, accuracy: 0.01)
    }
    
    // MARK: - Initialization with PolarCoordinate
    
    func testInitWithPolarCoordinate() {
        let polar = LengthPolar(bearing: .init(degrees: 135), magnitude: .init(meters: 100))
        
        let pos = RelativePosition(polarCoordinate: polar)
        
        XCTAssertEqual(pos.bearing.degrees, 135, accuracy: 0.0001)
        XCTAssertEqual(pos.range.meters, 100, accuracy: 0.0001)
        XCTAssertEqual(pos.x.meters, 70.71, accuracy: 0.01)
        XCTAssertEqual(pos.y.meters, -70.71, accuracy: 0.01)
    }
    
    // MARK: - Perpendicular Bearings
    
    func testPerpendicularBearings_North() {
        let pos = RelativePosition(bearing: .init(degrees: 0), range: .init(meters: 1))
        let perpendiculars = pos.perpendiculars
        
        XCTAssertEqual(perpendiculars.count, 2)
        XCTAssertEqual(perpendiculars[0].degrees, 90, accuracy: 0.0001)   // Right (East)
        XCTAssertEqual(perpendiculars[1].degrees, 270, accuracy: 0.0001)  // Left (West)
    }
    
    func testPerpendicularBearings_East() {
        let pos = RelativePosition(bearing: .init(degrees: 90), range: .init(meters: 1))
        let perpendiculars = pos.perpendiculars
        
        XCTAssertEqual(perpendiculars[0].degrees, 180, accuracy: 0.0001)  // Right (South)
        XCTAssertEqual(perpendiculars[1].degrees, 0, accuracy: 0.0001)    // Left (North)
    }
    
    func testPerpendicularBearings_WrappingHigh() {
        // 300° + 90° = 390° → 30°
        let pos = RelativePosition(bearing: .init(degrees: 300), range: .init(meters: 1))
        let perpendiculars = pos.perpendiculars
        
        XCTAssertEqual(perpendiculars[0].degrees, 30, accuracy: 0.0001)
        XCTAssertEqual(perpendiculars[1].degrees, 210, accuracy: 0.0001)
    }
    
    func testPerpendicularBearings_WrappingLow() {
        // 30° - 90° = -60° → 300°
        let pos = RelativePosition(bearing: .init(degrees: 30), range: .init(meters: 1))
        let perpendiculars = pos.perpendiculars
        
        XCTAssertEqual(perpendiculars[0].degrees, 120, accuracy: 0.0001)
        XCTAssertEqual(perpendiculars[1].degrees, 300, accuracy: 0.0001)
    }
    
    func testReciprocalBearing() {
        let testCases: [(original: Double, reciprocal: Double)] = [
            (0, 180),
            (45, 225),
            (90, 270),
            (135, 315),
            (180, 0),
            (225, 45),
            (270, 90),
            (315, 135)
        ]
        
        for tc in testCases {
            let pos = RelativePosition(bearing: .init(degrees: tc.original), range: .init(meters: 1))
            XCTAssertEqual(pos.reciprocalBearing.degrees, tc.reciprocal, accuracy: 0.0001,
                           "Failed reciprocal for \(tc.original)")
        }
    }
    
    func testRoundTrip_BearingToCartesianToBearing() {
        let bearings: [Double] = [0, 30, 45, 60, 90, 120, 135, 150, 180, 210, 225, 240, 270, 300, 315, 330]
        
        for bearing in bearings {
            let original = RelativePosition(bearing: .init(degrees: bearing), range: .init(meters: 1000))
            let fromCartesian = RelativePosition(x: original.x, y: original.y)
            
            XCTAssertEqual(fromCartesian.bearing.degrees, bearing, accuracy: 0.001,
                           "Failed round-trip for bearing \(bearing)")
            XCTAssertEqual(fromCartesian.range.meters, 1000, accuracy: 0.001)
        }
    }
    
    func testRoundTrip_CartesianToBearingToCartesian() {
        let testCases: [(x: Double, y: Double)] = [
            (100, 0),    // East
            (0, 100),    // North
            (-100, 0),   // West
            (0, -100),   // South
            (70.71, 70.71),    // NE
            (70.71, -70.71),   // SE
            (-70.71, -70.71),  // SW
            (-70.71, 70.71)    // NW
        ]
        
        for tc in testCases {
            let original = RelativePosition(x: .init(meters: tc.x), y: .init(meters: tc.y))
            let fromPolar = RelativePosition(bearing: original.bearing, range: original.range)
            
            XCTAssertEqual(fromPolar.x.meters, tc.x, accuracy: 0.01,
                           "Failed x round-trip for (\(tc.x), \(tc.y))")
            XCTAssertEqual(fromPolar.y.meters, tc.y, accuracy: 0.01,
                           "Failed y round-trip for (\(tc.x), \(tc.y))")
        }
    }
    
    func testZeroRange() {
        let pos = RelativePosition(bearing: .init(degrees: 45), range: .init(meters: 0))
        
        XCTAssertEqual(pos.range.meters, 0, accuracy: 0.0001)
        XCTAssertEqual(pos.x.meters, 0, accuracy: 0.0001)
        XCTAssertEqual(pos.y.meters, 0, accuracy: 0.0001)
    }
    
    func testOriginPosition() {
        let pos = RelativePosition(x: .init(meters: 0), y: .init(meters: 0))
        
        XCTAssertEqual(pos.range.meters, 0, accuracy: 0.0001)
        // Bearing at origin is technically undefined, but should return 0
        XCTAssertEqual(pos.bearing.degrees, 0, accuracy: 0.0001)
    }
    
    func testBearingNormalization() {
        let pos = RelativePosition(bearing: .init(degrees: 450), range: .init(meters: 100))
        
        XCTAssertEqual(pos.bearing.degrees, 90, accuracy: 0.0001)
    }
    
    func testNegativeBearing() {
        let pos = RelativePosition(bearing: .init(degrees: -45), range: .init(meters: 100))
        
        XCTAssertEqual(pos.bearing.degrees, 315, accuracy: 0.0001)
    }
    
    // MARK: - Real-World Scenarios
    
    func testAircraftRelativePosition() {
        // Target is 5nm at bearing 045 from ownship
        let target = RelativePosition(
            bearing: .init(degrees: 45),
            range: .init(value: 5, unit: .nauticalMiles)
        )
        
        // Verify components
        let expectedComponent = 5 * sqrt(0.5)  // ~3.54nm
        XCTAssertEqual(target.x.converted(to: .nauticalMiles).value, expectedComponent, accuracy: 0.01)
        XCTAssertEqual(target.y.converted(to: .nauticalMiles).value, expectedComponent, accuracy: 0.01)
    }
    
}
