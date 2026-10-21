import XCTest
@testable import AviationMaths

final class CartesianVectorArithmeticTests: XCTestCase {

    private func v(_ x: Double, _ y: Double) -> LengthCartesianVector {
        CartesianVector(
            x: .init(meters: x),
            y: .init(meters: y)
        )
    }

    func testAddition() {
        let a = v(1, 2)
        let b = v(3, 4)

        let result = a + b

        XCTAssertEqual(result.x.meters, 4)
        XCTAssertEqual(result.y.meters, 6)
    }

    func testSubtraction() {
        let a = v(5, 7)
        let b = v(2, 3)

        let result = a - b

        XCTAssertEqual(result.x.meters, 3)
        XCTAssertEqual(result.y.meters, 4)
    }

    func testUnaryMinus() {
        let a = v(3, -4)

        let result = -a

        XCTAssertEqual(result.x.meters, -3)
        XCTAssertEqual(result.y.meters, 4)
    }

    func testScalarMultiplication() {
        let a = v(2, -3)

        let result = a * 4

        XCTAssertEqual(result.x.meters, 8)
        XCTAssertEqual(result.y.meters, -12)
    }

    func testScalarMultiplicationReverse() {
        let a = v(2, -3)

        let result = 4 * a

        XCTAssertEqual(result.x.meters, 8)
        XCTAssertEqual(result.y.meters, -12)
    }

    func testScalarDivision() {
        let a = v(8, -6)

        let result = a / 2

        XCTAssertEqual(result.x.meters, 4)
        XCTAssertEqual(result.y.meters, -3)
    }

    func testSum_MixedUnits_ConvertsToCommonUnit() {
        let metres = v(100, 0)
        let feet = LengthCartesianVector(x: .init(feet: 100), y: .init(feet: 0))

        let result = CartesianVector.sum([metres, feet])

        XCTAssertEqual(result.x.meters, 130.48, accuracy: 1e-9)
    }

    func testAngle_MixedUnits_ParallelVectorsAreZeroDegreesApart() {
        let metres = v(100, 0)
        let feet = LengthCartesianVector(x: .init(feet: 100), y: .init(feet: 0))

        XCTAssertEqual(metres.angle(to: feet).degrees, 0, accuracy: 1e-9)
        XCTAssertEqual(metres.angle(between: feet).degrees, 0, accuracy: 1e-9)
    }

    func testMagnitudeAndBearing_MixedComponentUnits() {
        let vector = SpeedCartesianVector(x: .init(knots: 10), y: .init(mps: 10))
        let yKnots = Measurement<UnitSpeed>(mps: 10).knots

        XCTAssertEqual(vector.magnitude.knots, (100 + yKnots * yKnots).squareRoot(), accuracy: 1e-9)
        XCTAssertEqual(vector.bearing.degrees, atan2(10, yKnots) * 180 / .pi, accuracy: 1e-9)
    }

}
