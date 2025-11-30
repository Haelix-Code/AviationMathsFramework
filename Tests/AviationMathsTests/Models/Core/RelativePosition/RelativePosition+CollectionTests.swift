import XCTest
@testable import AviationMaths

final class RelativePositionCollectionTests: XCTestCase {

    private func position(bearing: Double, range: Double) -> RelativePosition {
        RelativePosition(bearing: .init(degrees: bearing), range: .init(meters: range))
    }
    
    private func position(x: Double, y: Double) -> RelativePosition {
        RelativePosition(x: .init(meters: x), y: .init(meters: y))
    }

    func testSumming_Cartesian() {
        let pos1 = position(x: 3, y: 4)
        let pos2 = position(x: 1, y: 2)

        let summed = RelativePosition(summing: [pos1, pos2])

        XCTAssertEqual(summed.x.meters, 4, accuracy: 0.0001)
        XCTAssertEqual(summed.y.meters, 6, accuracy: 0.0001)
    }
    
    func testSumming_CardinalDirections() {
        // Sum of 4 cardinal directions at equal range = zero
        let positions = [
            position(bearing: 0, range: 100),
            position(bearing: 90, range: 100),
            position(bearing: 180, range: 100),
            position(bearing: 270, range: 100)
        ]
        
        let summed = RelativePosition(summing: positions)
        
        XCTAssertEqual(summed.range.meters, 0, accuracy: 0.001)
    }
    
    func testSumming_SameDirection() {
        // Three positions all bearing North
        let positions = [
            position(bearing: 0, range: 100),
            position(bearing: 0, range: 50),
            position(bearing: 0, range: 25)
        ]
        
        let summed = RelativePosition(summing: positions)
        
        XCTAssertEqual(summed.range.meters, 175, accuracy: 0.001)
        XCTAssertEqual(summed.bearing.degrees, 0, accuracy: 0.001)
    }

    func testAveraging_Cartesian() {
        let pos1 = position(x: 2, y: 4)
        let pos2 = position(x: 6, y: 8)

        let averaged = RelativePosition(averaging: [pos1, pos2])

        XCTAssertNotNil(averaged)
        XCTAssertEqual(averaged!.x.meters, 4, accuracy: 0.0001)
        XCTAssertEqual(averaged!.y.meters, 6, accuracy: 0.0001)
    }
    
    func testAveraging_BearingMidpoint() {
        // Average of NE and SE should be East
        let ne = position(bearing: 45, range: 100)
        let se = position(bearing: 135, range: 100)
        
        let averaged = RelativePosition(averaging: [ne, se])
        
        XCTAssertNotNil(averaged)
        XCTAssertEqual(averaged!.bearing.degrees, 90, accuracy: 0.01)
    }

    func testAveraging_EmptyCollection() {
        let averaged = RelativePosition(averaging: [RelativePosition]())
        XCTAssertNil(averaged)
    }

    func testCollectionSum() {
        let positions = [
            position(x: 1, y: 2),
            position(x: 3, y: 4)
        ]

        let sum = positions.sum()

        XCTAssertEqual(sum.x.meters, 4, accuracy: 0.0001)
        XCTAssertEqual(sum.y.meters, 6, accuracy: 0.0001)
    }

    func testCollectionAverage() {
        let positions = [
            position(x: 2, y: 2),
            position(x: 4, y: 6)
        ]

        let avg = positions.average()

        XCTAssertNotNil(avg)
        XCTAssertEqual(avg!.x.meters, 3, accuracy: 0.0001)
        XCTAssertEqual(avg!.y.meters, 4, accuracy: 0.0001)
    }
    
    func testCollectionAverage_Empty() {
        let positions: [RelativePosition] = []
        let avg = positions.average()
        XCTAssertNil(avg)
    }

    func testSequenceSum() {
        let positions = [
            position(x: 5, y: 1),
            position(x: 2, y: 3)
        ]

        let sum = positions.sum()

        XCTAssertEqual(sum.x.meters, 7, accuracy: 0.0001)
        XCTAssertEqual(sum.y.meters, 4, accuracy: 0.0001)
    }
    
    func testAveragePosition_Waypoints() {
        // Find centroid of a triangular pattern
        let waypoints = [
            position(bearing: 0, range: 100), // North
            position(bearing: 120, range: 100), // SE
            position(bearing: 240, range: 100) // SW
        ]
        
        let centroid = waypoints.average()
        
        XCTAssertNotNil(centroid)
        // Centroid of equilateral triangle centered at origin is at origin
        XCTAssertEqual(centroid!.range.meters, 0, accuracy: 0.1)
    }
}
