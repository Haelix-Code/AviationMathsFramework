import XCTest
@testable import AviationMaths

final class CardinalDirectionTests: XCTestCase {

    func testLatitudeDirectionSign() {
        XCTAssertEqual(LatitudeDirection.north.sign, 1.0)
        XCTAssertEqual(LatitudeDirection.south.sign, -1.0)
    }

    func testLatitudeDirectionInitFromDecimalDegrees() {
        XCTAssertEqual(LatitudeDirection(decimalDegrees: 10), .north)
        XCTAssertEqual(LatitudeDirection(decimalDegrees: -5), .south)
    }

    func testLongitudeDirectionSign() {
        XCTAssertEqual(LongitudeDirection.east.sign, 1.0)
        XCTAssertEqual(LongitudeDirection.west.sign, -1.0)
    }

    func testLongitudeDirectionInitFromDecimalDegrees() {
        XCTAssertEqual(LongitudeDirection(decimalDegrees: 20), .east)
        XCTAssertEqual(LongitudeDirection(decimalDegrees: -15), .west)
    }

    func testLongitudeDirectionInitFromDecimalDegrees_Zero_MatchesLatitudeConvention() {
        // LatitudeDirection treats the 0° boundary as the positive side
        // (equator counts as north); LongitudeDirection must do the same
        // (prime meridian counts as east) for the two to be consistent.
        XCTAssertEqual(LatitudeDirection(decimalDegrees: 0), .north)
        XCTAssertEqual(LongitudeDirection(decimalDegrees: 0), .east)
    }

    func testLongitudeDirectionFromBearing() {
        // Bearings in East range
        XCTAssertEqual(LongitudeDirection.from(bearing: 0), .east)
        XCTAssertEqual(LongitudeDirection.from(bearing: 90), .east)
        XCTAssertEqual(LongitudeDirection.from(bearing: 180), .east)

        // Bearings in West range
        XCTAssertEqual(LongitudeDirection.from(bearing: 181), .west)
        XCTAssertEqual(LongitudeDirection.from(bearing: 270), .west)
        XCTAssertEqual(LongitudeDirection.from(bearing: 359), .west)

        // Negative bearings
        XCTAssertEqual(LongitudeDirection.from(bearing: -1), .west)
        XCTAssertEqual(LongitudeDirection.from(bearing: -179), .west)
    }
}
