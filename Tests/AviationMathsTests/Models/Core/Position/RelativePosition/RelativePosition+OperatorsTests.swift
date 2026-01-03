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

    func testSumAndAverage() {
        let a = RelativePosition(x: .init(meters: 10), y: .init(meters: 0))
        let b = RelativePosition(x: .init(meters: 0), y: .init(meters: 20))
        let c = RelativePosition(x: .init(meters: -5), y: .init(meters: 5))

        let sum = [a, b, c].sum()
        XCTAssertEqual(sum.x.meters, 5, accuracy: 1e-12)
        XCTAssertEqual(sum.y.meters, 25, accuracy: 1e-12)

        let avg = [a, b, c].average()
        XCTAssertNotNil(avg)
        XCTAssertEqual(avg!.x.meters, 5.0 / 3.0, accuracy: 1e-12)
        XCTAssertEqual(avg!.y.meters, 25.0 / 3.0, accuracy: 1e-12)
    }

    func testAverage_emptyReturnsNil() {
        let empty: [RelativePosition] = []
        XCTAssertNil(empty.average())
    }
}
