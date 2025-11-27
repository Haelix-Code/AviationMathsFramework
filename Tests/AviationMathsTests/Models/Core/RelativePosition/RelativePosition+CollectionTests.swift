import XCTest
@testable import AviationMaths

final class RelativePositionCollectionTests: XCTestCase {

    func testSummingInitializerWithCollection() {
        let pos1 = RelativePosition(x: Measurement(value: 3, unit: UnitLength.meters),
                                    y: Measurement(value: 4, unit: UnitLength.meters))
        let pos2 = RelativePosition(x: Measurement(value: 1, unit: UnitLength.meters),
                                    y: Measurement(value: 2, unit: UnitLength.meters))

        let summed = RelativePosition(summing: [pos1, pos2])

        XCTAssertEqual(summed.x.value, 4, accuracy: 0.0001)
        XCTAssertEqual(summed.y.value, 6, accuracy: 0.0001)
    }

    func testAveragingInitializerWithCollection() {
        let pos1 = RelativePosition(x: Measurement(value: 2, unit: UnitLength.meters),
                                    y: Measurement(value: 4, unit: UnitLength.meters))
        let pos2 = RelativePosition(x: Measurement(value: 6, unit: UnitLength.meters),
                                    y: Measurement(value: 8, unit: UnitLength.meters))

        let averaged = RelativePosition(averaging: [pos1, pos2])

        XCTAssertNotNil(averaged)
        XCTAssertEqual(averaged!.x.value, 4, accuracy: 0.0001)
        XCTAssertEqual(averaged!.y.value, 6, accuracy: 0.0001)
    }

    func testAveragingInitializerWithEmptyCollectionReturnsNil() {
        let averaged = RelativePosition(averaging: [RelativePosition]())
        XCTAssertNil(averaged)
    }

    func testCollectionSumExtension() {
        let positions = [
            RelativePosition(x: Measurement(value: 1, unit: UnitLength.meters),
                             y: Measurement(value: 2, unit: UnitLength.meters)),
            RelativePosition(x: Measurement(value: 3, unit: UnitLength.meters),
                             y: Measurement(value: 4, unit: UnitLength.meters))
        ]

        let sum = positions.sum()

        XCTAssertEqual(sum.x.value, 4, accuracy: 0.0001)
        XCTAssertEqual(sum.y.value, 6, accuracy: 0.0001)
    }

    func testCollectionAverageExtension() {
        let positions = [
            RelativePosition(x: Measurement(value: 2, unit: UnitLength.meters),
                             y: Measurement(value: 2, unit: UnitLength.meters)),
            RelativePosition(x: Measurement(value: 4, unit: UnitLength.meters),
                             y: Measurement(value: 6, unit: UnitLength.meters))
        ]

        let avg = positions.average()

        XCTAssertNotNil(avg)
        XCTAssertEqual(avg!.x.value, 3, accuracy: 0.0001)
        XCTAssertEqual(avg!.y.value, 4, accuracy: 0.0001)
    }

    func testSequenceSumExtension() {
        let positions = [
            RelativePosition(x: Measurement(value: 5, unit: UnitLength.meters),
                             y: Measurement(value: 1, unit: UnitLength.meters)),
            RelativePosition(x: Measurement(value: 2, unit: UnitLength.meters),
                             y: Measurement(value: 3, unit: UnitLength.meters))
        ]

        let sum = positions.sum()

        XCTAssertEqual(sum.x.value, 7, accuracy: 0.0001)
        XCTAssertEqual(sum.y.value, 4, accuracy: 0.0001)
    }
}
