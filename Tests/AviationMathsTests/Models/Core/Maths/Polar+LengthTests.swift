import XCTest
import Foundation
@testable import AviationMaths

final class PolarVectorLengthTests: XCTestCase {

    func testLengthProperty() {
        let v = LengthPolar(angle: .init(value: .pi/4, unit: .radians),
                            magnitude: .init(meters: 5))
        XCTAssertEqual(v.length.value, 5)
        XCTAssertEqual(v.length.unit, UnitLength.meters)
    }

    func testLengthCartesianVector() {
        let v = LengthPolar(angle: .init(value: .pi/4, unit: .radians),
                            magnitude: .init(meters: 1))
        let cart = v.lengthCartesianVector
        XCTAssertEqual(cart.x.meters, 0.7071, accuracy: 0.001)
        XCTAssertEqual(cart.y.meters, 0.7071, accuracy: 0.001)
    }

}
