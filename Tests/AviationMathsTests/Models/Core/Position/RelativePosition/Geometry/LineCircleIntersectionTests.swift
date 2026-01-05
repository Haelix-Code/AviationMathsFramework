import XCTest
@testable import AviationMaths


final class LineCircleIntersectionTests: XCTestCase {
    
    func test_linePassesThroughCircle_returnsTwoIntersections() {
        // Line along x-axis through circle centred at (0, 100m) with radius 50m
        let lineOrigin = RelativePosition.zero
        let lineDirection = RelativePosition(bearing: .init(degrees: 90), range: .init(meters: 1))
        let circleCentre = RelativePosition(x: .init(meters: 0), y: .init(meters: 100))
        let radius = Measurement<UnitLength>(meters: 50)
        
        let result = LineCircle.intersect(
            lineOrigin: lineOrigin,
            lineDirection: lineDirection,
            circleCentre: circleCentre,
            radius: radius
        )
        
        XCTAssertTrue(result.passesThrough)
        XCTAssertEqual(result.parameters.count, 2)
    }
    
    func test_lineMissesCircle_returnsNoIntersections() {
        // Line along x-axis, circle centred at (0, 200m) with radius 50m
        let lineOrigin = RelativePosition.zero
        let lineDirection = RelativePosition(bearing: .init(degrees: 90), range: .init(meters: 1))
        let circleCentre = RelativePosition(x: .init(meters: 0), y: .init(meters: 200))
        let radius = Measurement<UnitLength>(meters: 50)
        
        let result = LineCircle.intersect(
            lineOrigin: lineOrigin,
            lineDirection: lineDirection,
            circleCentre: circleCentre,
            radius: radius
        )
        
        XCTAssertTrue(result.misses)
        XCTAssertEqual(result.parameters.count, 0)
    }
    
    func test_lineThroughCircleCentre_returnsSymmetricIntersections() {
        // Line through centre of circle at (1000m, 0) with radius 500m
        // Line direction: East (90°)
        let lineOrigin = RelativePosition.zero
        let lineDirection = RelativePosition(bearing: .init(degrees: 90), range: .init(meters: 1))
        let circleCentre = RelativePosition(x: .init(meters: 1000), y: .init(meters: 0))
        let radius = Measurement<UnitLength>(meters: 500)
        
        let result = LineCircle.intersect(
            lineOrigin: lineOrigin,
            lineDirection: lineDirection,
            circleCentre: circleCentre,
            radius: radius
        )
        
        XCTAssertTrue(result.passesThrough)
        XCTAssertEqual(result.parameters[0], 500, accuracy: 0.001)  // Entry at 500m
        XCTAssertEqual(result.parameters[1], 1500, accuracy: 0.001) // Exit at 1500m
    }
    
    func test_lineSouthbound_correctIntersections() {
        // Line heading South (180°) from origin
        // Circle centred at (0, -2000m) with radius 1000m
        let lineOrigin = RelativePosition.zero
        let lineDirection = RelativePosition(bearing: .init(degrees: 180), range: .init(meters: 1))
        let circleCentre = RelativePosition(x: .init(meters: 0), y: .init(meters: -2000))
        let radius = Measurement<UnitLength>(meters: 1000)
        
        let result = LineCircle.intersect(
            lineOrigin: lineOrigin,
            lineDirection: lineDirection,
            circleCentre: circleCentre,
            radius: radius
        )
        
        XCTAssertTrue(result.passesThrough)
        // Entry at 1000m along track, exit at 3000m
        XCTAssertEqual(result.parameters[0], 1000, accuracy: 0.001)
        XCTAssertEqual(result.parameters[1], 3000, accuracy: 0.001)
    }
}
