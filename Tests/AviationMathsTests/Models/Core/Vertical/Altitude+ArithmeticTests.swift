import XCTest
@testable import AviationMaths

final class AltitudeArithmeticTests: XCTestCase {

    private let ref: VerticalReference = .amsl

    private func makeAltitude(
        meters: Double,
        context: AltitudeContext = .standardISA
    ) -> Altitude {
        Altitude(
            value: Measurement(value: meters, unit: .meters),
            reference: ref,
            context: context
        )
    }

    func testMidpoint_returnsArithmeticMeanInMeters() throws {
        let lower = makeAltitude(meters: 1000)
        let upper = makeAltitude(meters: 3000)

        let mid = try lower.midpoint(to: upper, in: ref)

        let midMeters = mid.value(in: ref).converted(to: .meters).value
        XCTAssertEqual(midMeters, 2000, accuracy: 0.0001,
                       "Midpoint should be the arithmetic mean of the two altitudes in meters")
    }

    func testMidpoint_throwsOnMismatchedContext() {
        let a = makeAltitude(meters: 1000, context: .standardISA)
        let b = makeAltitude(meters: 3000, context: .pressureAltitudeOnly(groundElevation: .init(feet: 100)))

        XCTAssertThrowsError(try a.midpoint(to: b, in: ref)) { error in
            XCTAssertEqual(error as? AltitudeArithmeticError,
                           .mismatchedContext,
                           "Midpoint should throw AltitudeArithmeticError.mismatchedContext when contexts differ")
        }
    }

    func testInterpolated_tZero_returnsSelf() throws {
        let start = makeAltitude(meters: 1000)
        let end   = makeAltitude(meters: 3000)

        let result = try start.interpolated(to: end, fraction: 0.0, in: ref)

        let resultMeters = result.value(in: ref).converted(to: .meters).value
        XCTAssertEqual(resultMeters, 1000, accuracy: 0.0001,
                       "t = 0 should yield the start altitude")
    }

    func testInterpolated_tOne_returnsOther() throws {
        let start = makeAltitude(meters: 1000)
        let end   = makeAltitude(meters: 3000)

        let result = try start.interpolated(to: end, fraction: 1.0, in: ref)

        let resultMeters = result.value(in: ref).converted(to: .meters).value
        XCTAssertEqual(resultMeters, 3000, accuracy: 0.0001,
                       "t = 1 should yield the end altitude")
    }

    func testInterpolated_throwsOnMismatchedContext() {
        let start = makeAltitude(meters: 1000)
        let end   = makeAltitude(meters: 3000, context: .pressureAltitudeOnly(groundElevation: .init(feet: 100)))

        XCTAssertThrowsError(try start.interpolated(to: end, fraction: 0.5, in: ref)) { error in
            XCTAssertEqual(error as? AltitudeArithmeticError,
                           .mismatchedContext,
                           "Interpolated should throw AltitudeArithmeticError.mismatchedContext when contexts differ")
        }
    }
}
