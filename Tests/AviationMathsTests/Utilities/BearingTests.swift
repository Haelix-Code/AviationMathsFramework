import XCTest
@testable import AviationMaths

final class BearingTests: XCTestCase {

    private struct Holder {
        @Bearing var bearing: Double
        init(_ value: Double) { self.bearing = value }
    }

    func testWrappedValue_normalizesIntoZeroTo360() {
        var h = Holder(0)
        XCTAssertEqual(h.bearing, 0, accuracy: 1e-12)

        h = Holder(360)
        XCTAssertEqual(h.bearing, 0, accuracy: 1e-12)

        h = Holder(-0.1)
        XCTAssertEqual(h.bearing, 359.9, accuracy: 1e-12)

        h = Holder(720)
        XCTAssertEqual(h.bearing, 0, accuracy: 1e-12)

        h = Holder(-721)
        XCTAssertEqual(h.bearing, 359, accuracy: 1e-12)
    }

    func testProjectedValue_isMeasurementInDegrees() {
        let h = Holder(270)
        XCTAssertEqual(h.$bearing.degrees, 270, accuracy: 1e-12)
    }

    func testReciprocal_andPerpendiculars_normalizeCorrectly() {
        let b = Bearing(degrees: 350)

        XCTAssertEqual(b.reciprocal.wrappedValue, 170, accuracy: 1e-12)

        let perpendiculars = b.perpendiculars
        XCTAssertEqual(perpendiculars.left.wrappedValue, 260, accuracy: 1e-12)  // 350 - 90
        XCTAssertEqual(perpendiculars.right.wrappedValue, 80, accuracy: 1e-12)  // 350 + 90 => 80
    }

    func testPerpendiculars_SameOrderAsMeasurementPerpendiculars() {
        for degrees in stride(from: 0.0, to: 360, by: 15) {
            let bearing = Bearing(degrees: degrees).perpendiculars
            let measurement = Measurement<UnitAngle>(degrees: degrees).perpendiculars

            XCTAssertEqual(bearing.0.wrappedValue, measurement.0.degrees, accuracy: 1e-12, "\(degrees)°")
            XCTAssertEqual(bearing.1.wrappedValue, measurement.1.degrees, accuracy: 1e-12, "\(degrees)°")
        }
    }

    func testNormalize_TinyNegativeInput_StaysBelow360() {
        let b = Bearing(degrees: -1e-14)
        XCTAssertLessThan(b.wrappedValue, 360)
        XCTAssertEqual(b.wrappedValue, 0)

        var h = Holder(10)
        h.bearing = -1e-14
        XCTAssertLessThan(h.bearing, 360)
    }

    func testDifferenceTo_shortestSignedDifferenceAcrossWrap() {
        let a = Bearing(degrees: 350)
        let b = Bearing(degrees: 10)

        // shortest path is +20 (not -340)
        XCTAssertEqual(a.difference(to: b), 20, accuracy: 1e-12)

        // reverse should be -20
        XCTAssertEqual(b.difference(to: a), -20, accuracy: 1e-12)
    }

    func testDifferenceTo_handles180BoundaryDeterministically() {
        let a = Bearing(degrees: 0)
        let b = Bearing(degrees: 180)

        // Implementation returns +180 (not -180)
        XCTAssertEqual(a.difference(to: b), 180, accuracy: 1e-12)
        XCTAssertEqual(b.difference(to: a), -180, accuracy: 1e-12)
    }

    func testCustomStringFormatting_zeroPads() {
        XCTAssertEqual(String(describing: Bearing(degrees: 0)), "360°")
        XCTAssertEqual(String(describing: Bearing(degrees: 5)), "005°")
        XCTAssertEqual(String(describing: Bearing(degrees: 45)), "045°")
        XCTAssertEqual(String(describing: Bearing(degrees: 360)), "360°")
    }

    func testCustomStringFormatting_North_DisplaysAs360() {
        XCTAssertEqual(String(describing: Bearing(degrees: 359.4)), "359°")
        XCTAssertEqual(String(describing: Bearing(degrees: 359.6)), "360°")
        XCTAssertEqual(String(describing: Bearing(degrees: 359.99)), "360°")
        XCTAssertEqual(String(describing: Bearing(degrees: 0.4)), "360°")
        XCTAssertEqual(String(describing: Bearing(degrees: -0.0)), "360°")
        XCTAssertEqual(String(describing: Bearing(degrees: 0.6)), "001°")
    }
}
