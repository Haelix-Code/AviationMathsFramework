import XCTest
@testable import AviationMaths

final class VectorContractTests: XCTestCase {

    func testIsZero_trueOnlyWhenMagnitudeIsExactlyZero() {
        let zero = CartesianVector<UnitLength>(x: .init(meters: 0), y: .init(meters: 0))
        XCTAssertTrue(zero.isZero)

        let tiny = CartesianVector<UnitLength>(x: .init(meters: 1e-12), y: .init(meters: 0))
        XCTAssertFalse(tiny.isZero, "isZero uses exact magnitude == 0; lock that behavior in.")
    }

    func testDotProduct_knownCases() {
        // Using aviation convention:
        // 0° = North (+y), 90° = East (+x)
        let north = CartesianVector<UnitLength>(x: .init(meters: 0), y: .init(meters: 10))
        let east  = CartesianVector<UnitLength>(x: .init(meters: 10), y: .init(meters: 0))
        let south = CartesianVector<UnitLength>(x: .init(meters: 0), y: .init(meters: -4))

        XCTAssertEqual(north.dot(east), 0, accuracy: 1e-12)
        XCTAssertEqual(north.dot(south), -40, accuracy: 1e-12) // (0*0) + (10*-4)
    }

    func testAngleTo_returnsExpectedForPerpendicularParallelOpposite() {
        let north = CartesianVector<UnitLength>(x: .init(meters: 0), y: .init(meters: 10))
        let east  = CartesianVector<UnitLength>(x: .init(meters: 10), y: .init(meters: 0))
        let north2 = CartesianVector<UnitLength>(x: .init(meters: 0), y: .init(meters: 5))
        let south = CartesianVector<UnitLength>(x: .init(meters: 0), y: .init(meters: -5))

        XCTAssertEqual(north.angle(to: east).degrees, 90, accuracy: 1e-12)
        XCTAssertEqual(north.angle(to: north2).degrees, 0, accuracy: 1e-12)
        XCTAssertEqual(north.angle(to: south).degrees, 180, accuracy: 1e-12)
    }

    func testAngleTo_whenEitherVectorHasZeroMagnitude_returnsZeroRadians() {
        let zero = CartesianVector<UnitLength>(x: .init(meters: 0), y: .init(meters: 0))
        let v = CartesianVector<UnitLength>(x: .init(meters: 10), y: .init(meters: 0))

        XCTAssertEqual(zero.angle(to: v).radians, 0, accuracy: 1e-12)
        XCTAssertEqual(v.angle(to: zero).radians, 0, accuracy: 1e-12)
    }

    func testArithmeticOperators_preserveUnitsAndValues() {
        let a = CartesianVector<UnitSpeed>(x: .init(knots: 10), y: .init(knots: -5))
        let b = CartesianVector<UnitSpeed>(x: .init(knots: -3), y: .init(knots: 7))

        let sum = a + b
        XCTAssertEqual(sum.x.knots, 7, accuracy: 1e-12)
        XCTAssertEqual(sum.y.knots, 2, accuracy: 1e-12)

        let diff = a - b
        XCTAssertEqual(diff.x.knots, 13, accuracy: 1e-12)
        XCTAssertEqual(diff.y.knots, -12, accuracy: 1e-12)

        let scaled = a * 2
        XCTAssertEqual(scaled.x.knots, 20, accuracy: 1e-12)
        XCTAssertEqual(scaled.y.knots, -10, accuracy: 1e-12)

        let divided = a / 2
        XCTAssertEqual(divided.x.knots, 5, accuracy: 1e-12)
        XCTAssertEqual(divided.y.knots, -2.5, accuracy: 1e-12)
    }
}
