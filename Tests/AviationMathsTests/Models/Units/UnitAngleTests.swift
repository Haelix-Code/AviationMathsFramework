import XCTest
@testable import AviationMaths

final class UnitAngleTests: XCTestCase {

    func testNormalized_TypicalValues() {
        XCTAssertEqual(Measurement<UnitAngle>(degrees: 45).normalized.degrees, 45)
        XCTAssertEqual(Measurement<UnitAngle>(degrees: 400).normalized.degrees, 40)
        XCTAssertEqual(Measurement<UnitAngle>(degrees: -10).normalized.degrees, 350)
    }

    /// A negative input small enough that `degrees + 360` rounds to exactly 360.0
    /// (reachable from floating-point noise, e.g. out of `atan2`) must still land
    /// strictly inside `0..<360`, not land on the open upper bound.
    func testNormalized_TinyNegativeNoise_StaysBelow360() {
        for tinyNegative in [-1e-14, -1e-15, -1e-16] {
            let result = Measurement<UnitAngle>(degrees: tinyNegative).normalized.degrees
            XCTAssertLessThan(result, 360, "normalized() returned \(result) for input \(tinyNegative)")
            XCTAssertGreaterThanOrEqual(result, 0)
        }
    }
}
