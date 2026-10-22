import XCTest
@testable import AviationMaths

final class UnitExtensionsTests: XCTestCase {

    func testNormalizedSigned_rangesToMinus180to180() {
        XCTAssertEqual(Measurement<UnitAngle>(degrees: 181).normalizedSigned.degrees, -179, accuracy: 1e-12)
        XCTAssertEqual(Measurement<UnitAngle>(degrees: 270).normalizedSigned.degrees, -90, accuracy: 1e-12)
        XCTAssertEqual(Measurement<UnitAngle>(degrees: -181).normalizedSigned.degrees, 179, accuracy: 1e-12)

        // Boundary behavior: <= -180 becomes +180 per implementation
        XCTAssertEqual(Measurement<UnitAngle>(degrees: -180).normalizedSigned.degrees, 180, accuracy: 1e-12)
        XCTAssertEqual(Measurement<UnitAngle>(degrees: 180).normalizedSigned.degrees, 180, accuracy: 1e-12)
    }

    func testReciprocalAndPerpendiculars_normalizeCorrectly() {
        let b = Measurement<UnitAngle>(degrees: 350)

        XCTAssertEqual(b.reciprocal.degrees, 170, accuracy: 1e-12)

        let (p1, p2) = b.perpendiculars
        XCTAssertEqual(p1.degrees, 80, accuracy: 1e-12)   // 350 + 90 => 440 => 80
        XCTAssertEqual(p2.degrees, 260, accuracy: 1e-12)  // 350 - 90 => 260
    }

    func testLongitudeDirectionFromBearing() {
        XCTAssertEqual(LongitudeDirection.from(bearing: 0), .east)
        XCTAssertEqual(LongitudeDirection.from(bearing: 180), .east)
        XCTAssertEqual(LongitudeDirection.from(bearing: 180.0001), .west)
        XCTAssertEqual(LongitudeDirection.from(bearing: 270), .west)

        // Wrap / negative handling
        XCTAssertEqual(LongitudeDirection.from(bearing: 450), .east)  // 90
        XCTAssertEqual(LongitudeDirection.from(bearing: -90), .west)  // 270
    }
}
